//
//  PaymentReviewConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct PaymentReviewConfiguration {
    let loadingIndicatorStyle: UIActivityIndicatorView.Style
    let loadingIndicatorColor: UIColor
    let infoBarLabelTextColor: UIColor
    let infoBarBackgroundColor: UIColor
    let mainViewBackgroundColor: UIColor
    let infoContainerViewBackgroundColor: UIColor
    let backgroundColor: UIColor
    let infoBarLabelFont: UIFont
    let statusBarStyle: UIStatusBarStyle
}

public struct PaymentReviewStrings {
    let alertOkButtonTitle: String
    let infoBarMessage: String
    let defaultErrorMessage: String
    let createPaymentErrorMessage: String
}
