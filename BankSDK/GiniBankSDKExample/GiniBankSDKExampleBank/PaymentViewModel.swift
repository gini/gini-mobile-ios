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
/**
 View model class for review screen
  */
public class PaymentViewModel: NSObject {
    private var apiLib: GiniBankAPI
    private var bankSDK: GiniBank

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var onPaymentInfoFetched: (_ info: PaymentInfo) -> Void = { _ in
        // This method will remain empty;   default implementation does nothing
    }

    var updateLoadingStatus: () -> Void = {
        // This method will remain empty;   default implementation does nothing
    }

    var onErrorHandling: (_ error: GiniBankError) -> Void = { _ in
        // This method will remain empty;   default implementation does nothing
    }

    var onResolvePaymentRequest: (_ resolved: ResolvedPaymentRequest) -> Void = { _ in
        // This method will remain empty;   default implementation does nothing
    }

    var onResolvePaymentRequestErrorHandling: () -> Void = {
        // This method will remain empty;   default implementation does nothing
    }

    var onGettingPayment: (_ payment: Payment) -> Void = { _ in
        // This method will remain empty;   default implementation does nothing
    }

    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus()
        }
    }

    private var paymentRequest: ResolvedPaymentRequest?

    public init(with giniApiLib: GiniBankAPI) {
        apiLib = giniApiLib
        bankSDK = GiniBank(with: apiLib)
    }
    

    func resolvePaymentRequest(paymentInfo: PaymentInfo) {
        isLoading = true
        bankSDK.resolvePaymentRequest(paymentRequesId: appDelegate.paymentRequestId, paymentInfo: paymentInfo) { [weak self] result in
            switch result {
            case .success(let resolvedPaymentRequest):
                self?.paymentRequest = resolvedPaymentRequest
                self?.isLoading = false
                self?.onResolvePaymentRequest(resolvedPaymentRequest)
            case .failure:
                self?.isLoading = false
                self?.onResolvePaymentRequestErrorHandling()
            }
        }
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
                    let paymentInfo = PaymentInfo(recipient: paymentRequest.recipient, iban: paymentRequest.iban, bic: paymentRequest.bic, amount: paymentRequest.amount, purpose: paymentRequest.purpose)
                    self?.onPaymentInfoFetched(paymentInfo)
                case let .failure(error):
                    self?.isLoading = false
                    self?.onErrorHandling(error)
                }
            }
        }
    }
    
    func fetchPayment(){
        bankSDK.paymentService.payment(id: appDelegate.paymentRequestId) { [weak self] result in
            switch result {
            case let .success(payment):
                self?.isLoading = false
                self?.onGettingPayment(payment)
            case let .failure(error):
                self?.isLoading = false
                self?.onErrorHandling(.apiError(error))
            }
        }
    }
}
