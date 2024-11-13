//
//  PaymentComponentsController+Helpers.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniHealthAPILibrary
import GiniInternalPaymentSDK
import GiniUtilites
import UIKit

/// A protocol for handling user actions in the Payment Providers bottom views.
protocol PaymentProvidersBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider)
    func didTapOnClose()
    func didTapOnMoreInformation()
    func didTapOnContinueOnShareBottomSheet()
    func didTapForwardOnInstallBottomSheet()
    func didTapOnPayButton()
}

extension PaymentComponentsController {
    
    // MARK: - Payment Provider Selection
    
    /**
     Loads the payment providers list and stores them.
     - note: Also triggers a function that checks if the payment providers are installed.
     */
    func loadPaymentProviders() {
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
    
    /**
     Retrieves the default installed payment provider, if available.
     - Returns: a Payment Provider object.
     */
    func defaultInstalledPaymentProvider() -> PaymentProvider? {
        savedPaymentProvider()
    }
    
    func storeDefaultPaymentProvider(paymentProvider: PaymentProvider) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(paymentProvider)
            UserDefaults.standard.set(data, forKey: Constants.kDefaultPaymentProvider)
        } catch {
            GiniUtilites.Log("Unable to encode payment provider: (\(error))", event: .error)
        }
    }
    
    func savedPaymentProvider() -> PaymentProvider? {
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
    
    func sortPaymentProviders() {
        guard !paymentProviders.isEmpty else { return }
        self.paymentProviders = paymentProviders
            .filter { $0.gpcSupportedPlatforms.contains(.ios) || $0.openWithSupportedPlatforms.contains(.ios) }
            .sorted {
                // First sort by whether the app scheme can be opened
                if $0.appSchemeIOS.canOpenURLString() != $1.appSchemeIOS.canOpenURLString() {
                    return $0.appSchemeIOS.canOpenURLString() && !$1.appSchemeIOS.canOpenURLString()
                }
                // Then sort by the index if the app scheme condition is the same
                return ($0.index ?? 0) < ($1.index ?? 0)
            }
    }
    
    
    // MARK: - Bottom sheets
    
    /**
     Provides a custom Gini for the payment view that is going to be presented as a bottom sheet.

     - Parameter documentId: An optional identifier for the document associated with the payment.
     - Returns: A configured `UIViewController` for displaying the payment bottom view.
     */
    public func paymentViewBottomSheet(documentId: String?) -> UIViewController {
        previousPresentedView = .paymentComponent
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(), bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return paymentComponentBottomView
    }
    
    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
     - Returns: a custom view
     */
    func paymentView() -> UIView {
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
    
    func presentPaymentViewBottomSheet() {
        let paymentViewBottomSheet = paymentViewBottomSheet(documentId: documentId ?? "")
        paymentViewBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: paymentViewBottomSheet, animated: false)
    }
    
    private func dismissAndPresent(viewController: UIViewController, animated: Bool) {
        if let presentedViewController = navigationControllerProvided?.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                self.navigationControllerProvided?.present(viewController, animated: animated)
            }
        } else {
            navigationControllerProvided?.present(viewController, animated: animated)
        }
    }
    
    /**
     Provides a custom Gini view for the bank selection bottom sheet.

     - Parameter documentId: An optional identifier for the document associated with the bank selection.
     - Returns: A configured `UIViewController` for displaying the bank selection options.
     */
    public func bankSelectionBottomSheet() -> UIViewController {
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
    func loadPaymentReviewScreenFor(trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
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
    
    private func loadPaymentReviewScreenWithoutDocument(paymentInfo: GiniInternalPaymentSDK.PaymentInfo?, trackingDelegate: GiniHealthTrackingDelegate?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
        previousPresentedView = nil
        preparePaymentReviewViewController(data: nil, paymentInfo: paymentInfo, completion: completion)
    }

    private func preparePaymentReviewViewController(data: DataForReview?, paymentInfo: GiniInternalPaymentSDK.PaymentInfo?, completion: @escaping (UIViewController?, GiniHealthError?) -> Void) {
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
    func paymentInfoViewController() -> UIViewController {
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
    public func shareInvoiceBottomSheet() -> BottomSheetViewController {
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
        incrementOnboardingCountFor(paymentProvider: selectedPaymentProvider)
        return shareInvoiceBottomView
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
        didTapOnMoreInformation(documentId: documentId)
    }
    
    // MARK: - Other helpers

    private func incrementOnboardingCountFor(paymentProvider: PaymentProvider?) {
        var onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        onboardingCounts.incrementPresentationCount(forProvider: paymentProvider?.name)
    }

    func setupObservers() {
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
    public func obtainPDFURLFromPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo, viewController: UIViewController) {
        createPaymentRequest(paymentInfo: paymentInfo) { [weak self] result in
            switch result {
                case .success(let paymentRequestId):
                    self?.loadPDFData(paymentRequestId: paymentRequestId, viewController: viewController)
                case .failure:
                    break
            }
        }
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
     Determines if the onboarding screen should be shown based on the presentation count for the selected payment provider.

     - Returns: A Boolean value indicating whether the onboarding screen should be displayed.
     */
    public func shouldShowOnboardingScreenFor() -> Bool {
        let onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        let count = onboardingCounts.presentationCount(forProvider: selectedPaymentProvider?.name)
        return count < Constants.numberOfTimesOnboardingShareScreenShouldAppear
    }

    // MARK: - Payment Review Screen functions
    
    /**
     Creates a payment request using the provided payment information.

     - Parameter paymentInfo: The payment information to be used for the request.
     - Parameter completion: A closure to be executed once the request is completed, containing the result of the operation.
     */
    public func createPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo, completion: @escaping (Result<String, GiniHealthAPILibrary.GiniError>) -> Void) {
        giniSDK.createPaymentRequest(paymentInfo: paymentInfo, completion: { result in
            switch result {
            case .success(let paymentRequestId):
                completion(.success(paymentRequestId))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        })
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
        Retrieves a payment request using the provided payment request ID.

        - Parameter id:         The ID of the payment request to retrieve.
        - Parameter completion: A closure to be executed once the retrieval is completed, containing the result of the operation as a `PaymentRequest` object on success or a `GiniError` on failure.
    */
    public func getPaymentRequest(by id: String, completion: @escaping (Result<PaymentRequest, GiniHealthAPILibrary.GiniError>) -> Void) {
        giniSDK.getPaymentRequest(by: id) { result in
            switch result {
            case .success(let paymentRequest):
                completion(.success(paymentRequest))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        }
    }
}

extension PaymentComponentsController: BanksSelectionProtocol {
    /// Updates the selected payment provider and notifies the delegate with the provider and optional document ID.
    public func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        selectedPaymentProvider = PaymentProvider(healthPaymentProvider: paymentProvider)
        if let provider = selectedPaymentProvider {
            storeDefaultPaymentProvider(paymentProvider: provider)
            self.presentPaymentViewBottomSheet()
        }
    }

    /// Handles the action when the continue button is tapped on the share bottom sheet.
    public func didTapOnContinueOnShareBottomSheet() {
        GiniUtilites.Log("Tapped Continue on Share Bottom Sheet", event: .success)
    }

    /// Handles the action when the forward button is tapped on the install bottom sheet.
    public func didTapForwardOnInstallBottomSheet() {
        GiniUtilites.Log("Tapped Forward on Install Bottom Sheet", event: .success)
    }

    /// Handles the action when the pay button is tapped on install bottom sheet.
    public func didTapOnPayButton() {
        //
    }
}

extension PaymentComponentsController: PaymentComponentViewProtocol {
    /// Handles the action when the more information button is tapped on the payment component view, using the provided document ID.
    public func didTapOnMoreInformation(documentId: String?) {
        let paymentInfoVC = paymentInfoViewController()
        pushOrDismissAndPush(paymentInfoVC)
    }
    
    private func pushOrDismissAndPush(_ viewController: UIViewController) {
        if let presentedVC = navigationControllerProvided?.presentedViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.navigationControllerProvided?.pushViewController(viewController, animated: true)
            }
        } else {
            navigationControllerProvided?.pushViewController(viewController, animated: true)
        }
    }
    
    /// Handles the action when the bank picker button is tapped on the payment component view, using the provided document ID.
    public func didTapOnBankPicker(documentId: String?) {
        GiniUtilites.Log("Tapped on Bank Picker on :\(documentId ?? "")", event: .success)
        if GiniHealthConfiguration.shared.useBottomPaymentComponentView {
            let bankSelectionBottomSheet = bankSelectionBottomSheet()
            bankSelectionBottomSheet.modalPresentationStyle = .overFullScreen
            dismissAndPresent(viewController: bankSelectionBottomSheet, animated: false)
        }
    }
    
    /// Handles the action when the pay invoice button is tapped on the payment component view, using the provided document ID.
    public func didTapOnPayInvoice(documentId: String?) {
        GiniUtilites.Log("Tapped on Pay Invoice on :\(documentId ?? "")", event: .success)
        if GiniHealthConfiguration.shared.showPaymentReviewScreen {
            loadPaymentReviewScreenFor(trackingDelegate: self) { [weak self] viewController, error in
                if let error = error {
                    self?.errors.append(error.localizedDescription)
                    self?.showErrorsIfAny()
                } else if let viewController = viewController {
                    self?.presentOrPushPaymentReviewScreen(viewController)
                }
            }
        } else {
            if supportsOpenWith() {
                if shouldShowOnboardingScreenFor() {
                    presentShareInvoiceBottomSheet(documentId: documentId)
                } else {
                    guard let paymentInfo else { return }
                    handleDismissalAndPDFURL(paymentInfo: paymentInfo)
                }
            } else if supportsGPC() {
                if canOpenPaymentProviderApp() {
                    guard let paymentInfo else { return }
                    processPaymentRequest(paymentInfo: paymentInfo)
                } else {
                    presentInstallAppBottomSheet()
                }
            }
        }
    }
    
    private func presentOrPushPaymentReviewScreen(_ viewController: UIViewController) {
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .overCurrentContext
        
        let presentOrPush: () -> Void = { [weak self] in
            guard let self = self else { return }
            if self.documentId != nil {
                self.navigationControllerProvided?.pushViewController(viewController, animated: true)
            } else {
                self.navigationControllerProvided?.present(viewController, animated: true)
            }
        }
        
        if let presentedVC = navigationControllerProvided?.presentedViewController {
            presentedVC.dismiss(animated: true, completion: presentOrPush)
        } else {
            presentOrPush()
        }
    }
    
    private func presentShareInvoiceBottomSheet(documentId: String?) {
        let shareInvoiceBottomSheet = shareInvoiceBottomSheet()
        shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: shareInvoiceBottomSheet, animated: false)
    }
    
    private func handleDismissalAndPDFURL(paymentInfo: GiniInternalPaymentSDK.PaymentInfo) {
        if let presentedVC = self.navigationControllerProvided?.presentedViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                guard let self = self, let navController = self.navigationControllerProvided else { return }
                self.obtainPDFURLFromPaymentRequest(paymentInfo: paymentInfo, viewController: navController)
            }
        } else {
            guard let presentedVC = self.navigationControllerProvided?.presentedViewController else { return }
            self.obtainPDFURLFromPaymentRequest(paymentInfo: paymentInfo, viewController: presentedVC)
        }
    }
    
    private func processPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo) {
        createPaymentRequest(paymentInfo: paymentInfo) { [weak self] result in
            switch result {
            case .success(let paymentRequestID):
                self?.handleSuccessfulPaymentRequest(paymentRequestID: paymentRequestID)
            case .failure(let error):
                self?.errors.append(error.localizedDescription)
                self?.showErrorsIfAny()
            }
        }
    }

    private func handleSuccessfulPaymentRequest(paymentRequestID: String) {
        if let presentedVC = navigationControllerProvided?.presentedViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.openPaymentProviderApp(requestId: paymentRequestID)
            }
        } else {
            openPaymentProviderApp(requestId: paymentRequestID)
        }
    }

    private func openPaymentProviderApp(requestId: String) {
        let universalLink = selectedPaymentProvider?.universalLinkIOS ?? ""
        openPaymentProviderApp(requestId: requestId, universalLink: universalLink)
    }

    private func presentInstallAppBottomSheet() {
        let installAppBottomSheet = installAppBottomSheet()
        installAppBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: installAppBottomSheet, animated: false)
    }
    
    private func showErrorsIfAny() {
        if !errors.isEmpty {
            let uniqueErrorMessages = Array(Set(errors))
            DispatchQueue.main.async {
                self.delegate?.isLoadingStateChanged(isLoading: false)
                self.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
            }
            errors = []
        }
    }
    
    func showErrorAlertView(error: String) {
        if navigationControllerProvided?.presentedViewController != nil {
            self.navigationControllerProvided?.presentedViewController?.dismiss(animated: true, completion: {
                self.presentAlerViewController(error: error)
            })
        } else {
            presentAlerViewController(error: error)
        }
    }

    private func presentAlerViewController(error: String) {
        let alertController = UIAlertController(title: "Error test",
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.navigationControllerProvided?.present(alertController, animated: true)
    }
}

extension PaymentComponentsController: PaymentProvidersBottomViewProtocol {
    /// Updates the selected payment provider from the bank selection bottom view and notifies the delegate with the selected provider and document ID.
    public func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        selectedPaymentProvider = paymentProvider
        storeDefaultPaymentProvider(paymentProvider: paymentProvider)
    }
    
    /// Notifies the delegate when the close button is tapped on bank selection bottom view
    public func didTapOnClose() {
//        didTapOnClose()
    }
    
    /// Notifies the delegate when the more information button is tapped on the bank selection bottom view
    public func didTapOnMoreInformation() {
//        didTapOnMoreInformation()
    }
}



extension PaymentComponentsController: ShareInvoiceBottomViewProtocol {
    /// Notifies the delegate to continue sharing the invoice with the provided document ID.
    public func didTapOnContinueToShareInvoice() {
        guard let navigationControllerProvided, let paymentInfo else { return }
        obtainPDFURLFromPaymentRequest(paymentInfo: paymentInfo, viewController: navigationControllerProvided)
    }
}

extension PaymentComponentsController: InstallAppBottomViewProtocol {
    // Notifies the delegate to proceed when the continue button is tapped in the install app bottom view. This happens after the user installed the app from AppStore
    public func didTapOnContinue() {
        didTapForwardOnInstallBottomSheet()
    }
}
