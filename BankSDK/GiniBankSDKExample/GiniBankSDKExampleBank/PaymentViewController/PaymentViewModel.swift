//
//  PaymentViewModel.swift
//  Bank
//
//  Created by Nadya Karaban on 03.05.21.
//

import Foundation
import GiniBankAPILibrary
import GiniBankSDK
import UIKit
import SwiftUI
import Combine

protocol PaymentViewModelDelegate: AnyObject {
    func paymentViewModelDidFinishPayment(_ paymentViewModel: PaymentViewModel, with paymentRequest: ResolvedPaymentRequest)
}

public class PaymentViewModel: ObservableObject {
    private var apiLib: GiniBankAPI
    private var bankSDK: GiniBank

    weak var delegate: PaymentViewModelDelegate?

    @Published var invoiceTitle: String = ""
    @Published var iban: String = ""
    @Published var invoiceReference: String = ""
    @Published var invoicePrice: Double = 28

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var paymentInfo: PaymentInfo?

    var onErrorHandling: (_ error: GiniBankError) -> Void = { _ in }
    var onResolvePaymentRequestErrorHandling: () -> Void = { }

    @Published var isLoading: Bool = false
    private var paymentRequest: ResolvedPaymentRequest?
    private var disposeBag = [AnyCancellable]()

    public init(with giniApiLib: GiniBankAPI) {
        apiLib = giniApiLib
        bankSDK = GiniBank(with: apiLib)

        $invoiceTitle.sink { [weak self] newValue in
            self?.paymentInfo?.recipient = newValue
        }.store(in: &disposeBag)

        $iban.sink { [weak self] newValue in
            self?.paymentInfo?.iban = newValue
        }.store(in: &disposeBag)

        $invoiceReference.sink { [weak self] newValue in
            self?.paymentInfo?.purpose = newValue
        }.store(in: &disposeBag)

        $invoicePrice.sink { [weak self] newValue in
            self?.paymentInfo?.amount = String(newValue)
        }.store(in: &disposeBag)
    }
    

    func resolvePaymentRequest() {
        guard let paymentInfo = paymentInfo else { return }
        guard isPaymentInfoOK() else { return }
        isLoading = true
        bankSDK.resolvePaymentRequest(paymentRequesId: appDelegate.paymentRequestId, paymentInfo: paymentInfo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resolvedPaymentRequest):
                self.paymentRequest = resolvedPaymentRequest
                self.isLoading = false
                self.delegate?.paymentViewModelDidFinishPayment(self, with: resolvedPaymentRequest)
            case .failure:
                self.isLoading = false
                self.onResolvePaymentRequestErrorHandling()
            }
        }
    }

    private func isPaymentInfoOK() -> Bool {
        guard let paymentInfo = paymentInfo else { return false }
        return paymentInfo.iban != "" &&
               paymentInfo.purpose != "" &&
               paymentInfo.recipient != "" &&
               paymentInfo.amount != ""
    }

    func openPaymentRequesterApp() {
        if let resolvedPayment = paymentRequest {
            bankSDK.returnBackToBusinessAppHandler(resolvedPaymentRequest: resolvedPayment)
        }
    }

    func fetchPaymentRequest() {
        if appDelegate.paymentRequestId != "" {
            isLoading = true
            bankSDK.receivePaymentRequest(paymentRequestId: appDelegate.paymentRequestId) { [weak self] result in
                switch result {
                case let .success(paymentRequest):
                    self?.isLoading = false

                    let paymentInfo = PaymentInfo(recipient: paymentRequest.recipient,
                                                  iban: paymentRequest.iban,
                                                  bic: paymentRequest.bic,
                                                  amount: String(paymentRequest.amount.split(separator: ":").first ?? "29"),
                                                  purpose: paymentRequest.purpose)
                    self?.paymentInfo = paymentInfo
                    self?.invoiceTitle = paymentRequest.recipient
                    self?.iban = paymentRequest.iban
                    self?.invoicePrice = Double(paymentRequest.amount.split(separator: ":").first ?? "29") ?? 28
                    self?.invoiceReference = paymentRequest.purpose
                case let .failure(error):
                    self?.isLoading = false
                    self?.onErrorHandling(error)
                }
            }
        }
    }
}
