//
//  PaymentComponentController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
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

private enum PaymentComponentScreenType {
    case paymentComponent
    case bankPicker
}

/**
 The `PaymentComponentsController` class allows control over the payment components.
 */
public final class PaymentComponentsController: PaymentComponentsProtocol {
    /// handling the Payment Component Controller delegate
    public weak var delegate: PaymentComponentsControllerProtocol?
    /// handling the Payment Component view delegate
    public weak var viewDelegate: PaymentComponentViewProtocol?
    /// handling the Payment Bottom view delegate
    public weak var bottomViewDelegate: PaymentProvidersBottomViewProtocol?

    private var giniMerchant: GiniMerchant
    private let giniMerchantConfiguration = GiniMerchantConfiguration.shared
    private var paymentProviders: PaymentProviders = []
    
    /// storing the current selected payment provider
    public var selectedPaymentProvider: PaymentProvider?

    /// Payment Component View Configuration
    public var paymentComponentConfiguration: PaymentComponentConfiguration?

    /// Previous presented view
    private var previousPresentedView: PaymentComponentScreenType?

    /// reponsible for storing the loading state of the controller and passing it to the delegate listeners
    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }
    
    var paymentComponentView: PaymentComponentView!

    /**
     Initializer of the Payment Component Controller class.

     - Parameters:
        - giniMerchant: An instance of GiniMerchant initialized with GiniHealthAPI.
     - Returns:
        - instance of the payment component controller class
     */
    public init(giniMerchant: GiniMerchant) {
        self.giniMerchant = giniMerchant
        giniMerchantConfiguration.useInvoiceWithoutDocument = true
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
        self.giniMerchant.fetchBankingApps { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(paymentProviders):
                self?.paymentProviders = paymentProviders
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
        giniMerchant.checkIfDocumentIsPayable(docId: docId, completion: completion)
    }

    /**
     Provides a custom Gini view that contains more information, bank selection if available and a tappable button to pay the document/invoice

     - Parameters:
     - Returns: a custom view
     */
    public func paymentView(documentId: String?) -> UIView {
        paymentComponentView = PaymentComponentView()
        let paymentComponentViewModel = PaymentComponentViewModel(paymentProvider: selectedPaymentProvider, giniMerchantConfiguration: giniMerchantConfiguration, paymentComponentConfiguration: paymentComponentConfiguration)
        paymentComponentViewModel.delegate = viewDelegate
        paymentComponentViewModel.documentId = documentId
        paymentComponentView.viewModel = paymentComponentViewModel
        return paymentComponentView
    }

    public func loadPaymentReviewScreenFor(documentID: String?, paymentInfo: PaymentInfo?, trackingDelegate: GiniMerchantTrackingDelegate?, completion: @escaping (UIViewController?, GiniMerchantError?) -> Void) {
        previousPresentedView = nil
        if !giniMerchantConfiguration.useInvoiceWithoutDocument {
            guard let documentID else {
                completion(nil, nil)
                return
            }
            self.isLoading = true
            self.giniMerchant.fetchDataForReview(documentId: documentID) { [weak self] result in
                self?.isLoading = false
                switch result {
                    case .success(let data):
                        guard let self else {
                            completion(nil, nil)
                            return
                        }
                        guard let selectedPaymentProvider else {
                            completion(nil, nil)
                            return
                        }
                        let vc = PaymentReviewViewController.instantiate(with: self.giniMerchant,
                                                                         data: data,
                                                                         paymentInfo: nil,
                                                                         selectedPaymentProvider: selectedPaymentProvider,
                                                                         trackingDelegate: trackingDelegate,
                                                                         paymentComponentsController: self)
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
        guard let selectedPaymentProvider else {
            completion(nil, nil)
            return
        }

        let paymentReviewViewController = PaymentReviewViewController.instantiate(with: self.giniMerchant,
                                                                                  data: nil,
                                                                                  paymentInfo: paymentInfo,
                                                                                  selectedPaymentProvider: selectedPaymentProvider,
                                                                                  trackingDelegate: trackingDelegate,
                                                                                  paymentComponentsController: self)
        completion(paymentReviewViewController, nil)
    }

    // MARK: - Bottom Sheets

    public func paymentViewBottomSheet(documentID: String?) -> UIViewController {
        previousPresentedView = .paymentComponent
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(documentId: documentID))
        return paymentComponentBottomView
    }

    public func bankSelectionBottomSheet() -> UIViewController {
        previousPresentedView = .bankPicker
        let paymentProvidersBottomViewModel = BanksBottomViewModel(paymentProviders: paymentProviders,
                                                                   selectedPaymentProvider: selectedPaymentProvider)
        let paymentProvidersBottomView = BanksBottomView(viewModel: paymentProvidersBottomViewModel)
        paymentProvidersBottomViewModel.viewDelegate = self
        paymentProvidersBottomView.viewModel = paymentProvidersBottomViewModel
        return paymentProvidersBottomView
    }

    public func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewController = PaymentInfoViewController()
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders)
        paymentInfoViewController.viewModel = paymentInfoViewModel
        return paymentInfoViewController
    }

    public func installAppBottomSheet() -> UIViewController {
        previousPresentedView = nil
        let installAppBottomViewModel = InstallAppBottomViewModel(selectedPaymentProvider: selectedPaymentProvider)
        installAppBottomViewModel.viewDelegate = self
        let installAppBottomView = InstallAppBottomView(viewModel: installAppBottomViewModel)
        return installAppBottomView
    }

    public func shareInvoiceBottomSheet() -> UIViewController {
        previousPresentedView = nil
        let shareInvoiceBottomViewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: selectedPaymentProvider)
        shareInvoiceBottomViewModel.viewDelegate = self
        let shareInvoiceBottomView = ShareInvoiceBottomView(viewModel: shareInvoiceBottomViewModel)
        incrementOnboardingCountFor(paymentProvider: selectedPaymentProvider)
        return shareInvoiceBottomView
    }

    // MARK: - Helping functions
    public func canOpenPaymentProviderApp() -> Bool {
        if supportsGPC() {
            if selectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true {
                return true
            }
        }
        return false
    }

    public func supportsOpenWith() -> Bool {
        if selectedPaymentProvider?.openWithSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    public func supportsGPC() -> Bool {
        if selectedPaymentProvider?.gpcSupportedPlatforms.contains(.ios) == true {
            return true
        }
        return false
    }

    public func obtainPDFURLFromPaymentRequest(paymentInfo: PaymentInfo, viewController: UIViewController) {
        createPaymentRequest(paymentInfo: paymentInfo, notifyDelegate: false, completion: { [weak self] paymentRequestID, error in
            if let paymentRequestID {
                self?.loadPDFData(paymentRequestID: paymentRequestID, viewController: viewController)
            }
        })
    }

    public func createPaymentRequest(paymentInfo: PaymentInfo, notifyDelegate: Bool = true, completion: @escaping (_ paymentRequestID: String?, _ error: GiniMerchantError?) -> Void) {
        giniMerchant.createPaymentRequest(paymentInfo: paymentInfo, notifyDelegate: notifyDelegate) { result in
            switch result {
            case let .success(requestId):
                completion(requestId, nil)
            case let .failure(error):
                completion(nil, GiniMerchantError.apiError(error))
            }
        }
    }

    public func openPaymentProviderApp(requestId: String, universalLink: String) {
        giniMerchant.openPaymentProviderApp(requestID: requestId, universalLink: universalLink)
    }

    public func shouldShowOnboardingScreenFor() -> Bool {
        let onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        let count = onboardingCounts.presentationCount(forProvider: selectedPaymentProvider?.name)
        return count < Constants.numberOfTimesOnboardingShareScreenShouldAppear
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
    public func didTapOnMoreInformation(documentId: String?) {
        viewDelegate?.didTapOnMoreInformation()
    }
    
    public func didTapOnBankPicker(documentId: String?) {
        viewDelegate?.didTapOnBankPicker()
    }
    
    public func didTapOnPayInvoice(documentId: String?) {
        viewDelegate?.didTapOnPayInvoice()
    }
}

extension PaymentComponentsController: PaymentProvidersBottomViewProtocol {
    public func didTapForwardOnInstallBottomSheet() {
        print("Tapped Forward on Install Bottom Sheet")
    }
    
    public func didTapOnContinueOnShareBottomSheet() {
        print("Tapped Continue on Share Bottom Sheet")
    }
    
    public func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        selectedPaymentProvider = paymentProvider
        storeDefaultPaymentProvider(paymentProvider: paymentProvider)
        bottomViewDelegate?.didSelectPaymentProvider(paymentProvider: paymentProvider)
    }
    
    public func didTapOnClose() {
        bottomViewDelegate?.didTapOnClose()
    }
    
    public func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation()
    }

    public func didTapOnPayButton() {
        bottomViewDelegate?.didTapOnPayButton()
    }
}

extension PaymentComponentsController {

    private func incrementOnboardingCountFor(paymentProvider: PaymentProvider?) {
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
                self?.giniMerchant.delegate?.didCreatePaymentRequest(paymentRequestID: paymentRequestID)
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
        giniMerchant.paymentService.pdfWithQRCode(paymentRequestId: paymentRequestID) { [weak self] result in
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

extension PaymentComponentsController: ShareInvoiceBottomViewProtocol {
    func didTapOnContinueToShareInvoice() {
        bottomViewDelegate?.didTapOnContinueOnShareBottomSheet()
    }
}

extension PaymentComponentsController: InstallAppBottomViewProtocol {
    func didTapOnContinue() {
        bottomViewDelegate?.didTapForwardOnInstallBottomSheet()
    }
}

extension PaymentComponentsController {
    private enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
        static let pdfExtension = ".pdf"
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
