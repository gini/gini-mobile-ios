//
//  PaymentComponentController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniPaymentComponents
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

public protocol PaymentProvidersBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider)
    func didTapOnClose()
    func didTapOnMoreInformation()
    func didTapOnContinueOnShareBottomSheet()
    func didTapForwardOnInstallBottomSheet()
    func didTapOnPayButton()
}

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
    var defaultStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration { get }
    var errorStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration { get }
    var selectionStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration { get }

    var showPaymentReviewCloseButton: Bool { get }
    var paymentComponentButtonsHeight: CGFloat { get }
}

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

///**
// Delegate to inform about the actions happened of the custom payment component view.
// You may find out when the user tapped on more information area, on the payment provider picker or on the pay invoice button
//
// */
//public protocol PaymentComponentViewProtocol: AnyObject {
//    /**
//     Called when the user tapped on the more information actionable label or the information icon
//
//     - parameter documentId: Id of document
//     */
//    func didTapOnMoreInformation(documentId: String?)
//
//    /**
//     Called when the user tapped on payment provider picker to change the selected payment provider or install it
//
//     - parameter documentId: Id of document
//     */
//    func didTapOnBankPicker(documentId: String?)
//
//    /**
//     Called when the user tapped on the pay the invoice button to pay the invoice/document
//     - parameter documentId: Id of document
//     */
//    func didTapOnPayInvoice(documentId: String?)
//}

private enum PaymentComponentScreenType {
    case paymentComponent
    case bankPicker
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
                            let viewModel = PaymentReviewModel(delegateAPI: self,
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
                                                               poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                               poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                                               bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration,
                                                               showPaymentReviewCloseButton: configurationProvider.showPaymentReviewCloseButton)

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

//        let paymentReviewViewController = PaymentReviewViewController.instantiate(with: self.giniMerchant,
//                                                                                  data: nil,
//                                                                                  paymentInfo: paymentInfo,
//                                                                                  selectedPaymentProvider: selectedPaymentProvider,
//                                                                                  trackingDelegate: trackingDelegate,
//                                                                                  paymentComponentsController: self)

        let viewModel = PaymentReviewModel(delegateAPI: self,
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
                                           poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                           poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                           bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration,
                                           showPaymentReviewCloseButton: configurationProvider.showPaymentReviewCloseButton)

        let vc = PaymentReviewViewController.instantiate(viewModel: viewModel,
                                                         selectedPaymentProvider: healthSelectedPaymentProvider)
        completion(vc, nil)
    }

    // MARK: - Bottom Sheets

    public func paymentViewBottomSheet(documentID: String?) -> UIViewController {
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(documentId: documentID), bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        return paymentComponentBottomView
    }

    public func bankSelectionBottomSheet() -> UIViewController {
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

    public func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders, 
                                                        configuration: configurationProvider.paymentInfoConfiguration,
                                                        strings: stringsProvider.paymentInfoStrings,
                                                        poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                        poweredByGiniStrings: stringsProvider.poweredByGiniStrings)
        return PaymentInfoViewController(viewModel: paymentInfoViewModel)
    }

    public func installAppBottomSheet() -> BottomSheetViewController {
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

    public func shareInvoiceBottomSheet() -> BottomSheetViewController {
        let shareInvoiceBottomViewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                      configuration: configurationProvider.shareInvoiceConfiguration,
                                                                      strings: stringsProvider.shareInvoiceStrings,
                                                                      primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
                                                                      poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                      poweredByGiniStrings: stringsProvider.poweredByGiniStrings)
        shareInvoiceBottomViewModel.viewDelegate = self
        let shareInvoiceBottomView = ShareInvoiceBottomView(viewModel: shareInvoiceBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
        incrementOnboardingCountFor(paymentProvider: healthSelectedPaymentProvider)
        return shareInvoiceBottomView
    }

    // MARK: - Helping functions
    public func canOpenPaymentProviderApp() -> Bool {
        if supportsGPC() {
            if healthSelectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true {
                return true
            }
        }
        return false
    }

    public func supportsOpenWith() -> Bool {
        if healthSelectedPaymentProvider?.openWithSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    public func supportsGPC() -> Bool {
        if healthSelectedPaymentProvider?.gpcSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    public func obtainPDFURLFromPaymentRequest(paymentInfo: PaymentInfo, viewController: UIViewController) {
        createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] paymentRequestID, error in
            if let paymentRequestID {
                self?.loadPDFData(paymentRequestID: paymentRequestID, viewController: viewController)
            }
        })
    }

    public func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (_ paymentRequestID: String?, _ error: GiniMerchantError?) -> Void) {
        giniSDK.createPaymentRequest(paymentInfo: paymentInfo) { result in
            switch result {
            case let .success(requestId):
                completion(requestId, nil)
            case let .failure(error):
                completion(nil, GiniMerchantError.apiError(error))
            }
        }
    }

    public func shouldShowOnboardingScreenFor() -> Bool {
        let onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        let count = onboardingCounts.presentationCount(forProvider: selectedPaymentProvider?.name)
        return count < Constants.numberOfTimesOnboardingShareScreenShouldAppear
    }
}

extension PaymentComponentsController: GiniPaymentComponents.PaymentComponentViewProtocol {
    public func didTapOnMoreInformation(documentId: String?) {
        viewDelegate?.didTapOnMoreInformation(documentId: documentId)
    }
    
    public func didTapOnBankPicker(documentId: String?) {
        viewDelegate?.didTapOnBankPicker(documentId: documentId)
    }
    
    public func didTapOnPayInvoice(documentId: String?) {
        viewDelegate?.didTapOnPayInvoice(documentId: documentId)
    }
}

extension PaymentComponentsController {
    private func incrementOnboardingCountFor(paymentProvider: GiniHealthAPILibrary.PaymentProvider?) {
        var onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        onboardingCounts.incrementPresentationCount(forProvider: paymentProvider?.name)
    }

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

extension PaymentComponentsController: BanksBottomViewProtocol {
    public func didTapForwardOnInstallBottomSheet() {
        print("Tapped Forward on Install Bottom Sheet")
    }

    public func didTapOnContinueOnShareBottomSheet() {
        print("Tapped Continue on Share Bottom Sheet")
    }

    public func didTapOnPayButton() {
        bottomViewDelegate?.didTapOnPayButton()
    }
    
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }

    public func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation(documentId: nil)
    }

    public func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        selectedPaymentProvider = PaymentProvider(healthPaymentProvider: paymentProvider)
        if let provider = selectedPaymentProvider {
            storeDefaultPaymentProvider(paymentProvider: provider)
            bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: provider)
        }
    }
}

extension PaymentComponentsController: ShareInvoiceBottomViewProtocol {
    public func didTapOnContinueToShareInvoice() {
        bottomViewDelegate?.didTapOnContinueOnShareBottomSheet()
    }
}

extension PaymentComponentsController: InstallAppBottomViewProtocol {
    public func didTapOnContinue() {
        bottomViewDelegate?.didTapForwardOnInstallBottomSheet()
    }
}

extension PaymentComponentsController: PaymentReviewAPIProtocol {
    public func submitFeedback(for document: GiniHealthAPILibrary.Document, updatedExtractions: [GiniHealthAPILibrary.Extraction], completion: @escaping (Result<Void, GiniHealthAPILibrary.GiniError>) -> Void) {
        let newDocument = Document(healthDocument: document)
        let extractions = updatedExtractions.map { Extraction(healthExtraction: $0) }
        giniSDK.documentService.submitFeedback(for: newDocument, with: [], and: ["payment": [extractions]]) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                let healthError = GiniHealthAPILibrary.GiniError.unknown(response: error.response, data: error.data)
                completion(.failure(healthError))
            }
        }
    }
    
    public func createPaymentRequest(paymentInfo: GiniPaymentComponents.PaymentInfo, completion: @escaping (Result<String, GiniHealthAPILibrary.GiniError>) -> Void) {
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
    
    public func shouldHandleErrorInternally(error: GiniHealthAPILibrary.GiniError) -> Bool {
        let merchantError = GiniMerchantError.apiError(GiniError.decorator(error))
        return giniSDK.delegate?.shouldHandleErrorInternally(error: merchantError) == true
    }

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
    
    public func openPaymentProviderApp(requestID: String, universalLink: String) {
        giniSDK.openPaymentProviderApp(requestID: requestID, universalLink: universalLink)
    }

    public func trackOnPaymentReviewCloseKeyboardClicked() {
        trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseKeyboardButtonClicked))
    }

    public func trackOnPaymentReviewCloseButtonClicked() {
        trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseButtonClicked))
    }

    public func trackOnPaymentReviewBankButtonClicked(providerName: String) {
        var event = TrackingEvent.init(type: PaymentReviewScreenEventType.onToTheBankButtonClicked)
        event.info = ["paymentProvider": providerName]
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
        static let pdfExtension = ".pdf"
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
