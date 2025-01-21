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

protocol PaymentComponentsProtocol {
    var isLoading: Bool { get set }
    var selectedPaymentProvider: PaymentProvider? { get set }
    func loadPaymentProviders()
    func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
    func paymentView() -> UIView
    func bankSelectionBottomSheet() -> UIViewController
    func loadPaymentReviewScreenFor(trackingDelegate: GiniHealthTrackingDelegate?,
                                    previousPaymentComponentScreenType: PaymentComponentScreenType?,
                                    completion: @escaping (UIViewController?, GiniHealthError?) -> Void)
    func paymentInfoViewController() -> UIViewController
    func paymentViewBottomSheet() -> UIViewController
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

/**
 The `PaymentComponentsController` class allows control over the payment components.
 */
public final class PaymentComponentsController: BottomSheetsProviderProtocol, GiniHealthTrackingDelegate {
    /// handling the Payment Component Controller delegate
    public weak var delegate: PaymentComponentsControllerProtocol?

    let giniSDK: GiniHealth
    private var trackingDelegate: GiniHealthTrackingDelegate?

    var paymentProviders: GiniHealthAPILibrary.PaymentProviders = []

    let configurationProvider: PaymentComponentsConfigurationProvider
    let stringsProvider: PaymentComponentsStringsProvider

    /// storing the current selected payment provider
    public var selectedPaymentProvider: PaymentProvider?
    var healthSelectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider? {
        selectedPaymentProvider?.toHealthPaymentProvider()
    }

    /// reponsible for storing the loading state of the controller and passing it to the delegate listeners
    var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingStateChanged(isLoading: isLoading)
        }
    }

    /// Previous presented view
    var previousPresentedViews: [PaymentComponentScreenType] = []
    // Client's navigation controller provided in order to handle all HealthSDK flows
    weak var navigationControllerProvided: UINavigationController?
    // Payment Information from the invoice that contains a document or not
    var paymentInfo: GiniInternalPaymentSDK.PaymentInfo?
    // Document Id if present for invocies with document
    var documentId: String?
    // Errors stack received from API. We will show them for the clients
    var errors: [String] = []
    
    // Store Share Bottom Sheet for dismissed native share modal
    var shareInvoiceBottomSheet: ShareInvoiceBottomView?
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
        loadPaymentProviders()
    }
    
    /**
         Initiates the payment flow for a specified document and payment information.

         - Parameters:
           - documentId: An optional identifier for the document associated id with the payment flow.
           - paymentInfo: An optional `PaymentInfo` object containing the payment details.
           - navigationController: The `UINavigationController` used to present subsequent view controllers in the payment flow.
         
         This method sets up the payment flow by storing the provided document ID, payment information, and navigation controller.
         If a `selectedPaymentProvider` is available, it either presents the payment review screen or the payment view bottom sheet,
         depending on the configuration. If no payment provider is selected, it directly presents the payment view bottom sheet.
     */
    public func startPaymentFlow(documentId: String?, paymentInfo: GiniHealthSDK.PaymentInfo?, navigationController: UINavigationController, trackingDelegate: GiniHealthTrackingDelegate?) {
        self.navigationControllerProvided = navigationController
        if let paymentInfo {
            self.paymentInfo = GiniInternalPaymentSDK.PaymentInfo(paymentConponentsInfo: paymentInfo)
        }
        self.documentId = documentId
        self.trackingDelegate = trackingDelegate
        guard let _ = selectedPaymentProvider else {
            presentPaymentViewBottomSheet()
            return
        }
        if GiniHealthConfiguration.shared.useInvoiceWithoutDocument {
            if GiniHealthConfiguration.shared.showPaymentReviewScreen {
                didTapOnPayInvoice(documentId: documentId)
            } else {
                presentPaymentViewBottomSheet()
            }
        } else {
            didTapOnPayInvoice(documentId: documentId)
        }
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
}

extension PaymentComponentsController: PaymentReviewProtocol {
    /**
     Submits feedback for the specified document and its updated extractions. Method used to update the information extracted from a document.

     - Parameters:
       - document: The document for which feedback is being submitted.
       - updatedExtractions: The updated extractions related to the document.
       - completion: An optional closure to be executed upon completion, containing the result of the submission.
     */
    public func submitFeedback(for documentId: String, updatedExtractions: [GiniHealthAPILibrary.Extraction], completion: ((Result<Void, GiniHealthAPILibrary.GiniError>) -> Void)?) {
        let extractions = updatedExtractions.map { Extraction(healthExtraction: $0) }
        giniSDK.documentService.submitFeedback(for: documentId, with: [], and: ["payment": [extractions]]) { result in
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
     Called when the payment request was successfully created

     - parameter paymentRequestId: Id of created payment request.
     */
    public func didCreatePaymentRequest(paymentRequestId: String) {
        giniSDK.delegate?.didCreatePaymentRequest(paymentRequestId: paymentRequestId)
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
         Notifies the tracking delegate of an event occurring on the payment review screen.

         - Parameter event: A `TrackingEvent` of type `PaymentReviewScreenEventType` that describes the specific event
           that occurred on the payment review screen.
         
         This method forwards the event to the `trackingDelegate`, which can handle it based on the event type and any associated data.
    */
    public func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
    }

    /**
     Fetches bank logos for the available payment providers.

     - Returns: A tuple containing an array of logo data and the count of additional banks, if any.
     */
    func fetchBankLogos() -> (logos: [Data]?, additionalBankCount: Int?) {
        guard !paymentProviders.isEmpty else { return ([], nil)}
        let maxShownProviders = min(paymentProviders.count, 2)
        let additionalBankCount = paymentProviders.count > 2 ? paymentProviders.count - 2 : nil
        return (paymentProviders.prefix(maxShownProviders).map { $0.iconData }, additionalBankCount)
    }
}

extension PaymentComponentsController {
    enum Constants {
        static let kDefaultPaymentProvider = "defaultPaymentProvider"
        static let pdfExtension = ".pdf"
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
