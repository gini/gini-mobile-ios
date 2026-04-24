//
//  PaymentReviewTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers:
//    - GiniLayoutEnvironment.isLandscape  (3 new lines in PR)
//    - PaymentReviewPaymentInformationObservableModel validation,
//      population, adjustment, validateAllFields, buildPaymentInfo
//    - PaymentReviewObservableModel: isBottomSheetMode, keyboardDoneButtonTitle,
//      isAmountFieldFocused default, trackKeyboardDismissed delegate forwarding

import Testing
import UIKit
import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

// MARK: - Mock implementations

private final class MockPaymentReviewDelegate: PaymentReviewProtocol {
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

private final class MockBottomSheetsProvider: BottomSheetsProviderProtocol {
    func installAppBottomSheet() -> UIViewController { UIViewController() }
    func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> UIViewController { UIViewController() }
    func bankSelectionBottomSheet() -> UIViewController { UIViewController() }
}

// MARK: - Test factories

private extension PaymentProvider {
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

private extension TextFieldConfiguration {
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

private extension ButtonConfiguration {
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

private extension PoweredByGiniConfiguration {
    static var test: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(poweredByGiniLabelFont: .systemFont(ofSize: 12),
                                   poweredByGiniLabelAccentColor: .label,
                                   giniIcon: UIImage())
    }
}

private extension PoweredByGiniStrings {
    static var test: PoweredByGiniStrings {
        PoweredByGiniStrings(poweredByGiniText: "Powered by Gini")
    }
}

private extension BottomSheetConfiguration {
    static var test: BottomSheetConfiguration {
        BottomSheetConfiguration(backgroundColor: .white,
                                 rectangleColor: .systemGray4,
                                 dimmingBackgroundColor: UIColor.black.withAlphaComponent(0.5))
    }
}

private extension PaymentReviewContainerStrings {
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

private extension PaymentReviewContainerConfiguration {
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

private extension PaymentReviewContainerViewModel {
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

private extension PaymentReviewStrings {
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

private extension PaymentReviewConfiguration {
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

private func makePaymentReviewModel(delegate: MockPaymentReviewDelegate,
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

// MARK: - GiniLayoutEnvironment tests

@Suite("GiniLayoutEnvironment")
struct GiniLayoutEnvironmentTests {

    @Test("compact vertical size class maps to landscape")
    func compactIsLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: .compact).isLandscape == true)
    }

    @Test("regular vertical size class is not landscape")
    func regularIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: .regular).isLandscape == false)
    }

    @Test("nil vertical size class is not landscape")
    func nilIsNotLandscape() {
        #expect(GiniLayoutEnvironment(verticalSizeClass: nil).isLandscape == false)
    }
}

// MARK: - PaymentReviewPaymentInformationObservableModel tests

@Suite("PaymentReviewPaymentInformationObservableModel — validation")
@MainActor
struct PaymentReviewPaymentInformationObservableModelValidationTests {

    // MARK: validateRecipient

    @Test("empty recipient is invalid and sets error")
    func emptyRecipientIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateRecipient("") == false)
        #expect(sut.recipientError != nil)
    }

    @Test("whitespace-only recipient is invalid")
    func whitespaceRecipientIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateRecipient("   ") == false)
        #expect(sut.recipientError != nil)
    }

    @Test("non-empty recipient is valid and clears error")
    func validRecipientClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateRecipient("") // seed an error first
        #expect(sut.validateRecipient("Gini GmbH") == true)
        #expect(sut.recipientError == nil)
    }

    // MARK: validateIBAN

    @Test("empty IBAN is invalid")
    func emptyIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("") == false)
        #expect(sut.ibanError != nil)
    }

    @Test("malformed IBAN is invalid")
    func malformedIBANIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateIBAN("NOTANIBAN") == false)
        #expect(sut.ibanError != nil)
    }

    @Test("valid German IBAN is accepted and clears error")
    func validIBANClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateIBAN("") // seed an error first
        #expect(sut.validateIBAN("DE89370400440532013000") == true)
        #expect(sut.ibanError == nil)
    }

    // MARK: validateAmount

    @Test("empty amount string is invalid")
    func emptyAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("", amount: 0) == false)
        #expect(sut.amountError != nil)
    }

    @Test("zero decimal amount is invalid")
    func zeroAmountIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAmount("0.00", amount: 0) == false)
        #expect(sut.amountError != nil)
    }

    @Test("positive amount is valid and clears error")
    func positiveAmountClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validateAmount("", amount: 0)
        #expect(sut.validateAmount("12.50", amount: 12.50) == true)
        #expect(sut.amountError == nil)
    }

    // MARK: validatePaymentPurpose

    @Test("empty purpose is invalid")
    func emptyPurposeIsInvalid() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validatePaymentPurpose("") == false)
        #expect(sut.paymentPurposeError != nil)
    }

    @Test("non-empty purpose is valid and clears error")
    func validPurposeClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        _ = sut.validatePaymentPurpose("")
        #expect(sut.validatePaymentPurpose("Invoice 1234") == true)
        #expect(sut.paymentPurposeError == nil)
    }
}

@Suite("PaymentReviewPaymentInformationObservableModel — validateAllFields")
@MainActor
struct PaymentReviewPaymentInformationObservableModelValidateAllTests {

    private func makeFullyPopulatedSUT() -> PaymentReviewPaymentInformationObservableModel {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"
        sut.ibanInputState.text = "DE89370400440532013000"
        sut.amountInputState.text = "12.50"
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        sut.paymentPurposeInputState.text = "Invoice 2026"
        return sut
    }

    @Test("all valid fields returns true")
    func allValidFieldsReturnsTrue() {
        let sut = makeFullyPopulatedSUT()
        #expect(sut.validateAllFields() == true)
    }

    @Test("invalid recipient makes validateAllFields return false")
    func invalidRecipientFails() {
        let sut = makeFullyPopulatedSUT()
        sut.recipientInputState.text = ""
        #expect(sut.validateAllFields() == false)
    }

    @Test("invalid IBAN makes validateAllFields return false")
    func invalidIBANFails() {
        let sut = makeFullyPopulatedSUT()
        sut.ibanInputState.text = "INVALID"
        #expect(sut.validateAllFields() == false)
    }

    @Test("zero amount makes validateAllFields return false")
    func zeroAmountFails() {
        let sut = makeFullyPopulatedSUT()
        sut.amountInputState.text = ""
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")
        #expect(sut.validateAllFields() == false)
    }

    @Test("empty purpose makes validateAllFields return false")
    func emptyPurposeFails() {
        let sut = makeFullyPopulatedSUT()
        sut.paymentPurposeInputState.text = ""
        #expect(sut.validateAllFields() == false)
    }

    @Test("all fields invalid returns false")
    func allInvalidReturnsFalse() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.validateAllFields() == false)
    }

    @Test("validateAllFields then updateFieldErrorStates shows errors in input states")
    func validateThenUpdateShowsErrors() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        // Simulate Pay tapped without ever focusing a field (all fields empty)
        _ = sut.validateAllFields()
        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == true)
        #expect(sut.ibanInputState.hasError == true)
        #expect(sut.amountInputState.hasError == true)
        #expect(sut.paymentPurposeInputState.hasError == true)
    }
}

@Suite("PaymentReviewPaymentInformationObservableModel — buildPaymentInfo")
@MainActor
struct PaymentReviewPaymentInformationObservableModelBuildTests {

    @Test("buildPaymentInfo maps field states to PaymentInfo")
    func buildPaymentInfoMapsFields() {
        let provider = PaymentProvider.test
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"
        sut.ibanInputState.text = "DE89370400440532013000"
        sut.paymentPurposeInputState.text = "Invoice 2026"
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")

        let info = sut.buildPaymentInfo()

        #expect(info.recipient == "Gini GmbH")
        #expect(info.iban == "DE89370400440532013000")
        #expect(info.purpose == "Invoice 2026")
        #expect(info.paymentProviderId == provider.id)
        #expect(info.paymentUniversalLink == provider.universalLinkIOS)
    }
}

@Suite("PaymentReviewPaymentInformationObservableModel — populateFieldsIfNeeded")
@MainActor
struct PaymentReviewPaymentInformationObservableModelPopulateTests {

    @Test("populates fields from PaymentInfo on first call")
    func populatesFromPaymentInfo() {
        let paymentInfo = PaymentInfo(recipient: "Gini GmbH",
                                     iban: "DE89370400440532013000",
                                     amount: "12.50:EUR",
                                     purpose: "Invoice 2026",
                                     paymentUniversalLink: "https://example.com",
                                     paymentProviderId: "test")
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(paymentInfo: paymentInfo))

        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Gini GmbH")
        #expect(sut.ibanInputState.text == "DE89370400440532013000")
        #expect(sut.paymentPurposeInputState.text == "Invoice 2026")
    }

    @Test("populates fields from extractions on first call")
    func populatesFromExtractions() {
        let extractions = [
            Extraction(box: nil, candidates: "", entity: "text", value: "Gini GmbH", name: "payment_recipient"),
            Extraction(box: nil, candidates: "", entity: "iban", value: "DE89370400440532013000", name: "iban"),
            Extraction(box: nil, candidates: "", entity: "text", value: "Invoice 2026", name: "payment_purpose"),
            Extraction(box: nil, candidates: "", entity: "amount", value: "12.50:EUR", name: "amount_to_pay")
        ]
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(extractions: extractions))

        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Gini GmbH")
        #expect(sut.ibanInputState.text == "DE89370400440532013000")
        #expect(sut.paymentPurposeInputState.text == "Invoice 2026")
    }

    @Test("second call is a no-op (idempotent)")
    func isIdempotent() {
        let paymentInfo = PaymentInfo(recipient: "Gini GmbH",
                                     iban: "DE89370400440532013000",
                                     amount: "12.50:EUR",
                                     purpose: "Invoice 2026",
                                     paymentUniversalLink: "https://example.com",
                                     paymentProviderId: "test")
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test(paymentInfo: paymentInfo))
        sut.populateFieldsIfNeeded()
        sut.recipientInputState.text = "Changed"
        sut.populateFieldsIfNeeded()

        #expect(sut.recipientInputState.text == "Changed",
                "second populateFieldsIfNeeded must not overwrite manually changed fields")
    }
}

@Suite("PaymentReviewPaymentInformationObservableModel — adjustAmountValue")
@MainActor
struct PaymentReviewPaymentInformationObservableModelAdjustTests {

    @Test("valid amount string returns adjusted text and decimal value")
    func validAmountReturnsAdjustedPair() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        let result = sut.adjustAmountValue(text: "12,50")
        #expect(result != nil)
        #expect(result?.newValue ?? 0 > 0)
    }

    @Test("empty string returns nil")
    func emptyStringReturnsNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.adjustAmountValue(text: "") == nil)
    }

    @Test("non-numeric string returns nil")
    func nonNumericReturnsNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        #expect(sut.adjustAmountValue(text: "abcdef") == nil)
    }
}

@Suite("PaymentReviewPaymentInformationObservableModel — updateFieldErrorStates")
@MainActor
struct PaymentReviewPaymentInformationObservableModelErrorStatesTests {

    @Test("updateFieldErrorStates mirrors error properties into input states")
    func errorStatesMirrored() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientError = "Invalid recipient"
        sut.ibanError = "Invalid IBAN"
        sut.amountError = nil
        sut.paymentPurposeError = "Purpose required"

        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == true)
        #expect(sut.recipientInputState.errorMessage == "Invalid recipient")
        #expect(sut.ibanInputState.hasError == true)
        #expect(sut.amountInputState.hasError == false)
        #expect(sut.paymentPurposeInputState.hasError == true)
    }

    @Test("updateFieldErrorStates clears error when property is nil")
    func clearsErrorWhenNil() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true
        sut.recipientError = nil

        sut.updateFieldErrorStates()

        #expect(sut.recipientInputState.hasError == false)
    }
}

// MARK: - PaymentReviewObservableModel tests

@Suite("PaymentReviewObservableModel")
@MainActor
struct PaymentReviewObservableModelTests {

    @Test("isBottomSheetMode is true when document is nil")
    func bottomSheetModeWithNoDocument() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.isBottomSheetMode == true)
    }

    @Test("keyboardDoneButtonTitle returns the configured string")
    func keyboardDoneButtonTitleIsConfigured() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = PaymentReviewModel(delegate: delegate,
                                       bottomSheetsProvider: provider,
                                       document: nil,
                                       extractions: nil,
                                       paymentInfo: nil,
                                       selectedPaymentProvider: .test,
                                       configuration: .test,
                                       strings: .test,
                                       containerConfiguration: .test,
                                       containerStrings: .test(keyboardDoneButtonTitle: "Fertig"),
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
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.keyboardDoneButtonTitle == "Fertig")
    }

    @Test("isAmountFieldFocused defaults to false")
    func isAmountFieldFocusedDefaultsFalse() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.isAmountFieldFocused == false)
    }

    @Test("trackKeyboardDismissed notifies the delegate")
    func trackKeyboardDismissedNotifiesDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        sut.trackKeyboardDismissed()

        #expect(delegate.closeKeyboardClickedCalled == true)
    }

    @Test("dismissBannerAfterDelay does not throw and is safe to call twice")
    func dismissBannerAfterDelayIsSafeToCallTwice() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        // Should not crash or throw when called multiple times
        sut.dismissBannerAfterDelay()
        sut.dismissBannerAfterDelay()
    }
}

// MARK: - PaymentReviewPaymentInformationObservableModel — handleFocusChange

@Suite("PaymentReviewPaymentInformationObservableModel — handleFocusChange")
@MainActor
struct PaymentReviewPaymentInformationObservableModelHandleFocusChangeTests {

    @Test("focus gained clears hasError")
    func focusGainedClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.hasError = true

        sut.handleFocusChange(isFocused: true,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == false)
    }

    @Test("focus lost with valid text sets no error")
    func focusLostValidTextNoError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = "Gini GmbH"

        sut.handleFocusChange(isFocused: false,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == false)
    }

    @Test("focus lost with empty text sets hasError and errorMessage")
    func focusLostEmptyTextSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.recipientInputState.text = ""

        sut.handleFocusChange(isFocused: false,
                              inputState: \.recipientInputState,
                              validate: sut.validateRecipient,
                              error: \.recipientError)

        #expect(sut.recipientInputState.hasError == true)
        #expect(sut.recipientInputState.errorMessage != nil)
    }

    @Test("focus lost with invalid IBAN sets hasError")
    func focusLostInvalidIBANSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.ibanInputState.text = "NOTANIBAN"

        sut.handleFocusChange(isFocused: false,
                              inputState: \.ibanInputState,
                              validate: sut.validateIBAN,
                              error: \.ibanError)

        #expect(sut.ibanInputState.hasError == true)
    }
}

// MARK: - PaymentReviewPaymentInformationObservableModel — handleAmountFocusChange

@Suite("PaymentReviewPaymentInformationObservableModel — handleAmountFocusChange")
@MainActor
struct PaymentReviewPaymentInformationObservableModelHandleAmountFocusTests {

    @Test("focus gained sets text to raw numeric value")
    func focusGainedSetsRawText() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: true)

        #expect(sut.amountInputState.text == (sut.amountToPay.stringWithoutSymbol ?? ""))
    }

    @Test("focus lost with empty text sets hasError")
    func focusLostEmptyTextSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = ""
        sut.amountToPay = Price(value: 0, currencyCode: "EUR")

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == true)
    }

    @Test("focus lost with valid positive amount clears error")
    func focusLostValidAmountClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountToPay = Price(value: 12.50, currencyCode: "EUR")
        // Use stringWithoutSymbol so the text uses the same locale-specific decimal
        // separator that decimal() will parse correctly on any CI machine.
        sut.amountInputState.text = sut.amountToPay.stringWithoutSymbol ?? "12.50"

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == false)
    }

    @Test("focus lost with zero parsed amount sets hasError")
    func focusLostZeroAmountSetsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.text = "0"

        sut.handleAmountFocusChange(isFocused: false)

        #expect(sut.amountInputState.hasError == true)
    }
}

// MARK: - PaymentReviewPaymentInformationObservableModel — handleAmountTextChange

@Suite("PaymentReviewPaymentInformationObservableModel — handleAmountTextChange")
@MainActor
struct PaymentReviewPaymentInformationObservableModelHandleAmountTextChangeTests {

    @Test("valid amount text clears error and updates amountToPay")
    func validTextClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true

        sut.handleAmountTextChange(updatedText: "12,50")

        #expect(sut.amountInputState.hasError == false)
        #expect(sut.amountToPay.value > 0)
    }

    @Test("non-parsable text still clears hasError without crashing")
    func nonParsableTextClearsError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.amountInputState.hasError = true

        sut.handleAmountTextChange(updatedText: "abc")

        #expect(sut.amountInputState.hasError == false)
    }
}

// MARK: - PaymentReviewPaymentInformationObservableModel — fieldState

@Suite("PaymentReviewPaymentInformationObservableModel — fieldState")
@MainActor
struct PaymentReviewPaymentInformationObservableModelFieldStateTests {

    @Test("hasError true returns .error regardless of active field")
    func errorStateReturnedWhenHasError() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .recipient

        #expect(sut.fieldState(for: .recipient, hasError: true) == .error)
    }

    @Test("active field with no error returns .focused")
    func activeFieldReturnsFocused() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .iban

        #expect(sut.fieldState(for: .iban, hasError: false) == .focused)
    }

    @Test("non-active field with no error returns .normal")
    func nonActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = .recipient

        #expect(sut.fieldState(for: .iban, hasError: false) == .normal)
    }

    @Test("nil active field returns .normal")
    func nilActiveFieldReturnsNormal() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())
        sut.activeField = nil

        #expect(sut.fieldState(for: .amount, hasError: false) == .normal)
    }
}