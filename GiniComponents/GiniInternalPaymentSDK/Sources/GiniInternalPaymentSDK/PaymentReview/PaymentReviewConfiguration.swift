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
    let paymentReviewClose: UIImage
    let backgroundColor: UIColor
    let rectangleColor: UIColor
    let infoBarLabelFont: UIFont
    let statusBarStyle: UIStatusBarStyle
    let pageIndicatorTintColor: UIColor
    let currentPageIndicatorTintColor: UIColor
    let isInfoBarHidden: Bool
    let popupAnimationDuration: TimeInterval

    public init(loadingIndicatorStyle: UIActivityIndicatorView.Style,
                loadingIndicatorColor: UIColor,
                infoBarLabelTextColor: UIColor,
                infoBarBackgroundColor: UIColor,
                mainViewBackgroundColor: UIColor,
                infoContainerViewBackgroundColor: UIColor,
                paymentReviewClose: UIImage,
                backgroundColor: UIColor,
                rectangleColor: UIColor,
                infoBarLabelFont: UIFont,
                statusBarStyle: UIStatusBarStyle,
                pageIndicatorTintColor: UIColor,
                currentPageIndicatorTintColor: UIColor,
                isInfoBarHidden: Bool,
                popupAnimationDuration: TimeInterval = 3.0) {
        self.loadingIndicatorStyle = loadingIndicatorStyle
        self.loadingIndicatorColor = loadingIndicatorColor
        self.infoBarLabelTextColor = infoBarLabelTextColor
        self.infoBarBackgroundColor = infoBarBackgroundColor
        self.mainViewBackgroundColor = mainViewBackgroundColor
        self.infoContainerViewBackgroundColor = infoContainerViewBackgroundColor
        self.backgroundColor = backgroundColor
        self.rectangleColor = rectangleColor
        self.infoBarLabelFont = infoBarLabelFont
        self.statusBarStyle = statusBarStyle
        self.pageIndicatorTintColor = pageIndicatorTintColor
        self.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        self.paymentReviewClose = paymentReviewClose
        self.isInfoBarHidden = isInfoBarHidden
        self.popupAnimationDuration = popupAnimationDuration
    }
}

public struct PaymentReviewStrings {
    public let alertOkButtonTitle: String
    public let infoBarMessage: String
    public let defaultErrorMessage: String
    public let createPaymentErrorMessage: String
    public let invoiceImageAccessibilityLabel: String
    public let closeButtonAccessibilityLabel: String

    public init(alertOkButtonTitle: String,
                infoBarMessage: String,
                defaultErrorMessage: String,
                createPaymentErrorMessage: String,
                invoiceImageAccessibilityLabel: String,
                closeButtonAccessibilityLabel: String) {
        self.alertOkButtonTitle = alertOkButtonTitle
        self.infoBarMessage = infoBarMessage
        self.defaultErrorMessage = defaultErrorMessage
        self.createPaymentErrorMessage = createPaymentErrorMessage
        self.invoiceImageAccessibilityLabel = invoiceImageAccessibilityLabel
        self.closeButtonAccessibilityLabel = closeButtonAccessibilityLabel
    }
}
