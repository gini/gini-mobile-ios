//
//  GiniConfiguration.swift
//  GiniCapture
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary
/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */
@objc public class GiniColor: NSObject {
    var light: UIColor
    var dark: UIColor

    /**
     Creates a GiniColor with the colors for the light and dark modes.

     - parameter light: color for the light mode
     - parameter dark: color for the dark mode
     */
    public init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }

    public func uiColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return self.dark
                } else {
                    /// Return the color for Light Mode
                    return self.light
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return self.light
        }
    }
}

/**
 The `GiniConfiguration` class allows customizations to the look and feel of the Gini Capture SDK.
 If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.

 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle.
         The library will prefer whatever value is set in the following order: attribute in configuration,
         key in strings file in project bundle, key in strings file in `GiniCapture` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files
         in the projects bundle. The library will prefer whatever value is set in the following order: asset file
         in project bundle, asset file in `GiniCapture` bundle.
 - attention: If there are conflicting pairs of image and text for an interface element
              (e.g. `navigationBarCameraTitleCloseButton`) the image will always be preferred,
              while making sure the accessibility label is set.
 */
@objc public final class GiniConfiguration: NSObject {

    /**
     Singleton to make configuration internally accessible in all classes of the Gini Capture SDK.
     */
    public static var shared = GiniConfiguration()
    /**
     Supported document types by Gini Capture SDK.
    */
    @objc public enum GiniCaptureImportFileTypes: Int {
        case none
        case pdf
        case pdf_and_images
    }

    /**
     Returns a `GiniConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Capture SDK.

     - returns: Instance of `GiniConfiguration`.
     */
    override init() {}

    // MARK: General options

    /**
     Sets custom validations that can be done apart from the default ones (file size, file type...).
     It should throw a `CustomDocumentValidationError` error.
     */
    @objc public var customDocumentValidations: ((GiniCaptureDocument) -> CustomDocumentValidationResult) = { _ in
        return CustomDocumentValidationResult.success()
    }

    /**
     Should be set if the main app's bundle is not used.
     */
    public var customResourceBundle: Bundle?

    /**
     Enables the customization of resources to override the default Gini resources. The change will affect all screens.

     - Important: To ensure proper customization, set this property before configuring any custom Gini button configurations, such as `primaryButtonConfiguration`, `secondaryButtonConfiguration`, `transparentButtonConfiguration`, `cameraControlButtonConfiguration` and `addPageButtonConfiguration`.
     */
    public var customResourceProvider: CustomResourceProvider?

    // MARK: Button configuration options

    public lazy var primaryButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .GiniCapture.accent1,
                                borderColor: .clear,
                                titleColor: .GiniCapture.light1,
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)

    public lazy var secondaryButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .GiniCapture.dark4,
                                borderColor: GiniColor(light: UIColor.GiniCapture.light6,
                                                      dark: UIColor.clear).uiColor(),
                                titleColor: GiniColor(light: UIColor.GiniCapture.dark6,
                                                      dark: UIColor.GiniCapture.light1).uiColor(),
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 2,
                                shadowRadius: 14,
                                withBlurEffect: true)

    public lazy var transparentButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: .GiniCapture.accent1,
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)

    public lazy var cameraControlButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: .GiniCapture.light1,
                                shadowColor: .clear,
                                cornerRadius: 0,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)

    public lazy var addPageButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: GiniColor(light: .GiniCapture.dark2, dark: .GiniCapture.light2).uiColor(),
                                shadowColor: .clear,
                                cornerRadius: 0,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)

    /**
     Can be turned on during development to unlock extra information and to save captured images to camera roll.

     - warning: Should never be used outside of a development enviroment.
     */
    @objc public var debugModeOn = false

    /**
     Used to handle all the logging messages in order to log them in a different way.
     */
    @objc public var logger: GiniLogger = DefaultLogger()

    /**
     Indicates whether the multipage feature is enabled or not. In case of `true`,
     multiple pages can be processed, showing a different review screen when capturing.
     */
    @objc public var multipageEnabled = false

    /**
     Sets the custom navigation view controller as a root view controller for Gini Capture SDK screens.
    */
    @objc public var customNavigationController: UINavigationController?

    /**
     Indicates whether the open with feature is enabled or not. In case of `true`,
     a new option with the open with tutorial wil be shown in the Help menu.
     */
    @objc public var openWithEnabled = false

    /**
     Indicates whether the QR Code scanning feature is enabled or not.
     */
    @objc public var qrCodeScanningEnabled = false

    /**
     Indicates whether only the QR Code scanning feature is enabled or not.
     */
    @objc public var onlyQRCodeScanningEnabled = false

    /**
     Indicates the status bar style in the Gini Capture SDK.
     */
    @objc public var statusBarStyle = UIStatusBarStyle.lightContent

    // MARK: Camera options
    /**
     Set the types supported by the file import feature. `GiniCaptureImportFileTypes.none` by default.
     */
    @objc public var fileImportSupportedTypes: GiniCaptureImportFileTypes = .none

    /**
     Indicates whether the flash toggle should be shown in the camera screen.
     */
    @objc public var flashToggleEnabled = false

    /**
     Set whether the camera flash should be on or off when the SDK starts. The flash is off by default.
     */
    @objc public var flashOnByDefault = false

    /**
     Sets the close button text in the navigation bar on the camera screen.
    */
    @objc public var navigationBarCameraTitleCloseButton = ""

    /**
     Sets the help button text in the navigation bar on the camera screen.
     */
    @objc public var navigationBarCameraTitleHelpButton = ""

    // MARK: Onboarding screens

    /**
      * Sets the continue button text in the navigation bar on the onboarding screen.
     */
    @objc public var navigationBarOnboardingTitleContinueButton = ""

    /**
      * Indicates whether the onboarding screen should be presented at each start of the Gini Capture SDK.
     */
    @objc public var onboardingShowAtLaunch = false

    /**
     Indicates whether the onboarding screen should be presented at the first
     start of the Gini Capture SDK. It is advised to do so.

     - note: Overwrites `onboardingShowAtLaunch` for the first launch.
     */
    @objc public var onboardingShowAtFirstLaunch = true

    /**
     Set custom onboarding pages
     - note: For your convenience we provide the `OnboardingPage` struct.
     */
    public var customOnboardingPages: [OnboardingPage]?

    /**
      * Enable/disable the bottom navigation bar.
     */
    public var bottomNavigationBarEnabled: Bool = false

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the help screens.
     */
    public var helpNavigationBarBottomAdapter: HelpBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the camera screen.
     */
    public var cameraNavigationBarBottomAdapter: CameraBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the review screen.
     */
    public var reviewNavigationBarBottomAdapter: ReviewScreenBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the image picker screen.
     */
    public var imagePickerNavigationBarBottomAdapter: ImagePickerBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the onboarding screen.
     */
    public var onboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?

    /**
      * Set an adapter implementation to show a custom illustration on the "align corners" onboarding page.
     */
    public var onboardingAlignCornersIllustrationAdapter: OnboardingIllustrationAdapter?

     /**
       * Set an adapter implementation to show a custom illustration on the "lighting" onboarding page.
      */
    public var onboardingLightingIllustrationAdapter: OnboardingIllustrationAdapter?

     /**
      * Set an adapter implementation to show a custom illustration on the "multi-page" onboarding page.
      */
    public var onboardingMultiPageIllustrationAdapter: OnboardingIllustrationAdapter?

     /**
      * Set an adapter implementation to show a custom illustration on the "QR code" onboarding page.
      */
    public var onboardingQRCodeIllustrationAdapter: OnboardingIllustrationAdapter?

    /**
     * Set an adapter implementation to show a custom loading indicator on the document analysis screen.
     */
    public var customLoadingIndicator: CustomLoadingIndicatorAdapter?

    /**
     * Set an adapter implementation to show a custom loading indicator on the buttons which support loading.
     */
    public var onButtonLoadingIndicator: OnButtonLoadingIndicatorAdapter?

    /**
     Sets the back button text in the navigation bar on the review screen. Use this if you only want to show the title.
     */
    @objc public var navigationBarReviewTitleBackButton = ""

    /**
     Sets the close button text in the navigation bar on the review screen. Use this if you only want to show the title.
     */
    @objc public var navigationBarReviewTitleCloseButton = ""

    /**
     * Sets the continue button text in the navigation bar on the review screen.
     */
    @objc public var navigationBarReviewTitleContinueButton = ""

    // MARK: Analysis options

    /**
     * Sets the back button text in the navigation bar on the analysis screen. Use this if you only want to show the title.
     */
    @objc public var navigationBarAnalysisTitleBackButton = ""

    // MARK: Help screens

    /**
     Sets the back button text in the navigation bar on the help menu screen. Use this if you only want to show the title.
     */
    @objc public var navigationBarHelpMenuTitleBackToCameraButton = ""

    /**
     Sets the back button text in the navigation bar on the help screen. Use this if you only want to show the title.
    */
    @objc public var navigationBarHelpScreenTitleBackToMenuButton = ""

    /**
     Indicates whether the supported format screens should be shown. In case of `false`,
     the option won't be shown in the Help menu.
     */
    @objc public var shouldShowSupportedFormatsScreen = true

    // MARK: Open with tutorial options

    /**
     Sets the text of the app name for the Open with tutorial texts.
    */
    @objc public var openWithAppNameForTexts = Bundle.main.appName

    /**
     Sets if the Drag&Drop step should be shown in the "Open with" tutorial.
     */
    @objc public var shouldShowDragAndDropTutorial = true

    /**
     Set an array of additional custom help menu items . Those items will be presented as table view cells on the help menu screen. By selecting the cell the user will be redirected to the page, which represented by viewController provided by customer during the  `HelpMenuViewController.Item` initialization.
    */
    public var customMenuItems: [HelpMenuItem] = []

    // MAKR: - Transaction Docs feature
    /**
     * Indicates whether the Transaction Docs feature is enabled or not. If set to `true`,
     * the user will be presented with an alert dialog in the photo payment flow to choose
     * whether to attach images or PDFs to the transaction.
     */
    public var transactionDocsEnabled: Bool = true

    /**
     Sets the default error logger. It is only used when giniErrorLoggerIsOn is true.

     - note: Internal usage only.
     */
    internal var giniErrorLogger: GiniCaptureErrorLoggerDelegate? {
        get {
            return errorLogger.giniErrorLogger
        }
        set {
            errorLogger.giniErrorLogger = newValue
        }
    }

    let errorLogger = GiniCaptureErrorLogger()

    /**
     Sets if the default error logging implementation is on.
     */
    @objc public var giniErrorLoggerIsOn: Bool {
        get {
            return errorLogger.isGiniLoggingOn
        }
        set {
            errorLogger.isGiniLoggingOn = newValue
        }
    }

    /**
     Should sets if the custom error logging is implemented.
     */
    public var customGiniErrorLoggerDelegate: GiniCaptureErrorLoggerDelegate? {
        get {
            return errorLogger.customErrorLogger
        }
        set {
            errorLogger.customErrorLogger = newValue
        }
    }

    /**
     Should be set if the default name "Localizable.strings" are not used.
     */
    public var localizedStringsTableName: String?

    // Undocumented--Xamarin only
    @objc public var closeButtonResource: PreferredButtonResource?
    @objc public var helpButtonResource: PreferredButtonResource?
    @objc public var backToCameraButtonResource: PreferredButtonResource?
    @objc public var backToMenuButtonResource: PreferredButtonResource?
    @objc public var nextButtonResource: PreferredButtonResource?
    @objc public var cancelButtonResource: PreferredButtonResource?

    /**
     Set dictionary of fonts for available text styles. Used internally.
     */
    var textStyleFonts: [UIFont.TextStyle: UIFont] = [
    .largeTitle: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.systemFont(ofSize: 34)),
    .title1: UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.systemFont(ofSize: 28)),
    .title1Bold: UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.boldSystemFont(ofSize: 28)),
    .title2: UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22)),
    .title3: UIFontMetrics(forTextStyle: .title3).scaledFont(for: UIFont.systemFont(ofSize: 20)),
    .caption1: UIFontMetrics(forTextStyle: .caption1).scaledFont(for: UIFont.systemFont(ofSize: 12)),
    .caption2: UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 11)),
    .headline: UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 17)),
    .subheadline: UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.systemFont(ofSize: 15)),
    .body: UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 17)),
    .bodyBold: UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.boldSystemFont(ofSize: 17)),
    .callout: UIFontMetrics(forTextStyle: .callout).scaledFont(for: UIFont.systemFont(ofSize: 16)),
    .calloutBold: UIFontMetrics(forTextStyle: .callout).scaledFont(for: UIFont.boldSystemFont(ofSize: 16)),
    .footnote: UIFontMetrics(forTextStyle: .footnote).scaledFont(for: UIFont.systemFont(ofSize: 13)),
    .footnoteBold: UIFontMetrics(forTextStyle: .footnote).scaledFont(for: UIFont.boldSystemFont(ofSize: 13))
    ]

    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be assosiated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
    */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        textStyleFonts[textStyle] = font
    }

    var documentService: DocumentServiceProtocol?

    // swiftlint:disable function_parameter_count
     /// Function for clean up
     /// - Parameters:
     ///   - paymentRecipient: paymentRecipient description
     ///   - paymentReference: paymentReference description
     ///   - iban: iban description
     ///   - bic: bic description
     ///   - amountToPay: amountToPay description
    // swiftlint:disable line_length
    @available(*, deprecated, message: "Please use sendTransferSummary() to provide the required transfer summary first (if the user has completed TAN verification) and then cleanup() to let the SDK free up used resources")
    // swiftlint:enable line_length
    public func cleanup(paymentRecipient: String,
                        paymentReference: String,
                        paymentPurpose: String,
                        iban: String,
                        bic: String,
                        amountToPay: ExtractionAmount) {
        guard let documentService = documentService else { return }

        let updatedExtractions = buildPaymentExtractions(paymentRecipient,
                                                         paymentReference,
                                                         paymentPurpose,
                                                         iban,
                                                         bic,
                                                         amountToPay)

        documentService.sendFeedback(with: updatedExtractions, updatedCompoundExtractions: nil)

        documentService.resetToInitialState()
        self.documentService = nil
    }

    private func buildPaymentExtractions(_ paymentRecipient: String,
                                         _ paymentReference: String,
                                         _ paymentPurpose: String,
                                         _ iban: String,
                                         _ bic: String,
                                         _ amountToPay: ExtractionAmount) -> [Extraction] {

        let formattedPriceValue = amountToPay.value.stringValue(withDecimalPoint: 2) ?? "\(amountToPay.value)"
        let amountToPayString = "\(formattedPriceValue)" + ":" + amountToPay.currency.rawValue

        let paymentRecipientExtraction = Extraction(box: nil,
                                                    candidates: nil,
                                                    entity: "companyname",
                                                    value: paymentRecipient,
                                                    name: "paymentRecipient")
        let paymentReferenceExtraction = Extraction(box: nil,
                                                    candidates: nil,
                                                    entity: "reference",
                                                    value: paymentReference,
                                                    name: "paymentReference")
        let paymentPurposeExtraction = Extraction(box: nil,
                                                  candidates: nil,
                                                  entity: "text",
                                                  value: paymentPurpose,
                                                  name: "paymentPurpose")
        let ibanExtraction = Extraction(box: nil,
                                        candidates: nil,
                                        entity: "iban",
                                        value: iban,
                                        name: "iban")
        let bicExtraction = Extraction(box: nil,
                                       candidates: nil,
                                       entity: "bic",
                                       value: bic,
                                       name: "bic")
        let amountExtraction = Extraction(box: nil,
                                          candidates: nil,
                                          entity: "amount",
                                          value: amountToPayString,
                                          name: "amountToPay")
        return [paymentRecipientExtraction,
                paymentReferenceExtraction,
                paymentPurposeExtraction,
                ibanExtraction,
                bicExtraction,
                amountExtraction]
    }
    // swiftlint:enable function_parameter_count

    /**
     Enum that represents entry points used for launching the SDK.
    */
    public enum GiniEntryPoint: Int {
        // Must be used when the user launches the SDK from a button.
        case button
        // Must be used when the user launches the SDK from a text field.
        case field

        var stringValue: String {
            switch self {
            case .button:
                return "button"
            case .field:
                return "field"
            }
        }
    }

    /**
     Set the entry point used for launching the Gini Capture SDK.
     Default value is `GiniEntryPoint.button`.
     */
    public var entryPoint: GiniEntryPoint = .button

    // MARK: - Transfer summary sending and cleanup

    /**
     Function for transfer summary.
     Provides transfer summary to Gini.
     Please provide the required transfer summary to improve the future extraction accuracy.

     Please follow the recommendations below:
     - Make sure to call this method before calling `cleanup()` if the user has completed TAN verification.
     - Provide values for all necessary fields, including those that were not extracted.
     - Provide the final data approved by the user (and not the initially extracted only).
     - Send the transfer summary after TAN verification and provide the extraction values the user has used.

     - parameter paymentRecipient: paymentRecipient description
     - parameter paymentReference: paymentReference description
     - parameter iban: iban description
     - parameter bic: bic description
     - parameter amountToPay: amountToPay description
     */
    public func sendTransferSummary(paymentRecipient: String,
                                    paymentReference: String,
                                    paymentPurpose: String,
                                    iban: String,
                                    bic: String,
                                    amountToPay: ExtractionAmount) {
        guard let documentService = documentService else { return }

        let updatedExtractions = buildPaymentExtractions(paymentRecipient,
                                                         paymentReference,
                                                         paymentPurpose,
                                                         iban,
                                                         bic,
                                                         amountToPay)

        documentService.sendFeedback(with: updatedExtractions, updatedCompoundExtractions: nil)
    }

    /**
     Frees up resources used by the capture flow.
     */
    public func cleanup() {
        guard let documentService = documentService else { return }
        documentService.resetToInitialState()
        self.documentService = nil
    }
}
