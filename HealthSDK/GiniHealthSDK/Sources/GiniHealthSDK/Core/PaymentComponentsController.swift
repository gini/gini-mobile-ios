//
//  PaymentComponentController.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
import GiniInternalPaymentSDK
import GiniUtilites

/**
 Protocol used to provide updates on the current status of the Payment Components Controller.
 Uses a callback mechanism to handle payment provider requests.
 */
public protocol PaymentComponentsControllerProtocol: AnyObject {
    func isLoadingStateChanged(isLoading: Bool) // Because we can't use Combine
    func didFetchedPaymentProviders()
}

/// A protocol for handling user actions in the Payment Providers bottom views.
public protocol PaymentProvidersBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider, documentId: String?)
    func didTapOnClose()
    func didTapOnMoreInformation()
    func didTapOnContinueOnShareBottomSheet(documentId: String?)
    func didTapForwardOnInstallBottomSheet()
    func didTapOnPayButton()
}

/// A protocol that provides configuration settings for various payment components.
public protocol PaymentComponentsConfigurationProvider {
    var paymentReviewContainerConfiguration: PaymentReviewContainerConfiguration { get }
    var installAppConfiguration: InstallAppConfiguration { get }
    var bottomSheetConfiguration: BottomSheetConfiguration { get }
    var shareInvoiceConfiguration: ShareInvoiceConfiguration { get }
    var paymentInfoConfiguration: PaymentInfoConfiguration { get }
    var bankSelectionConfiguration: BankSelectionConfiguration { get }
    var paymentComponentsConfiguration: PaymentComponentsConfiguration { get }
    var paymentReviewConfiguration: PaymentReviewConfiguration { get }
    var poweredByGiniConfiguration: PoweredByGiniConfiguration { get }
    var moreInformationConfiguration: MoreInformationConfiguration { get }
    var paymentComponentConfiguration: PaymentComponentConfiguration { get set }

    var primaryButtonConfiguration: ButtonConfiguration { get }
    var secondaryButtonConfiguration: ButtonConfiguration { get }
    var defaultStyleInputFieldConfiguration: TextFieldConfiguration { get }
    var errorStyleInputFieldConfiguration: TextFieldConfiguration { get }
    var selectionStyleInputFieldConfiguration: TextFieldConfiguration { get }

    var showPaymentReviewCloseButton: Bool { get }
    var paymentComponentButtonsHeight: CGFloat { get }
}

/// A protocol that provides localized string resources for various payment components.
public protocol PaymentComponentsStringsProvider {
    var paymentReviewContainerStrings: PaymentReviewContainerStrings { get }
    var paymentComponentsStrings: PaymentComponentsStrings { get }
    var installAppStrings: InstallAppStrings { get }
    var shareInvoiceStrings: ShareInvoiceStrings { get }
    var paymentInfoStrings: PaymentInfoStrings { get }
    var banksBottomStrings: BanksBottomStrings { get }
    var paymentReviewStrings: PaymentReviewStrings { get }
    var poweredByGiniStrings: PoweredByGiniStrings { get }
    var moreInformationStrings: MoreInformationStrings { get }
}

protocol PaymentComponentsProtocol {
    var isLoading: Bool { get set }
    var selectedPaymentProvider: PaymentProvider? { get set }
    func loadPaymentProviders()
    func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
    func paymentView(documentId: String?) -> UIView
    func bankSelectionBottomSheet(documentId: String?) -> UIViewController
    func loadPaymentReviewScreenFor(documentId: String?, paymentInfo: PaymentInfo?, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void)
    func paymentInfoViewController() -> UIViewController
    func paymentViewBottomSheet(documentId: String?) -> UIViewController
}

/**
 The `PaymentComponentsController` class allows control over the payment components.
 */
public final class PaymentComponentsController: PaymentComponentsProtocol, BottomSheetsProviderProtocol {
    /// handling the Payment Component Controller delegate
    public weak var delegate: PaymentComponentsControllerProtocol?
    /// handling the Payment Component view delegate
    public weak var viewDelegate: PaymentComponentViewProtocol?
    /// handling the Payment Bottom view delegate
    public weak var bottomViewDelegate: PaymentProvidersBottomViewProtocol?

    private let giniSDK: GiniHealth
    private var trackingDelegate: GiniHealthTrackingDelegate?

    private var paymentProviders: GiniHealthAPILibrary.PaymentProviders = []

    private let configurationProvider: PaymentComponentsConfigurationProvider
    private let stringsProvider: PaymentComponentsStringsProvider

    /// storing the current selected payment provider
    public var selectedPaymentProvider: PaymentProvider?
    private var healthSelectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider? {
        selectedPaymentProvider?.toHealthPaymentProvider()
    }

    /// reponsible for storing the loading state of the controller and passing it to the delegate listeners
    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }
    
    var paymentComponentView: PaymentComponentView!

    /// Previous presented view
    private var previousPresentedView: PaymentComponentScreenType?

    /**
     Initializer of the Payment Component Controller class.

     - Parameters:
        - giniHealth: An instance of GiniHealth initialized with GiniHealthAPI.
     - Returns:
        - instance of the payment component controller class
     */
    public init(giniHealth: GiniHealth & PaymentComponentsConfigurationProvider & PaymentComponentsStringsProvider) {
        self.giniSDK = giniHealth
        self.configurationProvider = giniHealth
        self.stringsProvider = giniHealth
        setupObservers()
    }

    /**
     Retrieves the default installed payment provider, if available.
     - Returns: a Payment Provider object.
     */
    private func defaultInstalledPaymentProvider() -> PaymentProvider? {
        savedPaymentProvider()
    }
    
    /**
     Loads the payment providers list and stores them.
     - note: Also triggers a function that checks if the payment providers are installed.
     */
    public func loadPaymentProviders() {
        self.isLoading = true
        self.giniSDK.fetchBankingApps { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(paymentProviders):
                self?.paymentProviders = paymentProviders.map{ $0.toHealthPaymentProvider() }
                self?.sortPaymentProviders()
                self?.selectedPaymentProvider = self?.defaultInstalledPaymentProvider()
                self?.delegate?.didFetchedPaymentProviders()
            case let .failure(error):
                GiniUtilites.Log("Couldn't load payment providers: \(error.localizedDescription)", event: .error)
            }
        }
    }
    
    private func storeDefaultPaymentProvider(paymentProvider: PaymentProvider) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(paymentProvider)
            UserDefaults.standard.set(data, forKey: Constants.kDefaultPaymentProvider)
        } catch {
            GiniUtilites.Log("Unable to encode payment provider: (\(error))", event: .error)
        }
    }
    
    private func savedPaymentProvider() -> PaymentProvider? {
        if let data = UserDefaults.standard.data(forKey: Constants.kDefaultPaymentProvider) {
            do {
                let decoder = JSONDecoder()
                let paymentProvider = try decoder.decode(PaymentProvider.self, from: data)
                if self.paymentProviders.contains(where: { $0.id == paymentProvider.id }) {
                    return paymentProvider
                }
            } catch {
                GiniUtilites.Log("Unable to decode payment provider: (\(error))", event: .error)
            }
        }
        return nil
    }

    /**
     Checks if the document is payable by extracting the IBAN.
     - Parameters:
         - docId: The ID of the uploaded document.
         - completion: A closure for processing asynchronous data received from the service. It has a Result type parameter, representing either success or failure. The completion block is called on the main thread.
         In the case of success, it includes a boolean value indicating whether the IBAN was extracted successfully.
         In case of failure, it returns an error from the server side.
     */
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        giniSDK.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
     - Returns: a custom view
     */
    func paymentView(documentId: String?) -> UIView {
        let paymentComponentViewModel = PaymentComponentViewModel(
            paymentProvider: healthSelectedPaymentProvider,
            primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
            secondaryButtonConfiguration: configurationProvider.secondaryButtonConfiguration,
            configuration: configurationProvider.paymentComponentsConfiguration,
            strings: stringsProvider.paymentComponentsStrings,
            poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
            poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
            moreInformationConfiguration: configurationProvider.moreInformationConfiguration,
            moreInformationStrings: stringsProvider.moreInformationStrings,
            minimumButtonsHeight: configurationProvider.paymentComponentButtonsHeight,
            paymentComponentConfiguration: configurationProvider.paymentComponentConfiguration
        )
        paymentComponentViewModel.delegate = self
        paymentComponentViewModel.documentId = documentId
        return PaymentComponentView(viewModel: paymentComponentViewModel)
    }

    /**
     Provides a custom Gini for the payment view that is going to be presented as a bottom sheet.

     - Parameter documentId: An optional identifier for the document associated with the payment.
     - Returns: A configured `UIViewController` for displaying the payment bottom view.
     */
    public func paymentViewBottomSheet(documentId: String?) -> UIViewController {
        previousPresentedView = .paymentComponent
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(documentId: documentId), bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return paymentComponentBottomView
    }

    /**
     Provides a custom Gini view for the bank selection bottom sheet.

     - Parameter documentId: An optional identifier for the document associated with the bank selection.
     - Returns: A configured `UIViewController` for displaying the bank selection options.
     */
    public func bankSelectionBottomSheet(documentId: String?) -> UIViewController {
        previousPresentedView = .bankPicker
        let paymentProvidersBottomViewModel = BanksBottomViewModel(paymentProviders: paymentProviders,
                                                                   selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                   configuration: configurationProvider.bankSelectionConfiguration,
                                                                   strings: stringsProvider.banksBottomStrings,
                                                                   poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                   poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                                                   moreInformationConfiguration: configurationProvider.moreInformationConfiguration,
                                                                   moreInformationStrings: stringsProvider.moreInformationStrings)
        paymentProvidersBottomViewModel.viewDelegate = self
        paymentProvidersBottomViewModel.documentId = documentId
        return BanksBottomView(viewModel: paymentProvidersBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
    }

    /**
     Loads the payment review screen for the specified document or for the provided payment information

     This method fetches data for review based on the provided document ID. If the configuration
     allows for invoice handling without a document, it directly loads the payment review screen
     using the provided payment information provided.

     - Parameters:
       - documentId: An optional identifier for the document being reviewed.
       - paymentInfo: An optional `PaymentInfo` object containing details about the payment.
       - trackingDelegate: An optional delegate for tracking events related to Gini Health.
       - completion: A closure that is called with the resulting `UIViewController` and an optional
         `GiniHealthError` once the loading process is complete.
     */
    public func loadPaymentReviewScreenFor(documentId: String?, paymentInfo: PaymentInfo?, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
        previousPresentedView = nil
        if !GiniHealthConfiguration.shared.useInvoiceWithoutDocument {
            guard let documentId else {
                completion(nil, nil)
                return
            }
            self.isLoading = true
            self.giniSDK.fetchDataForReview(documentId: documentId) { [weak self] result in
                self?.isLoading = false
                switch result {
                    case .success(let data):
                        guard let self else {
                            completion(nil, nil)
                            return
                        }
                        self.preparePaymentReviewViewController(data: data, paymentInfo: nil, completion: completion)
                    case .failure(let error):
                        completion(nil, error)
                }
            }
        } else {
            loadPaymentReviewScreenWithoutDocument(paymentInfo: paymentInfo, trackingDelegate: trackingDelegate, completion: completion)
        }
    }

    private func loadPaymentReviewScreenWithoutDocument(paymentInfo: PaymentInfo?, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
        previousPresentedView = nil
        preparePaymentReviewViewController(data: nil, paymentInfo: paymentInfo, completion: completion)
    }

    private func preparePaymentReviewViewController(data: DataForReview?, paymentInfo: PaymentInfo?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
        guard let healthSelectedPaymentProvider else {
            completion(nil, nil)
            return
        }
        let viewModel = PaymentReviewModel(delegate: self,
                                           bottomSheetsProvider: self,
                                           document: data?.document.toHealthDocument(),
                                           extractions: data?.extractions.map { $0.toHealthExtraction() },
                                           paymentInfo: paymentInfo,
                                           selectedPaymentProvider: healthSelectedPaymentProvider,
                                           configuration: configurationProvider.paymentReviewConfiguration,
                                           strings: stringsProvider.paymentReviewStrings,
                                           containerConfiguration: configurationProvider.paymentReviewContainerConfiguration,
                                           containerStrings: stringsProvider.paymentReviewContainerStrings,
                                           defaultStyleInputFieldConfiguration: configurationProvider.defaultStyleInputFieldConfiguration,
                                           errorStyleInputFieldConfiguration: configurationProvider.errorStyleInputFieldConfiguration,
                                           selectionStyleInputFieldConfiguration: configurationProvider.selectionStyleInputFieldConfiguration,
                                           primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
                                           secondaryButtonConfiguration: configurationProvider.secondaryButtonConfiguration,
                                           poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                           poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                           bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration,
                                           showPaymentReviewCloseButton: configurationProvider.showPaymentReviewCloseButton)

        let vc = PaymentReviewViewController.instantiate(viewModel: viewModel,
                                                         selectedPaymentProvider: healthSelectedPaymentProvider)

        completion(vc, nil)
    }

    /**
     Provides a custom Gini view for displaying payment more information view.

     This method initializes a `PaymentInfoViewModel` with the necessary configurations and
     localized strings, then returns a `PaymentInfoViewController` with the view model.

     - Returns: A configured `UIViewController` for displaying payment information.
     */
    public func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders,
                                                        configuration: configurationProvider.paymentInfoConfiguration,
                                                        strings: stringsProvider.paymentInfoStrings,
                                                        poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                        poweredByGiniStrings: stringsProvider.poweredByGiniStrings)
        return PaymentInfoViewController(viewModel: paymentInfoViewModel)
    }

    /**
     Provides a custom Gini view for installing the app if not present.

     This method initializes an `InstallAppBottomViewModel` with the necessary configurations and
     localized strings, and returns an `InstallAppBottomView` configured with the view model.

     - Returns: A configured `BottomSheetViewController` for the app installation process.
     */
    public func installAppBottomSheet() -> BottomSheetViewController {
        previousPresentedView = nil
        let installAppBottomViewModel = InstallAppBottomViewModel(selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                  installAppConfiguration: configurationProvider.installAppConfiguration,
                                                                  strings: stringsProvider.installAppStrings,
                                                                  primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
                                                                  poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                  poweredByGiniStrings: stringsProvider.poweredByGiniStrings)
        installAppBottomViewModel.viewDelegate = self
        let installAppBottomView = InstallAppBottomView(viewModel: installAppBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return installAppBottomView
    }

    /**
     Provides a custom Gini view for onboarding the user about the sharing invoices flow.

     This method initializes a `ShareInvoiceBottomViewModel` with the necessary configurations and
     localized strings, and returns a `ShareInvoiceBottomView` configured with the view model.
     It also increments the onboarding count for the selected payment provider.

     - Parameter documentId: An optional identifier for the document associated with the invoice.
     - Returns: A configured `BottomSheetViewController` for sharing invoices.
     */
    public func shareInvoiceBottomSheet(documentId: String?) -> BottomSheetViewController {
        previousPresentedView = nil
        let shareInvoiceBottomViewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                      configuration: configurationProvider.shareInvoiceConfiguration,
                                                                      strings: stringsProvider.shareInvoiceStrings,
                                                                      primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
                                                                      poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                      poweredByGiniStrings: stringsProvider.poweredByGiniStrings)
        shareInvoiceBottomViewModel.viewDelegate = self
        shareInvoiceBottomViewModel.documentId = documentId
        let shareInvoiceBottomView = ShareInvoiceBottomView(viewModel: shareInvoiceBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        incrementOnboardingCountFor(paymentProvider: healthSelectedPaymentProvider)
        return shareInvoiceBottomView
    }

    private func incrementOnboardingCountFor(paymentProvider: GiniHealthAPILibrary.PaymentProvider?) {
        var onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        onboardingCounts.incrementPresentationCount(forProvider: paymentProvider?.name)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(paymentInfoDissapeared), name: .paymentInfoDissapeared, object: nil)
    }

    @objc
    private func paymentInfoDissapeared() {
        if previousPresentedView == .bankPicker {
            didTapOnBankPicker()
        } else if previousPresentedView == .paymentComponent {
            didTapOnPayButton()
        }
        previousPresentedView = nil
    }
}

extension PaymentComponentsController: BanksSelectionProtocol {
    /// Updates the selected payment provider and notifies the delegate with the provider and optional document ID.
    public func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider, documentId: String?) {
        selectedPaymentProvider = PaymentProvider(healthPaymentProvider: paymentProvider)
        if let provider = selectedPaymentProvider {
            storeDefaultPaymentProvider(paymentProvider: provider)
            bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: provider, documentId: documentId)
        }
    }

    /// Handles the action when the continue button is tapped on the share bottom sheet.
    public func didTapOnContinueOnShareBottomSheet(documentId: String?) {
        GiniUtilites.Log("Tapped Continue on Share Bottom Sheet", event: .success)
    }

    /// Handles the action when the forward button is tapped on the install bottom sheet.
    public func didTapForwardOnInstallBottomSheet() {
        GiniUtilites.Log("Tapped Forward on Install Bottom Sheet", event: .success)
    }

    /// Handles the action when the pay button is tapped on install bottom sheet.
    public func didTapOnPayButton() {
        bottomViewDelegate?.didTapOnPayButton()
    }
}

extension PaymentComponentsController: PaymentComponentViewProtocol {
    /// Handles the action when the more information button is tapped on the payment component view, using the provided document ID.
    public func didTapOnMoreInformation(documentId: String?) {
        viewDelegate?.didTapOnMoreInformation(documentId: documentId)
    }
    
    /// Handles the action when the bank picker button is tapped on the payment component view, using the provided document ID.
    public func didTapOnBankPicker(documentId: String?) {
        viewDelegate?.didTapOnBankPicker(documentId: documentId)
    }
    
    /// Handles the action when the pay invoice button is tapped on the payment component view, using the provided document ID.
    public func didTapOnPayInvoice(documentId: String?) {
        viewDelegate?.didTapOnPayInvoice(documentId: documentId)
    }
}

extension PaymentComponentsController: PaymentProvidersBottomViewProtocol {
    /// Updates the selected payment provider from the bank selection bottom view and notifies the delegate with the selected provider and document ID.
    public func didSelectPaymentProvider(paymentProvider: PaymentProvider, documentId: String?) {
        selectedPaymentProvider = paymentProvider
        storeDefaultPaymentProvider(paymentProvider: paymentProvider)
        bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: paymentProvider, documentId: documentId)
    }
    
    /// Notifies the delegate when the close button is tapped on bank selection bottom view
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }
    
    /// Notifies the delegate when the more information button is tapped on the bank selection bottom view
    public func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation()
    }
}

extension PaymentComponentsController: ShareInvoiceBottomViewProtocol {
    /// Notifies the delegate to continue sharing the invoice with the provided document ID.
    public func didTapOnContinueToShareInvoice(documentId: String?) {
        bottomViewDelegate?.didTapOnContinueOnShareBottomSheet(documentId: documentId)
    }
}

extension PaymentComponentsController: InstallAppBottomViewProtocol {
    // Notifies the delegate to proceed when the continue button is tapped in the install app bottom view. This happens after the user installed the app from AppStore
    public func didTapOnContinue() {
        bottomViewDelegate?.didTapForwardOnInstallBottomSheet()
    }
}

extension PaymentComponentsController: PaymentReviewProtocol {
    /**
     Creates a payment request using the provided payment information.

     - Parameter paymentInfo: The payment information to be used for the request.
     - Parameter completion: A closure to be executed once the request is completed, containing the result of the operation.
     */
    public func createPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo, completion: @escaping (Result<String, GiniHealthAPILibrary.GiniError>) -> Void) {
        let info = PaymentInfo(paymentConponentsInfo: paymentInfo)
        giniSDK.createPaymentRequest(paymentInfo: info, completion: { result in
            switch result {
            case .success(let paymentRequestId):
                completion(.success(paymentRequestId))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        })
    }

    // MARK: - Helping functions
    
    /// Checks if the payment provider app can be opened based on the selected payment provider and GPC(Gini Pay Connect) support.
    public func canOpenPaymentProviderApp() -> Bool {
        if supportsGPC() {
            if healthSelectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true {
                return true
            }
        }
        return false
    }


    /// Checks if the selected payment provider supports the "Open With" feature on iOS.
    public func supportsOpenWith() -> Bool {
        if healthSelectedPaymentProvider?.openWithSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    /// Checks if the selected payment provider supports GPC(Gini Pay Connect) on iOS.
    public func supportsGPC() -> Bool {
        if healthSelectedPaymentProvider?.gpcSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    /**
     Creates a payment request and obtains the PDF URL using the provided payment information.

     - Parameter paymentInfo: The payment information for the request.
     - Parameter viewController: The view controller used to present any necessary UI related to the request.
     */
    public func obtainPDFURLFromPaymentRequest(paymentInfo: PaymentInfo, viewController: UIViewController) {
        createPaymentRequest(paymentInfo: paymentInfo) { [weak self] result in
            switch result {
                case .success(let paymentRequestId):
                    self?.loadPDFData(paymentRequestId: paymentRequestId, viewController: viewController)
                case .failure:
                    break
            }
        }
    }

    /**
     Determines if the onboarding screen should be shown based on the presentation count for the selected payment provider.

     - Returns: A Boolean value indicating whether the onboarding screen should be displayed.
     */
    public func shouldShowOnboardingScreenFor() -> Bool {
        let onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        let count = onboardingCounts.presentationCount(forProvider: selectedPaymentProvider?.name)
        return count < Constants.numberOfTimesOnboardingShareScreenShouldAppear
    }

    /**
     Submits feedback for the specified document and its updated extractions. Method used to update the information extracted from a document.

     - Parameters:
       - document: The document for which feedback is being submitted.
       - updatedExtractions: The updated extractions related to the document.
       - completion: An optional closure to be executed upon completion, containing the result of the submission.
     */
    public func submitFeedback(for document: GiniHealthAPILibrary.Document, updatedExtractions: [GiniHealthAPILibrary.Extraction], completion: ((Result<Void, GiniHealthAPILibrary.GiniError>) -> Void)?) {
        let newDocument = Document(healthDocument: document)
        let extractions = updatedExtractions.map { Extraction(healthExtraction: $0) }
        giniSDK.documentService.submitFeedback(for: newDocument, with: [], and: ["payment": [extractions]]) { result in
            switch result {
            case .success(let result):
                completion?(.success(result))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion?(.failure(healthError))
            }
        }
    }

    /**
     Determines if the specified error should be handled internally by the SDK.

     - Parameter error: The Gini error to evaluate.
     - Returns: A Boolean value indicating whether the error should be handled internally.
     */
    public func shouldHandleErrorInternally(error: GiniHealthAPILibrary.GiniError) -> Bool {
        let healthError = GiniHealthError.apiError(GiniError.decorator(error))
        return giniSDK.delegate?.shouldHandleErrorInternally(error: healthError) == true
    }

    /**
     Retrieves a preview for the specified document and page number.

     - Parameters:
       - documentId: The ID of the document to preview.
       - pageNumber: The page number of the document to retrieve.
       - completion: A closure that gets called with the result containing either the preview data or an error.
     */
    public func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniHealthAPILibrary.GiniError>) -> Void) {
        giniSDK.documentService.preview(for: documentId, pageNumber: pageNumber) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        }
    }

    /**
     Opens the payment provider app using the specified request ID and universal link.

     - Parameters:
       - requestId: The ID of the payment request.
       - universalLink: The universal link to open the payment provider app.
     */
    public func openPaymentProviderApp(requestId: String, universalLink: String) {
        giniSDK.openPaymentProviderApp(requestID: requestId, universalLink: universalLink)
    }

    /**
     Tracks the event when the keyboard is closed on the payment review screen.

     This method informs the tracking delegate about the keyboard close event.
     */
    public func trackOnPaymentReviewCloseKeyboardClicked() {
        trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseKeyboardButtonClicked))
    }

    /**
     Tracks the event when the close button is clicked on the payment review screen.

     This method notifies the tracking delegate about the close button click event.
     */
    public func trackOnPaymentReviewCloseButtonClicked() {
        trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseButtonClicked))
    }

    /**
     Tracks the event when the bank button is clicked on the payment review screen.

     - Parameters:
       - providerName: The name of the payment provider associated with the button click.
     */
    public func trackOnPaymentReviewBankButtonClicked(providerName: String) {
        var event = TrackingEvent.init(type: PaymentReviewScreenEventType.onToTheBankButtonClicked)
        event.info = ["paymentProvider": providerName]
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
    }

    private func loadPDFData(paymentRequestId: String, viewController: UIViewController) {
        self.loadPDF(paymentRequestId: paymentRequestId, completion: { [weak self] pdfData in
            let pdfPath = self?.writePDFDataToFile(data: pdfData, fileName: paymentRequestId)

            guard let pdfPath else {
                GiniUtilites.Log("Couldn't retrieve pdf URL", event: .warning)
                return
            }

            self?.sharePDF(pdfURL: pdfPath, paymentRequestId: paymentRequestId, viewController: viewController) { [weak self] (activity, _, _, _) in
                guard activity != nil else {
                    return
                }

                // Publish the payment request id only after a user has picked an activity (app)
                self?.giniSDK.delegate?.didCreatePaymentRequest(paymentRequestId: paymentRequestId)
            }
        })
    }

    private func loadPDF(paymentRequestId: String, completion: @escaping (Data) -> ()) {
        isLoading = true
        giniSDK.paymentService.pdfWithQRCode(paymentRequestId: paymentRequestId) { [weak self] result in
            self?.isLoading = false
            switch result {
                case .success(let data):
                    completion(data)
                case .failure:
                    break
            }
        }
    }

    private func writePDFDataToFile(data: Data, fileName: String) -> URL? {
        do {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let docDirectoryPath = paths.first else { return  nil}
            let pdfFileName = fileName + Constants.pdfExtension
            let pdfPath = docDirectoryPath.appendingPathComponent(pdfFileName)
            try data.write(to: pdfPath)
            return pdfPath
        } catch {
            GiniUtilites.Log("Error while write pdf file to location: \(error.localizedDescription)", event: .error)
            return nil
        }
    }

    private func sharePDF(pdfURL: URL, paymentRequestId: String, viewController: UIViewController,
                          completionWithItemsHandler: @escaping UIActivityViewController.CompletionWithItemsHandler) {
        // Create UIActivityViewController with the PDF file
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = completionWithItemsHandler

        // Exclude some activities if needed
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .airDrop,
            .mail,
            .message,
            .postToFacebook,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTwitter,
            .postToTencentWeibo,
            .copyToPasteboard,
            .markupAsPDF,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]

        // Present the UIActivityViewController
        DispatchQueue.main.async {
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            if (viewController.presentedViewController != nil) {
                viewController.presentedViewController?.dismiss(animated: true, completion: {
                    viewController.present(activityViewController, animated: true, completion: nil)
                })
            } else {
                viewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    /**
     Updates the selected payment provider with the given payment provider. This method is used when updating the payment provider from Payment Review Screen

     - Parameters:
       - paymentProvider: The new payment provider to be set.
     */
    public func updatedPaymentProvider(_ paymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        self.selectedPaymentProvider = PaymentProvider(healthPaymentProvider: paymentProvider)
    }

    /**
     Opens the more information view controller by notifying the view delegate. This method is used when opening the More Information screen inside the bank selection bottom sheet that's presented in the Payment Review Screen.

     This method triggers the delegate's action for displaying more information.
     */
    public func openMoreInformationViewController() {
        viewDelegate?.didTapOnMoreInformation()
    }

    public func fetchBankLogos() -> (logos: [Data]?, additionalBankCount: Int?) {
        guard !paymentProviders.isEmpty else { return ([], nil)}
        let paymentProvidersShownCount = paymentProviders.count == 1 ? 1 : 2
        let additionalBankCount = paymentProviders.count > 2 ? paymentProviders.count - 2 : nil
        return (paymentProviders.prefix(paymentProvidersShownCount).map { $0.iconData }, additionalBankCount)
    }

    private func sortPaymentProviders() {
        guard !paymentProviders.isEmpty else { return }
        self.paymentProviders = paymentProviders
            .filter { $0.gpcSupportedPlatforms.contains(.ios) || $0.openWithSupportedPlatforms.contains(.ios) }
            .sorted(by: { ($0.index ?? 0 < $1.index ?? 0) })
            .sorted(by: { ( $0.appSchemeIOS.canOpenURLString() && !$1.appSchemeIOS.canOpenURLString() ) })
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
        static let pdfExtension = ".pdf"
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
