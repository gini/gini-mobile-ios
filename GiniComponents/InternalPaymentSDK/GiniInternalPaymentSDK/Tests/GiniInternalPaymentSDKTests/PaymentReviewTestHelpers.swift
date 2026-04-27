//
//  PaymentReviewTestHelpers.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

// MARK: - Mock implementations

final class MockPaymentReviewDelegate: PaymentReviewProtocol {
    var closeKeyboardClickedCalled = false

    // PaymentReviewAPIProtocol
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void) {}
    func shouldHandleErrorInternally(error: GiniError) -> Bool { true }
    func openPaymentProviderApp(requestId: String, universalLink: String) {}
    func submitFeedback(for document: Document,
                        updatedExtractions: [Extraction],
                        completion: ((Result<Void, GiniError>) -> Void)?) {}
    func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniError>) -> Void) {}
    func obtainPDFURLFromPaymentRequest(viewController: UIViewController, paymentRequestId: String) {}

    // PaymentReviewTrackingProtocol
    func trackOnPaymentReviewCloseKeyboardClicked() { closeKeyboardClickedCalled = true }
    func trackOnPaymentReviewCloseButtonClicked() {}
    func trackOnPaymentReviewBankButtonClicked(providerName: String) {}

    // PaymentReviewSupportedFormatsProtocol
    func supportsGPC() -> Bool { false }
    func supportsOpenWith() -> Bool { false }

    // PaymentReviewActionProtocol
    func updatedPaymentProvider(_ paymentProvider: PaymentProvider) {}
    func openMoreInformationViewController() {}
    func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?) {}
    func presentShareInvoiceBottomSheet(paymentRequestId: String,
                                        paymentInfo: PaymentInfo,
                                        completion: @escaping (UIViewController) -> Void) {}
}

final class MockBottomSheetsProvider: BottomSheetsProviderProtocol {
    func installAppBottomSheet() -> UIViewController { UIViewController() }
    func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> UIViewController { UIViewController() }
    func bankSelectionBottomSheet() -> UIViewController { UIViewController() }
}

// MARK: - Test factories

extension PaymentProvider {
    static var test: PaymentProvider {
        PaymentProvider(id: "test-provider-id",
                        name: "Test Bank",
                        appSchemeIOS: "testbank://",
                        minAppVersion: nil,
                        colors: ProviderColors(background: "#FFFFFF", text: "#000000"),
                        iconData: Data(),
                        appStoreUrlIOS: nil,
                        universalLinkIOS: "https://testbank.example",
                        index: 0,
                        gpcSupportedPlatforms: [],
                        openWithSupportedPlatforms: [])
    }
}

extension TextFieldConfiguration {
    static var test: TextFieldConfiguration {
        TextFieldConfiguration(backgroundColor: .white,
                               borderColor: .systemGray4,
                               textColor: .label,
                               textFont: .systemFont(ofSize: 14),
                               cornerRadius: 8,
                               borderWidth: 1,
                               placeholderForegroundColor: .placeholderText)
    }
}

extension ButtonConfiguration {
    static var test: ButtonConfiguration {
        ButtonConfiguration(backgroundColor: .systemBlue,
                            borderColor: .clear,
                            titleColor: .white,
                            titleFont: .systemFont(ofSize: 16, weight: .semibold),
                            shadowColor: .clear,
                            cornerRadius: 8,
                            borderWidth: 0,
                            shadowRadius: 0,
                            withBlurEffect: false)
    }
}

extension PoweredByGiniConfiguration {
    static var test: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(poweredByGiniLabelFont: .systemFont(ofSize: 12),
                                   poweredByGiniLabelAccentColor: .label,
                                   giniIcon: UIImage())
    }
}

extension PoweredByGiniStrings {
    static var test: PoweredByGiniStrings {
        PoweredByGiniStrings(poweredByGiniText: "Powered by Gini")
    }
}

extension BottomSheetConfiguration {
    static var test: BottomSheetConfiguration {
        BottomSheetConfiguration(backgroundColor: .white,
                                 rectangleColor: .systemGray4,
                                 dimmingBackgroundColor: UIColor.black.withAlphaComponent(0.5))
    }
}

extension PaymentReviewContainerStrings {
    static func test(keyboardDoneButtonTitle: String = "Done") -> PaymentReviewContainerStrings {
        let placeholders = PaymentReviewFieldPlaceholders(recipient: "Recipient",
                                                          iban: "IBAN",
                                                          amount: "Amount",
                                                          usage: "Usage")
        let errors = PaymentReviewFieldErrors(emptyCheck: "Field is empty",
                                              ibanCheck: "Invalid IBAN",
                                              recipient: "Invalid recipient",
                                              iban: "IBAN required",
                                              amount: "Amount required",
                                              purpose: "Purpose required")
        let accessibility = PaymentReviewBankSelectionAccessibility(payInvoiceHint: "Pay invoice",
                                                                     selectBankText: "Select bank",
                                                                     selectBankHint: "Hint")
        return PaymentReviewContainerStrings(fieldPlaceholders: placeholders,
                                             fieldErrors: errors,
                                             bankSelectionAccessibility: accessibility,
                                             payInvoiceLabelText: "Pay invoice",
                                             infoBarMessage: "Info",
                                             keyboardDoneButtonTitle: keyboardDoneButtonTitle)
    }
}

extension PaymentReviewContainerConfiguration {
    static var test: PaymentReviewContainerConfiguration {
        let errorLabel = PaymentReviewErrorLabelConfiguration(textColor: .systemRed,
                                                              font: .systemFont(ofSize: 12))
        let banksPicker = PaymentReviewBanksPickerConfiguration(lockIcon: UIImage(),
                                                                lockedFields: false,
                                                                showBanksPicker: true,
                                                                chevronDownIcon: nil,
                                                                chevronDownIconColor: nil)
        let infoBar = PaymentReviewInfoBarConfiguration(labelTextColor: .label,
                                                        labelFont: .systemFont(ofSize: 12),
                                                        backgroundColor: .systemBlue,
                                                        containerBackgroundColor: .systemBackground)
        return PaymentReviewContainerConfiguration(errorLabel: errorLabel,
                                                   banksPicker: banksPicker,
                                                   infoBar: infoBar,
                                                   popupAnimationDuration: 3.0)
    }
}

extension PaymentReviewContainerViewModel {
    static func test(paymentInfo: PaymentInfo? = nil,
                     extractions: [Extraction]? = nil,
                     keyboardDoneButtonTitle: String = "Done") -> PaymentReviewContainerViewModel {
        let paymentData = PaymentReviewContainerPaymentData(extractions: extractions,
                                                            document: nil,
                                                            paymentInfo: paymentInfo,
                                                            selectedPaymentProvider: .test,
                                                            displayMode: .bottomSheet)
        let buttons = PaymentReviewContainerButtonsConfiguration(primaryButton: .test,
                                                                  secondaryButton: .test)
        let inputFields = PaymentReviewContainerInputFieldsConfiguration(defaultStyle: .test,
                                                                          errorStyle: .test,
                                                                          selectionStyle: .test)
        let poweredByGini = PoweredByGiniViewModel(configuration: .test, strings: .test)
        return PaymentReviewContainerViewModel(paymentData: paymentData,
                                               configuration: .test,
                                               strings: .test(keyboardDoneButtonTitle: keyboardDoneButtonTitle),
                                               buttonsConfiguration: buttons,
                                               inputFieldsConfiguration: inputFields,
                                               poweredByGiniViewModel: poweredByGini,
                                               clientConfiguration: nil)
    }
}

extension PaymentReviewStrings {
    static var test: PaymentReviewStrings {
        PaymentReviewStrings(alertOkButtonTitle: "OK",
                             infoBarMessage: "Info",
                             defaultErrorMessage: "Error",
                             createPaymentErrorMessage: "Payment error",
                             invoiceImageAccessibilityLabel: "Invoice",
                             closeButtonAccessibilityLabel: "Close",
                             sheetGrabberAccessibilityLabel: "Sheet",
                             sheetGrabberAccessibilityHint: "Drag")
    }
}

extension PaymentReviewConfiguration {
    static var test: PaymentReviewConfiguration {
        PaymentReviewConfiguration(loadingIndicatorStyle: .medium,
                                   loadingIndicatorColor: .systemBlue,
                                   infoBarLabelTextColor: .label,
                                   infoBarBackgroundColor: .systemBlue,
                                   mainViewBackgroundColor: .systemBackground,
                                   infoContainerViewBackgroundColor: .systemBackground,
                                   paymentReviewClose: UIImage(),
                                   backgroundColor: .systemBackground,
                                   rectangleColor: .systemGray4,
                                   infoBarLabelFont: .systemFont(ofSize: 12),
                                   statusBarStyle: .default,
                                   pageIndicatorTintColor: .systemGray,
                                   currentPageIndicatorTintColor: .systemBlue,
                                   isInfoBarHidden: true,
                                   popupAnimationDuration: 3.0)
    }
}

func makePaymentReviewModel(delegate: MockPaymentReviewDelegate,
                            bottomSheetsProvider: MockBottomSheetsProvider,
                            displayMode: DisplayMode = .bottomSheet) -> PaymentReviewModel {
    PaymentReviewModel(delegate: delegate,
                       bottomSheetsProvider: bottomSheetsProvider,
                       document: nil,
                       extractions: nil,
                       paymentInfo: nil,
                       selectedPaymentProvider: .test,
                       configuration: .test,
                       strings: .test,
                       containerConfiguration: .test,
                       containerStrings: .test(),
                       defaultStyleInputFieldConfiguration: .test,
                       errorStyleInputFieldConfiguration: .test,
                       selectionStyleInputFieldConfiguration: .test,
                       primaryButtonConfiguration: .test,
                       secondaryButtonConfiguration: .test,
                       poweredByGiniConfiguration: .test,
                       poweredByGiniStrings: .test,
                       bottomSheetConfiguration: .test,
                       showPaymentReviewCloseButton: true,
                       previousPaymentComponentScreenType: nil,
                       clientConfiguration: nil)
}
