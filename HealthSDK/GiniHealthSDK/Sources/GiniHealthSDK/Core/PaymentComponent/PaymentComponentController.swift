//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit

protocol PaymentComponentProtocol: AnyObject {
    func getPaymentView() -> UIView
}

public final class PaymentComponentController: NSObject, PaymentComponentProtocol {
    
    var giniConfiguration: GiniHealthConfiguration
    
    public init(giniConfiguration: GiniHealthConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
    public func getPaymentView() -> UIView {
        let paymentComponentView = PaymentComponentView()
        paymentComponentView.viewModel = PaymentComponentViewModel(giniConfiguration: giniConfiguration)
        return paymentComponentView
    }
}
