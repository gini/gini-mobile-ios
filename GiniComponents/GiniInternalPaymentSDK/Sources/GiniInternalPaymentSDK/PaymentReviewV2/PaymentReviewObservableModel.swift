//
//  PaymentReviewObservableModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI

final class PaymentReviewObservableModel: ObservableObject {
    
    @Published var cellViewModels: [PageCollectionCellViewModel] = []
    @Published var isImagesLoading: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedPaymentProvider: PaymentProvider
    
    lazy var paymentReviewPaymentInformationView: PaymentReviewPaymentInformationView = buildPaymentInformationView()
    
    var document: Document? {
        model.document
    }
    
    let model: PaymentReviewModel
    
    init(model: PaymentReviewModel) {
        self.model = model
        self.selectedPaymentProvider = model.selectedPaymentProvider
        setupBindings()
    }
    
    func fetchImages() async {
        await model.fetchImages()
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
    
    private func buildPaymentInformationView() -> PaymentReviewPaymentInformationView {
        PaymentReviewPaymentInformationView(viewModel: model.paymentReviewContainerViewModel(),
                                            onBankSelectionTapped: { [weak self] in
            self?.model.openBankSelectionBottomSheet()
        },
                                            onPayTapped: { [weak self] paymentInfo in
            self?.didTapPay(paymentInfo)
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
            DispatchQueue.main.async {
                self?.cellViewModels = self?.model.cellViewModels ?? []
            }
        }
        
        model.updateImagesLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.isImagesLoading = self?.model.isImagesLoading == true
            }
        }
        
        model.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = self?.model.isLoading == true
            }
        }
        
        model.onNewPaymentProvider = { [weak self] in
            guard let self else { return }
            selectedPaymentProvider = model.selectedPaymentProvider
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
}
