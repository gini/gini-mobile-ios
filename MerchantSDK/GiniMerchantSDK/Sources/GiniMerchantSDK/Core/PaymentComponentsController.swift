//
//  PaymentComponentController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniInternalPaymentSDK
import GiniHealthAPILibrary
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
    func didSelectPaymentProvider(paymentProvider: PaymentProvider)
    func didTapOnClose()
    func didTapOnMoreInformation()
    func didTapOnContinueOnShareBottomSheet(paymentRequestId: String)
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
    func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniMerchantError>) -> Void)
    func paymentView(documentId: String?) -> UIView
    func bankSelectionBottomSheet() -> UIViewController
    func loadPaymentReviewScreenFor(documentID: String?, paymentInfo: PaymentInfo?, trackingDelegate: GiniMerchantTrackingDelegate?, completion: @escaping (UIViewController?, GiniMerchantError?) -> Void)
    func paymentInfoViewController() -> UIViewController
    func paymentViewBottomSheet(documentID: String?) -> UIViewController
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

    private let giniSDK: GiniMerchant
    private var trackingDelegate: GiniMerchantTrackingDelegate?

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
        - giniMerchant: An instance of GiniMerchant initialized with GiniHealthAPI.
     - Returns:
        - instance of the payment component controller class
     */
    public init(giniMerchant: GiniMerchant & PaymentComponentsConfigurationProvider & PaymentComponentsStringsProvider) {
        self.giniSDK = giniMerchant
        self.configurationProvider = giniMerchant
        self.stringsProvider = giniMerchant
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
                self?.selectedPaymentProvider = self?.defaultInstalledPaymentProvider()
                self?.delegate?.didFetchedPaymentProviders()
            case let .failure(error):
                print("Couldn't load payment providers: \(error.localizedDescription)")
            }
        }
    }
    
    private func storeDefaultPaymentProvider(paymentProvider: PaymentProvider) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(paymentProvider)
            UserDefaults.standard.set(data, forKey: Constants.kDefaultPaymentProvider)
        } catch {
            print("Unable to encode payment provider: (\(error))")
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
                print("Unable to decode payment provider: (\(error))")
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
    public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniMerchantError>) -> Void) {
        giniSDK.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
     - Returns: a custom view
     */
    public func paymentView(documentId: String?) -> UIView {
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
    public func loadPaymentReviewScreenFor(documentID: String?, paymentInfo: PaymentInfo?, trackingDelegate: GiniMerchantTrackingDelegate?, completion: @escaping (UIViewController?, GiniMerchantError?) -> Void) {
            previousPresentedView = nil
            if !GiniMerchantConfiguration.shared.useInvoiceWithoutDocument {
                guard let documentID else {
                    completion(nil, nil)
                    return
                }
                self.isLoading = true
                self.giniSDK.fetchDataForReview(documentId: documentID) { [weak self] result in
                    self?.isLoading = false
                    switch result {
                        case .success(let data):
                            guard let self else {
                                completion(nil, nil)
                                return
                            }
                            guard let healthSelectedPaymentProvider else {
                                completion(nil, nil)
                                return
                            }
                            let viewModel = PaymentReviewModel(delegate: self,
                                                               bottomSheetsProvider: self,
                                                               document: data.document.toHealthDocument(),
                                                               extractions: data.extractions.map { $0.toHealthExtraction() },
                                                               paymentInfo: nil,
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
                                                               showPaymentReviewCloseButton: configurationProvider.showPaymentReviewCloseButton,
                                                               previousPaymentComponentScreenType: nil)

                            let vc = PaymentReviewViewController.instantiate(viewModel: viewModel,
                                                                             selectedPaymentProvider: healthSelectedPaymentProvider)
                            completion(vc, nil)
                        case .failure(let error):
                            completion(nil, error)
                    }
                }
            } else {
                loadPaymentReviewScreenWithoutDocument(paymentInfo: paymentInfo, trackingDelegate: trackingDelegate, completion: completion)
            }
        }

    private func loadPaymentReviewScreenWithoutDocument(paymentInfo: PaymentInfo?, trackingDelegate: GiniMerchantTrackingDelegate?, completion: @escaping (UIViewController?, GiniMerchantError?) -> Void) {
        previousPresentedView = nil
        guard let healthSelectedPaymentProvider else {
            completion(nil, nil)
            return
        }

        let viewModel = PaymentReviewModel(delegate: self,
                                           bottomSheetsProvider: self,
                                           document: nil,
                                           extractions: nil,
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
                                           showPaymentReviewCloseButton: configurationProvider.showPaymentReviewCloseButton,
                                           previousPaymentComponentScreenType: nil)

        let vc = PaymentReviewViewController.instantiate(viewModel: viewModel,
                                                         selectedPaymentProvider: healthSelectedPaymentProvider)
        completion(vc, nil)
    }

    // MARK: - Bottom Sheets

    /**
     Provides a custom Gini for view the payment view that is going to be presented as a bottom sheet.

     - Parameter documentId: An optional identifier for the document associated id with the payment.
     - Returns: A configured `UIViewController` for displaying the payment bottom view.
     */
    public func paymentViewBottomSheet(documentID: String?) -> UIViewController {
        previousPresentedView = .paymentComponent
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(documentId: documentID), bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return paymentComponentBottomView
    }

    /**
     Provides a custom Gini view for the bank selection bottom sheet.

     - Parameter documentId: An optional identifier for the document associated id with the bank selection.
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
        return BanksBottomView(viewModel: paymentProvidersBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
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

     - Parameter qrCodeData: QR Data shown in the Share Invoice Bottom Sheet
     - Parameter paymentRequestId: Payment request id generated from the payment info extracted from the order
     - Returns: A configured `BottomSheetViewController` for sharing invoices.
     */
    public func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> BottomSheetViewController {
        previousPresentedView = nil
        let shareInvoiceBottomViewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                      configuration: configurationProvider.shareInvoiceConfiguration,
                                                                      strings: stringsProvider.shareInvoiceStrings,
                                                                      primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
                                                                      poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                      poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                                                      qrCodeData: qrCodeData,
                                                                      paymentInfo: nil,
                                                                      paymentRequestId: paymentRequestId)
        shareInvoiceBottomViewModel.viewDelegate = self
        let shareInvoiceBottomView = ShareInvoiceBottomView(viewModel: shareInvoiceBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return shareInvoiceBottomView
    }

    /**
     Provides a custom Gini view for the bank selection bottom sheet.

     - Parameter documentId: An optional identifier for the document associated id with the bank selection.
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
        healthSelectedPaymentProvider?.openWithSupportedPlatforms.contains(.ios) == true
    }

    /// Checks if the selected payment provider supports GPC(Gini Pay Connect) on iOS.
    public func supportsGPC() -> Bool {
        healthSelectedPaymentProvider?.gpcSupportedPlatforms.contains(.ios) == true
    }

    /**
     Creates a payment request and obtains the PDF URL using the provided payment information.

     - Parameter viewController: The view controller used to present any necessary UI related to the request.
     - Parameter paymentRequestId: The paymentRequestId generated from the payment info extracted from the order
     */
    public func obtainPDFURLFromPaymentRequest(viewController: UIViewController, paymentRequestId: String) {
        self.loadPDFData(paymentRequestID: paymentRequestId, viewController: viewController)
    }

    /**
     Creates a payment request with the provided payment information.

     - Parameters:
       - paymentInfo: The information needed to create the payment request.
       - completion: A closure that is called with the payment request ID or an error.
     */
    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (_ paymentRequestID: String?, _ error: GiniMerchantError?) -> Void) {
        giniSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            switch result {
            case let .success(requestId):
                completion(requestId, nil)
                self?.didCreatePaymentRequest(paymentRequestId: requestId)
            case let .failure(error):
                completion(nil, GiniMerchantError.apiError(error))
            }
        }
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

extension PaymentComponentsController {
    private func loadPDFData(paymentRequestID: String, viewController: UIViewController) {
        self.loadPDF(paymentRequestID: paymentRequestID, completion: { [weak self] pdfData in
            let pdfPath = self?.writePDFDataToFile(data: pdfData, fileName: paymentRequestID)

            guard let pdfPath else {
                print("Couldn't retrieve pdf URL")
                return
            }

            self?.sharePDF(pdfURL: pdfPath, paymentRequestID: paymentRequestID, viewController: viewController) { [weak self] (activity, _, _, _) in
                guard activity != nil else {
                    return
                }

                // Publish the payment request id only after a user has picked an activity (app)
                self?.giniSDK.delegate?.didCreatePaymentRequest(paymentRequestID: paymentRequestID)
            }
        })
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
            print("Error while write pdf file to location: \(error.localizedDescription)")
            return nil
        }
    }

    private func sharePDF(pdfURL: URL, paymentRequestID: String, viewController: UIViewController,
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

    private func loadPDF(paymentRequestID: String, completion: @escaping (Data) -> ()) {
        isLoading = true
        giniSDK.paymentService.pdfWithQRCode(paymentRequestId: paymentRequestID) { [weak self] result in
            self?.isLoading = false
            switch result {
                case .success(let data):
                    completion(data)
                case .failure:
                    break
            }
        }
    }
}

extension PaymentComponentsController: BanksSelectionProtocol {
    /// Handles the action when the forward button is tapped on the install bottom sheet.
    public func didTapForwardOnInstallBottomSheet() {
        print("Tapped Forward on Install Bottom Sheet")
    }

    /// Handles the action when the continue button is tapped on the share bottom sheet.
    public func didTapOnContinueOnShareBottomSheet() {
        print("Tapped Continue on Share Bottom Sheet")
    }

    /// Handles the action when the pay button is tapped on install bottom sheet.
    public func didTapOnPayButton() {
        bottomViewDelegate?.didTapOnPayButton()
    }
    
    /// Notifies the delegate when the close button is tapped on bank selection bottom view
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }

    /// Notifies the delegate when the more information button is tapped on the bank selection bottom view
    public func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation(documentId: nil)
    }

    /// Updates the selected payment provider from the bank selection bottom view and notifies the delegate with the selected provider and document ID.
    public func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        selectedPaymentProvider = PaymentProvider(healthPaymentProvider: paymentProvider)
        if let provider = selectedPaymentProvider {
            storeDefaultPaymentProvider(paymentProvider: provider)
            bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: provider)
        }
    }
}

extension PaymentComponentsController: ShareInvoiceBottomViewProtocol {
    /// Notifies the delegate to continue sharing the invoice with the provided document ID.
    public func didTapOnContinueToShareInvoice(paymentRequestId: String) {
        bottomViewDelegate?.didTapOnContinueOnShareBottomSheet(paymentRequestId: paymentRequestId)
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
     Called when the payment request was successfully created

     - parameter paymentRequestId: Id of created payment request.
     */
    public func didCreatePaymentRequest(paymentRequestId: String) {
        giniSDK.delegate?.didCreatePaymentRequest(paymentRequestID: paymentRequestId)
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
     Creates a payment request using the provided payment information.

     - Parameter paymentInfo: The payment information to be used for the request.
     - Parameter completion: A closure to be executed once the request is completed, containing the result of the operation.
     */
    public func createPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo, completion: @escaping (Result<String, GiniHealthAPILibrary.GiniError>) -> Void) {
        let info = PaymentInfo(paymentConponentsInfo: paymentInfo)
        giniSDK.createPaymentRequest(paymentInfo: info, completion: { result in
            switch result {
                case .success(let paymentRequestID):
                    completion(.success(paymentRequestID))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        })
    }
    
    /**
     Determines if the specified error should be handled internally by the SDK.

     - Parameter error: The Gini error to evaluate.
     - Returns: A Boolean value indicating whether the error should be handled internally.
     */
    public func shouldHandleErrorInternally(error: GiniHealthAPILibrary.GiniError) -> Bool {
        let merchantError = GiniMerchantError.apiError(GiniError.decorator(error))
        return giniSDK.delegate?.shouldHandleErrorInternally(error: merchantError) == true
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
    
    public func presentShareInvoiceBottomSheet(paymentRequestId: String, paymentInfo: GiniInternalPaymentSDK.PaymentInfo) {}
    
    public func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?) {
        // TODO: This method is going to be handled later in GiniMerchantSDK 
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
        static let pdfExtension = ".pdf"
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
