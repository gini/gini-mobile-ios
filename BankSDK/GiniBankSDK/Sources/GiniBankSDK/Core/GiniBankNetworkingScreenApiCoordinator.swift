//
//  GiniPayBankNetworkingScreenApiCoordinator.swift
//  GiniBank
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

protocol Coordinator: AnyObject {
    var rootViewController: UIViewController { get }
    var childCoordinators: [Coordinator] { get set }
}

open class GiniBankNetworkingScreenApiCoordinator: GiniScreenAPICoordinator, GiniCaptureDelegate {
    static var currentCoordinator: GiniBankNetworkingScreenApiCoordinator?
    var childCoordinators: [Coordinator] = []

    // MARK: - GiniCaptureDelegate

    public func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        // Common logic for creating extractions
        func createExtractions(for key: String, from document: GiniQRCodeDocument) -> [Extraction] {
            return document.extractedParameters.compactMap {
                Extraction(box: nil, candidates: nil,
                           entity: key,
                           value: $0.value,
                           name: key)
            }
        }

        // Common logic for delivering the result
        func deliverExtractionResult(for key: String, document: GiniQRCodeDocument) {
            let extractions = createExtractions(for: key, from: document)
            let extractionResult = ExtractionResult(extractions: extractions,
                                                    lineItems: [],
                                                    returnReasons: [],
                                                    candidates: [:])
            deliver(result: extractionResult, analysisDelegate: networkDelegate)
        }

        // The EPS QR codes are a special case, since they don't have to be analyzed by the Gini Bank API and therefore,
        // they are ready to be delivered after capturing them.
        if let qrCodeDocument = document as? GiniQRCodeDocument,
           let format = qrCodeDocument.qrCodeFormat,
           format == .eps4mobile {
            deliverExtractionResult(for: QRCodesExtractor.epsCodeUrlKey, document: qrCodeDocument)
            return
        }

        // When an non reviewable document or an image in multipage mode is captured,
        // it has to be uploaded right away.
        if giniConfiguration.multipageEnabled || !document.isReviewable {
            if (document as? GiniImageDocument)?.isFromOtherApp ?? false {
                uploadAndStartAnalysisWithReturnAssistant(document: document,
                                                          networkDelegate: networkDelegate,
                                                          uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
                return
            }
            if !document.isReviewable {
                uploadAndStartAnalysisWithReturnAssistant(document: document,
                                                          networkDelegate: networkDelegate,
                                                          uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
            } else if giniConfiguration.multipageEnabled {
                // When multipage is enabled the document upload result should be communicated to the network delegate
                uploadWithReturnAssistant(document: document,
                                          didComplete: networkDelegate.uploadDidComplete,
                                          didFail: networkDelegate.uploadDidFail)
            }
        }
    }

    public func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if giniConfiguration.multipageEnabled {
            documentService.sortDocuments(withSameOrderAs: documents)
        }

        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService.update(imageDocument: document)
        }

        // In multipage mode the analysis can be triggered once the documents have been uploaded.
        // However, in single mode, the analysis can be triggered right after capturing the image.
        // That is why the document upload shuld be done here and start the analysis afterwards
        if giniConfiguration.multipageEnabled {
            startAnalysisWithReturnAssistant(networkDelegate: networkDelegate)
        } else {
            uploadAndStartAnalysisWithReturnAssistant(document: documents[0],
                                                      networkDelegate: networkDelegate,
                                                      uploadDidFail: {
                self.didReview(documents: documents, networkDelegate: networkDelegate)
            })
        }
    }

    public func didCancelCapturing() {
        resultsDelegate?.giniCaptureDidCancelAnalysis()
    }

    public func didCancelReview(for document: GiniCaptureDocument) {
        documentService.remove(document: document)
    }

    public func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        if pages.type == .image {
            documentService.cancelAnalysis()
        } else {
            documentService.resetToInitialState()
        }
    }

    weak var resultsDelegate: GiniCaptureResultsDelegate?
    let documentService: DocumentServiceProtocol
    private var configurationService: ClientConfigurationServiceProtocol?
    private var analyticsService: AnalyticsServiceProtocol?
    var giniBankConfiguration = GiniBankConfiguration.shared

    /// Internal coordinator for managing transaction documents, conforming to `TransactionDocsDataInternalProtocol`.
    /// Provides access to internal methods like retrieving the view model, deleting documents, and loading document data.
    /// This is cast from the public-facing protocol for internal SDK use only.
    private var transactionDocsDataCoordinator: TransactionDocsDataInternalProtocol? {
        return GiniBankConfiguration
            .shared.transactionDocsDataCoordinator as? TransactionDocsDataInternalProtocol
    }

    public init(client: Client,
                resultsDelegate: GiniCaptureResultsDelegate,
                configuration: GiniBankConfiguration,
                documentMetadata: Document.Metadata?,
                api: APIDomain,
                trackingDelegate: GiniCaptureTrackingDelegate?,
                lib: GiniBankAPI) {
        documentService = DocumentService(lib: lib, metadata: Self.makeMetadata(with: documentMetadata))
        configurationService = lib.configurationService()
        analyticsService = lib.analyticService()
        let captureConfiguration = configuration.captureConfiguration()
        super.init(withDelegate: nil, giniConfiguration: captureConfiguration)

        visionDelegate = self
        GiniBank.setConfiguration(configuration)
        giniBankConfiguration = configuration
        giniBankConfiguration.documentService = documentService
        self.resultsDelegate = resultsDelegate
        self.trackingDelegate = trackingDelegate
    }

    private init(resultsDelegate: GiniCaptureResultsDelegate,
                 configuration: GiniBankConfiguration,
                 documentMetadata: Document.Metadata?,
                 trackingDelegate: GiniCaptureTrackingDelegate?,
                 lib: GiniBankAPI) {
        documentService = DocumentService(lib: lib, metadata: Self.makeMetadata(with: documentMetadata))
        configurationService = lib.configurationService()
        analyticsService = lib.analyticService()
        let captureConfiguration = configuration.captureConfiguration()
        super.init(withDelegate: nil, giniConfiguration: captureConfiguration)

        visionDelegate = self
        GiniBank.setConfiguration(configuration)
        giniBankConfiguration = configuration
        giniBankConfiguration.documentService = documentService
        self.resultsDelegate = resultsDelegate
        self.trackingDelegate = trackingDelegate
    }

    public init(resultsDelegate: GiniCaptureResultsDelegate,
                configuration: GiniBankConfiguration,
                documentMetadata: Document.Metadata?,
                trackingDelegate: GiniCaptureTrackingDelegate?,
                captureNetworkService: GiniCaptureNetworkService,
                configurationService: ClientConfigurationServiceProtocol?) {
        documentService = DocumentService(giniCaptureNetworkService: captureNetworkService,
                                          metadata: Self.makeMetadata(with: documentMetadata))
        self.configurationService = configurationService
        let captureConfiguration = configuration.captureConfiguration()

        super.init(withDelegate: nil,
                   giniConfiguration: captureConfiguration)
        giniBankConfiguration = configuration
        giniBankConfiguration.documentService = documentService
        GiniBank.setConfiguration(configuration)
        visionDelegate = self
        self.resultsDelegate = resultsDelegate
        self.trackingDelegate = trackingDelegate
    }

    convenience init(client: Client,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     configuration: GiniBankConfiguration,
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     userApi: UserDomain,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        let lib = GiniBankAPI
            .Builder(client: client, api: api, userApi: userApi)
            .build()

        self.init(client: client,
                  resultsDelegate: resultsDelegate,
                  configuration: configuration,
                  documentMetadata: documentMetadata,
                  api: api,
                  trackingDelegate: trackingDelegate,
                  lib: lib)
    }

    convenience init(alternativeTokenSource tokenSource: AlternativeTokenSource,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     configuration: GiniBankConfiguration,
                     documentMetadata: Document.Metadata?,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        let lib = GiniBankAPI
            .Builder(alternativeTokenSource: tokenSource)
            .build()

        self.init(resultsDelegate: resultsDelegate,
                  configuration: configuration,
                  documentMetadata: documentMetadata,
                  trackingDelegate: trackingDelegate,
                  lib: lib)
    }

    private func deliver(result: ExtractionResult, analysisDelegate: AnalysisDelegate) {
        let hasExtractions = result.extractions.count > 0

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if hasExtractions {
                let images = self.pages.compactMap { $0.document.previewImage }
                let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: result.extractions.compactMap {
                    guard let name = $0.name else { return nil }

                    return (name, $0)
                })

                let result = AnalysisResult(extractions: extractions,
                                            lineItems: result.lineItems,
                                            images: images,
                                            candidates: result.candidates)

                let documentService = self.documentService

                self.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: result)
                documentService.resetToInitialState()
            } else {
                analysisDelegate.tryDisplayNoResultsScreen()
                self.documentService.resetToInitialState()
            }
        }
    }

    public func didPressEnterManually() {
        self.resultsDelegate?.giniCaptureDidEnterManually()
    }

    /**
     This method first attempts to fetch configuration settings using the `configurationService`.
     If the configurations are successfully fetched, it initializes the analytics with the fetched configuration
     on the main thread. Regardless of the result of fetching configurations, it then proceeds to start the
     SDK with the provided documents.
     */
    public func startSDK(withDocuments documents: [GiniCaptureDocument]?, animated: Bool = false) -> UIViewController {
        Self.currentCoordinator = self
        setupAnalytics(withDocuments: documents)
        configurationService?.fetchConfigurations { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let configuration):
                DispatchQueue.main.async {
                    GiniBankUserDefaultsStorage.clientConfiguration = configuration
                    GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled = configuration.qrCodeEducationEnabled
                    GiniCaptureUserDefaultsStorage.eInvoiceEnabled = configuration.eInvoiceEnabled
                    self.initializeAnalytics(with: configuration)
                }
            case .failure(let error):
                print("❌ configurationService with error: \(error)")
                // There will be no retries if the endpoint fails.
                // We will not implement any caching mechanism on our side if the request is too slow.
                // In case of a failure, the UJ analytics will remain disabled for that session.
            }
        }
        return start(withDocuments: documents, animated: animated)
    }

    public static func closeSDK() {
        currentCoordinator?.finishWithCancellation()
        currentCoordinator?.giniBankConfiguration.cleanup()
        currentCoordinator = nil
    }
}

// MARK: - Analytics Handling Extension

private extension GiniBankNetworkingScreenApiCoordinator {

    private func setupAnalytics(withDocuments documents: [GiniCaptureDocument]?) {
        // Clean the GiniAnalyticsManager properties and events queue between SDK sessions.
        /// The `cleanManager` method of `GiniAnalyticsManager` is called to ensure that properties and events
        /// are reset between SDK sessions. This is particularly important when the SDK is reopened using
        /// the `openWith` flow after it has already been opened for the first time. Without this reset,
        /// residual properties and events from the previous session could lead to incorrect analytics data.
        GiniAnalyticsManager.cleanManager()

        // Set new sessionId every time the SDK is initialized
        GiniAnalyticsManager.setSessionId()

        var entryPointValue = GiniEntryPointAnalytics.makeFrom(entryPoint: giniConfiguration.entryPoint).rawValue
        if let documents = documents, !documents.isEmpty, !documents.containsDifferentTypes {
            entryPointValue = GiniEntryPointAnalytics.openWith.rawValue
        }
        GiniAnalyticsManager.registerSuperProperties([.entryPoint: entryPointValue])
        GiniAnalyticsManager.track(event: .sdkOpened, screenName: nil)
    }

    private func initializeAnalytics(with configuration: ClientConfiguration) {
        let analyticsEnabled = configuration.userJourneyAnalyticsEnabled
        let analyticsConfiguration = GiniAnalyticsConfiguration(clientID: configuration.clientID,
                                                                userJourneyAnalyticsEnabled: analyticsEnabled)

        GiniAnalyticsManager.trackUserProperties([.returnAssistantEnabled: configuration.returnAssistantEnabled,
                                                  .returnReasonsEnabled: giniBankConfiguration.enableReturnReasons,
                                                  .bankSDKVersion: GiniBankSDKVersion,
                                                  .instantPaymentEnabled: configuration.instantPaymentEnabled])
        GiniAnalyticsManager.initializeAnalytics(with: analyticsConfiguration,
                                                 analyticsAPIService: analyticsService)
    }

    private func sendAnalyticsEventSDKClose() {
        let properties: [GiniAnalyticsProperty] = [GiniAnalyticsProperty(key: .status, value: "successful")]
        GiniAnalyticsManager.track(event: .sdkClosed,properties: properties)
    }

    private func setDocumentIdAsUserProperty() {
        guard let documentId = documentService.document?.id else { return }
        GiniAnalyticsManager.registerSuperProperties([.documentId: documentId])
    }
}

// MARK: - Return Assistant
private extension GiniBankNetworkingScreenApiCoordinator {

    // MARK: - Start Analysis with Return Assistant or Skonto

    private func startAnalysisWithReturnAssistant(networkDelegate: GiniCaptureNetworkDelegate) {
        documentService.startAnalysis { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let extractionResult):
                self.setDocumentIdAsUserProperty()
                Task {
                    await self.handleSuccessfulAnalysis(with: extractionResult, networkDelegate: networkDelegate)
                }
            case .failure(let error):
                guard error != .requestCancelled else { return }

                DispatchQueue.main.async { [weak self] in
                    self?.displayError(errorType: ErrorType(error: error), animated: true)
                }
            }
        }
    }

    // handleSuccessfulAnalysis runs entirely on the main actor.
    @MainActor
    private func handleSuccessfulAnalysis(with extractionResult: ExtractionResult,
                                          networkDelegate: GiniCaptureNetworkDelegate) async {
        if let analysisVC = screenAPINavigationController.children.last as? AnalysisViewController {
            await analysisVC.waitUntilAnimationCompleted()
        } else if let qrCodeVC = screenAPINavigationController.children.last as? QRCodeEducationPresenting,
                  let task = qrCodeVC.educationTask {
            _ = await task.value
        }

        presentNextScreen(extractionResult: extractionResult, delegate: networkDelegate)
    }

    @MainActor
    private func presentNextScreen(extractionResult: ExtractionResult,
                                   delegate: GiniCaptureNetworkDelegate) {
        if GiniBankConfiguration.shared.returnAssistantEnabled,
           let lineItems = extractionResult.lineItems, !lineItems.isEmpty {
            handleReturnAssistantScreenDisplay(extractionResult, delegate)
        } else if GiniBankConfiguration.shared.skontoEnabled,
                  let skontoDiscounts = extractionResult.skontoDiscounts, !skontoDiscounts.isEmpty {
            handleSkontoScreenDisplay(extractionResult, delegate)
        } else {
            let document = documentService.document
            handleTransactionDocsAlert(on: screenAPINavigationController,
                                       extractionResult: extractionResult,
                                       documentId: document?.id,
                                       deliveryFunction: { [weak self] result in
                guard let self = self else { return }
                self.deliverWithReturnAssistant(result: result, analysisDelegate: delegate)
            })
        }
    }

    // MARK: - Deliver with Return Assistant
    private func deliverWithReturnAssistant(result: ExtractionResult, analysisDelegate: AnalysisDelegate) {
        let hasExtractions = result.extractions.count > 0

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if hasExtractions {
                let images = self.pages.compactMap { $0.document.previewImage }
                let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: result.extractions.compactMap {
                    guard let name = $0.name else { return nil }

                    return (name, $0)
                })

                let documentService = self.documentService

                let result = AnalysisResult(extractions: extractions,
                                            lineItems: result.lineItems,
                                            skontoDiscounts: result.skontoDiscounts,
                                            images: images,
                                            document: documentService.document,
                                            candidates: result.candidates)
                sendAnalyticsEventSDKClose()
                self.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: result)

                self.giniBankConfiguration.lineItems = result.lineItems
                if let skontoDiscounts = result.skontoDiscounts {
                    self.giniBankConfiguration.skontoDiscounts = skontoDiscounts
                    self.sendSkontoTransferSummary(extractions: extractions)
                }
            } else {
                analysisDelegate.tryDisplayNoResultsScreen()
                self.documentService.resetToInitialState()
            }
        }
    }

    private func showDigitalInvoiceScreen(digitalInvoice: DigitalInvoice, analysisDelegate: AnalysisDelegate) {
        let coordinator = DigitalInvoiceCoordinator(navigationController: screenAPINavigationController,
                                                    digitalInvoice: digitalInvoice,
                                                    analysisDelegate: analysisDelegate)
        coordinator.delegate = self
        coordinator.skontoDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    private func handleReturnAssistantScreenDisplay(_ extractionResult: ExtractionResult,
                                                    _ networkDelegate: GiniCaptureNetworkDelegate) {
        do {
            let digitalInvoice = try DigitalInvoice(extractionResult: extractionResult)
            showDigitalInvoiceScreen(digitalInvoice: digitalInvoice,
                                     analysisDelegate: networkDelegate)
        } catch {
            deliverWithReturnAssistant(result: extractionResult,
                                       analysisDelegate: networkDelegate)
        }
    }

    private func uploadWithReturnAssistant(document: GiniCaptureDocument,
                                           didComplete: @escaping (GiniCaptureDocument) -> Void,
                                           didFail: @escaping (GiniCaptureDocument, GiniError) -> Void) {
        documentService.upload(document: document) { result in
            switch result {
            case .success:
                didComplete(document)
            case let .failure(error):
                didFail(document, error)
            }
        }
    }

    private func uploadAndStartAnalysisWithReturnAssistant(document: GiniCaptureDocument,
                                                           networkDelegate: GiniCaptureNetworkDelegate,
                                                           uploadDidFail: @escaping () -> Void) {
        uploadWithReturnAssistant(document: document, didComplete: { _ in
            self.startAnalysisWithReturnAssistant(networkDelegate: networkDelegate)
        }, didFail: { _, error in
            DispatchQueue.main.async {
                guard error != .requestCancelled else { return }
                networkDelegate.displayError(errorType: ErrorType(error: error), animated: true)
            }
        })
    }
}

extension GiniBankNetworkingScreenApiCoordinator: DigitalInvoiceCoordinatorDelegate {
    func didFinishAnalysis(_ coordinator: DigitalInvoiceCoordinator,
                           invoice: DigitalInvoice?,
                           analysisDelegate: GiniCaptureSDK.AnalysisDelegate) {
        guard let invoice = invoice else { return }
        let document = documentService.document
        self.handleTransactionDocsAlert(on: self.screenAPINavigationController,
                                        extractionResult: invoice.extractionResult,
                                        documentId: document?.id,
                                        deliveryFunction: { [weak self] result in
            self?.deliverWithReturnAssistant(result: result, analysisDelegate: analysisDelegate)
        })
    }

    func didCancelAnalysis(_ coordinator: DigitalInvoiceCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        resultsDelegate?.giniCaptureDidCancelAnalysis()
    }
}

extension GiniBankNetworkingScreenApiCoordinator: DocumentPagesProvider {
    func getDocumentPages(completion: @escaping (Result<[Document.Page], GiniError>) -> Void) {
        documentService.pages(completion: completion)
    }

    func getDocumentPage(for pageNumber: Int,
                         size: Document.Page.Size,
                         completion: @escaping (Result<Data, GiniError>) -> Void) {
        documentService.documentPage(pageNumber: pageNumber,
                                     size: size,
                                     completion: completion)
    }
}

// MARK: - Skonto
extension GiniBankNetworkingScreenApiCoordinator {
    // MARK: - Deliver with Skonto
    private func deliverWithSkonto(result: ExtractionResult, analysisDelegate: AnalysisDelegate? = nil) {
        let hasExtractions = result.extractions.count > 0

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if hasExtractions {
                let images = self.pages.compactMap { $0.document.previewImage }
                let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: result.extractions.compactMap {
                    guard let name = $0.name else { return nil }

                    return (name, $0)
                })

                let documentService = self.documentService

                let result = AnalysisResult(extractions: extractions,
                                            skontoDiscounts: result.skontoDiscounts,
                                            images: images,
                                            document: documentService.document,
                                            candidates: result.candidates)
                self.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: result)

                self.giniBankConfiguration.skontoDiscounts = result.skontoDiscounts
                self.sendSkontoTransferSummary(extractions: extractions)
            } else {
                analysisDelegate?.tryDisplayNoResultsScreen()
                self.documentService.resetToInitialState()
            }
        }
    }

    private func sendSkontoTransferSummary(extractions: [String: Extraction]) {
        guard let extractionAmount = ExtractionAmount.extract(from: extractions) else { return }
        let amountToPayString = extractionAmount.formattedString()
        let amountExtraction = createAmountExtraction(value: amountToPayString)
        giniBankConfiguration.sendTransferSummaryWithSkonto(amountToPayExtraction: amountExtraction,
                                                            amountToPayString: amountToPayString)
    }

    private func createAmountExtraction(value: String) -> Extraction {
        return Extraction(box: nil,
                          candidates: nil,
                          entity: "amount",
                          value: value,
                          name: "amountToPay")
    }

    private func showSkontoScreen(skontoDiscounts: SkontoDiscounts, documentId: String) {
        let coordinator = SkontoCoordinator(screenAPINavigationController,
                                            skontoDiscounts)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    private func handleSkontoScreenDisplay(_ extractionResult: ExtractionResult,
                                           _ networkDelegate: GiniCaptureNetworkDelegate) {
        do {
            guard let documentId = documentService.document?.id else { return }
            let skontoDiscounts = try SkontoDiscounts(extractions: extractionResult)
            showSkontoScreen(skontoDiscounts: skontoDiscounts, documentId: documentId)
        } catch {
            deliverWithSkonto(result: extractionResult,
                              analysisDelegate: networkDelegate)
        }
    }

    private func getDocumentLayout(completion: @escaping (Result<Document.Layout, GiniError>) -> Void) {
        documentService.layout(completion: completion)
    }
}

extension GiniBankNetworkingScreenApiCoordinator: SkontoCoordinatorDelegate {
    func didFinishAnalysis(_ coordinator: SkontoCoordinator,
                           _ editedExtractionResult: GiniBankAPILibrary.ExtractionResult?) {
        guard let editedExtractionResult else { return }
        let document = documentService.document
        self.handleTransactionDocsAlert(on: self.screenAPINavigationController,
                                        extractionResult: editedExtractionResult,
                                        documentId: document?.id,
                                        deliveryFunction: { [weak self] result in
            self?.deliverWithSkonto(result: result)
        })
    }

    func didCancelAnalysis(_ coordinator: SkontoCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        pages = []
        didCancelAnalysis()
        _ = start(withDocuments: nil, animated: true)
    }

    func didTapDocumentPreview(_ coordinator: Coordinator, _ skontoViewModel: SkontoViewModel) {
        let errorButtonTitle = SkontoDocumentPagesViewModel.errorButtonTitle
        let screenTitle = SkontoDocumentPagesViewModel.screenTitle
        let viewController = DocumentPagesViewController(screenTitle: screenTitle,
                                                         errorButtonTitle: errorButtonTitle)
        viewController.modalPresentationStyle = .overCurrentContext
        screenAPINavigationController.present(viewController, animated: true)

        guard let documentPagesViewModel = skontoViewModel.documentPagesViewModel else {
            handleDocumentPage(for: skontoViewModel, with: viewController)
            return
        }

        if documentPagesViewModel.processedImages.isEmpty {
            handleDocumentPage(for: skontoViewModel, with: viewController)
        } else {
            viewController.stopLoadingIndicatorAnimation()
            viewController.setData(viewModel: documentPagesViewModel)
        }
    }

    private func handleTransactionDocsAlert(on navigationController: UINavigationController,
                                            extractionResult: ExtractionResult,
                                            documentId: String?,
                                            deliveryFunction: @escaping (ExtractionResult) -> Void) {
        guard extractionResult.extractions.count > 0 else {
            deliveryFunction(extractionResult)
            return
        }

        self.handleTransactionDocsAlertIfNeeded(on: navigationController,
                                                defaultAction: { [weak self] in
            self?.giniBankConfiguration.transactionDocsDataCoordinator.transactionDocs = []
            deliveryFunction(extractionResult)
        },
                                                attachAction: { [weak self] in
            if let documentId = documentId {
                // NOTE: For now all the documents that are not PDfs will be saved with name "Document.png"
                // this should come from backend in the feature
                // for PDFs documents Gini store the original name
                let originalFileName = originalDocumentName ?? "Document.png"
                self?.giniBankConfiguration.transactionDocsDataCoordinator
                    .transactionDocs = [.init(documentId: documentId,
                                              originalFileName: originalFileName)]
                self?.setTransactionDocsDataToDisplay(with: extractionResult, for: documentId)
            } else {
                self?.giniBankConfiguration.transactionDocsDataCoordinator.transactionDocs = []
            }

            deliveryFunction(extractionResult)
        })
    }

    private func handleDocumentPage(for skontoViewModel: SkontoViewModel,
                                    with viewController: DocumentPagesViewController) {
        createDocumentPageViewModel(from: skontoViewModel) { [weak self] result in
            guard let self = self else { return }
            viewController.stopLoadingIndicatorAnimation()
            switch result {
            case .success(let viewModel):
                viewController.setData(viewModel: viewModel)
            case .failure(let error):
                self.handleDocumentPageError(for: skontoViewModel, with: viewController, error: error)
            }
        }
    }

    private func handleDocumentPageError(for skontoViewModel: SkontoViewModel,
                                         with viewController: DocumentPagesViewController,
                                         error: GiniError) {
        viewController.setError(errorType: .init(error: error)) { [weak self] in
            guard let self = self else { return }
            viewController.startLoadingIndicatorAnimation()
            self.handleDocumentPage(for: skontoViewModel, with: viewController)
        }
    }

    private typealias SkontoDocumentPagesResult = Result<SkontoDocumentPagesViewModel, GiniError>

    private func createDocumentPageViewModel(from skontoViewModel: SkontoViewModel,
                                             completion: @escaping (SkontoDocumentPagesResult) -> Void) {
        let dispatchGroup = DispatchGroup()
        var originalSizes: [DocumentPageSize] = []
        var pageImages: [UIImage] = []
        var layoutError: GiniError?
        var documentPagesError: GiniError?

        dispatchGroup.enter()
        getDocumentLayout { result in
            switch result {
            case .success(let documentLayout):
                originalSizes = documentLayout.pages.map {
                    DocumentPageSize(width: $0.sizeX, height: $0.sizeY)
                }
            case .failure(let error):
                layoutError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        loadDocumentPages { result in
            switch result {
            case .success(let images):
                pageImages = images
            case .failure(let error):
                documentPagesError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let layoutError = layoutError {
                completion(.failure(layoutError))
            } else if let documentPagesError = documentPagesError {
                completion(.failure(documentPagesError))
            } else {
                let extractionBoundingBoxes = skontoViewModel.extractionBoundingBoxes
                let viewModel = SkontoDocumentPagesViewModel(originalImages: pageImages,
                                                             originalSizes: originalSizes,
                                                             extractionBoundingBoxes: extractionBoundingBoxes,
                                                             amountToPay: skontoViewModel.amountToPay,
                                                             skontoAmountToPay: skontoViewModel.skontoAmountToPay,
                                                             expiryDate: skontoViewModel.dueDate)
                skontoViewModel.setDocumentPagesViewModel(viewModel)
                completion(.success(viewModel))
            }
        }
    }

    private func loadDocumentPages(completion: @escaping (Result<[UIImage], GiniError>) -> Void) {
        DocumentServiceHelper.fetchDocumentPages(from: self, completion: completion)
    }

    private func loadAllPages(pages: [Document.Page], completion: @escaping (Result<[UIImage], GiniError>) -> Void) {
        DocumentServiceHelper.loadAllPages(from: self, pages: pages, completion: completion)
    }
}

extension GiniBankNetworkingScreenApiCoordinator {
    private func setTransactionDocsDataToDisplay(with extractionResult: ExtractionResult, for documentId: String) {
        transactionDocsDataCoordinator?.loadDocumentData = { [weak self] in
            guard let viewModel = self?.transactionDocsDataCoordinator?.getTransactionDocsViewModel(),
                  let images = viewModel.cachedImages[documentId],
                  !images.isEmpty else {
                self?.loadDocumentPagesAndHandleErrors(for: documentId, with: extractionResult.extractions)
                return
            }

            let extractions = extractionResult.extractions
            self?.transactionDocsDataCoordinator?.updateTransactionDocsViewModel(with: images,
                                                                                 extractions: extractions,
                                                                                 for: documentId)
        }
    }

    private func loadDocumentPagesAndHandleErrors(for documentId: String, with extractions: [Extraction]) {
        DocumentServiceHelper.fetchDocumentPages(from: self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let images):
                    self.transactionDocsDataCoordinator?.updateTransactionDocsViewModel(
                        with: images,
                        extractions: extractions,
                        for: documentId
                    )
                case .failure(let error):
                    self.handlePreviewDocumentError(error: error)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func handlePreviewDocumentError(error: GiniError) {
        let viewModel = transactionDocsDataCoordinator?.getTransactionDocsViewModel()
        viewModel?.setPreviewDocumentError(error: error) { [weak self] in
            self?.transactionDocsDataCoordinator?.loadDocumentData?()
        }
    }
}

// MARK: - Document Metadata creation
extension GiniBankNetworkingScreenApiCoordinator {
    private static func makeMetadata(with documentMetadata: Document.Metadata?) -> Document.Metadata {
        guard var documentMetadata else {
            return .init(bankSDKVersion: GiniBankSDKVersion)
        }
        documentMetadata.addGiniBankSDKVersion(GiniBankSDKVersion)
        return documentMetadata
    }
}
