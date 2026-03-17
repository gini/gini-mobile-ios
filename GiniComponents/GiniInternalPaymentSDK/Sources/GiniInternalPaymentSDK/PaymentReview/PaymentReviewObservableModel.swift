//
//  PaymentReviewObservableModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI

final class PaymentReviewObservableModel: ObservableObject {
    
    private let containerViewModel: PaymentReviewContainerViewModel
    private let paymentInformationObservableModel: PaymentReviewPaymentInformationObservableModel
    
    private var selectedPaymentProvider: PaymentProvider {
        containerViewModel.selectedPaymentProvider
    }
    
    private var bannerDismissTask: Task<Void, Never>?
    private var bannerDismissed: Bool = false
    private var reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled
    private var reduceMotionObserver: NSObjectProtocol?
    
    var isBottomSheetMode: Bool {
        model.displayMode == .bottomSheet
    }
    
    var invoiceImageAccessibilityLabel: String {
        model.strings.invoiceImageAccessibilityLabel
    }
    
    @Published private var showBanner: Bool
    
    @Published var cellViewModels: [PageCollectionCellViewModel] = []
    @Published var isImagesLoading: Bool = false
    @Published var isLoading: Bool = false
    
    var document: Document? {
        model.document
    }
    
    let model: PaymentReviewModel
    
    init(model: PaymentReviewModel) {
        self.model = model
        self.containerViewModel = model.paymentReviewContainerViewModel()
        self.paymentInformationObservableModel = PaymentReviewPaymentInformationObservableModel(model: containerViewModel)
        self.showBanner = !model.configuration.isInfoBarHidden
        setupBindings()
        
        reduceMotionObserver = NotificationCenter.default.addObserver(forName: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.reduceMotion = UIAccessibility.isReduceMotionEnabled
        }
    }
    
    deinit {
        if let reduceMotionObserver {
            NotificationCenter.default.removeObserver(reduceMotionObserver)
        }
        bannerDismissTask?.cancel()
    }
    
    func fetchImages() async {
        await model.fetchImages()
    }
    
    func dismissBannerAfterDelay() {
        guard !bannerDismissed else { return }
        
        let duration = model.paymentReviewContainerViewModel().configuration.popupAnimationDuration
        
        bannerDismissTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(duration))

                guard !Task.isCancelled else { return }
                guard let self = self else { return }

                let animation = self.reduceMotion ? nil : Animation.easeInOut(duration: Constants.bannerDismissDelay)

                await MainActor.run {
                    withAnimation(animation) {
                        self.showBanner = false
                        self.bannerDismissed = true
                    }
                }
            } catch {
                /// Task was cancelled - no action needed
            }
        }
    }
    
    func didTapClose() {
        model.closePaymentReview()
    }
    
    func didTapPay(_ paymentInfo: PaymentInfo) {
        guard let delegate = model.delegate else {
            return
        }
        
        delegate.trackOnPaymentReviewBankButtonClicked(providerName: selectedPaymentProvider.name)
        
        if delegate.supportsGPC() {
            guard selectedPaymentProvider.appSchemeIOS.canOpenURLString() else {
                model.openInstallAppBottomSheet()
                return
            }
            
            createPaymentRequestForGPC(paymentInfo: paymentInfo)
        } else if delegate.supportsOpenWith() {
            createPaymentRequestForOpenWith(paymentInfo: paymentInfo)
        }
    }

    func paymentReviewPaymentInformationView(contentHeight: Binding<CGFloat>) -> PaymentReviewPaymentInformationView {
        PaymentReviewPaymentInformationView(viewModel: paymentInformationObservableModel,
                                            contentHeight: contentHeight,
                                            showBanner: Binding( get: { self.showBanner }, set: { self.showBanner = $0 }),
                                            onBankSelectionTapped: { [weak self] in
            self?.model.openBankSelectionBottomSheet()
        },
                                            onPayTapped: { [weak self] paymentInfo in
            self?.didTapPay(paymentInfo)
        },
                                            onKeyboardDismissed: { [weak self] in
            self?.model.delegate?.trackOnPaymentReviewCloseKeyboardClicked()
        })
    }
    
    private func createPaymentRequestForGPC(paymentInfo: PaymentInfo) {
        model.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] requestId in
            self?.model.openPaymentProviderApp(requestId: requestId, universalLink: paymentInfo.paymentUniversalLink)
        })
        
        sendFeedback(paymentInfo: paymentInfo)
    }
    
    private func createPaymentRequestForOpenWith(paymentInfo: PaymentInfo) {
        model.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] requestId in
            self?.model.openOnboardingShareInvoiceBottomSheet(paymentRequestId: requestId, paymentInfo: paymentInfo)
        })
        
        sendFeedback(paymentInfo: paymentInfo)
    }
    
    private func setupBindings() {
        // Observe changes from the original model
        model.onPreviewImagesFetched = { [weak self] in
            Task { @MainActor [weak self] in
                self?.cellViewModels = self?.model.cellViewModels ?? []
            }
        }
        
        model.updateImagesLoadingStatus = { [weak self] in
            Task { @MainActor [weak self] in
                self?.isImagesLoading = self?.model.isImagesLoading == true
            }
        }
        
        model.updateLoadingStatus = { [weak self] in
            Task { @MainActor [weak self] in
                self?.isLoading = self?.model.isLoading == true
            }
        }
        
        model.onNewPaymentProvider = { [weak self] in
            guard let self else { return }
            containerViewModel.selectedPaymentProvider = model.selectedPaymentProvider
        }
        
        model.onErrorHandling = { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                model.viewModelDelegate?.presentErrorAlert(message: model.strings.defaultErrorMessage)
            }
        }
        
        model.onCreatePaymentRequestErrorHandling = { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                model.viewModelDelegate?.presentErrorAlert(message: model.strings.createPaymentErrorMessage)
            }
        }
    }
    
    private func sendFeedback(paymentInfo: PaymentInfo) {
        let paymentRecipientExtraction = Extraction(box: nil,
                                                    candidates: "",
                                                    entity: "text",
                                                    value: paymentInfo.recipient,
                                                    name: "payment_recipient")
        
        let ibanExtraction = Extraction(box: nil,
                                        candidates: "",
                                        entity: "iban",
                                        value: paymentInfo.iban,
                                        name: "iban")
        
        let paymentPurposeExtraction = Extraction(box: nil,
                                                  candidates: "",
                                                  entity: "text",
                                                  value: paymentInfo.purpose,
                                                  name: "payment_purpose")
        
        let amountToPayExtraction = Extraction(box: nil,
                                               candidates: "",
                                               entity: "amount",
                                               value: paymentInfo.amount,
                                               name: "amount_to_pay")
        
        let updatedExtractions = [paymentRecipientExtraction,
                                  ibanExtraction,
                                  paymentPurposeExtraction,
                                  amountToPayExtraction]
        
        model.sendFeedback(updatedExtractions: updatedExtractions)
    }
    
    private struct Constants {
        
        static let bannerDismissDelay = 0.3
    }
}

