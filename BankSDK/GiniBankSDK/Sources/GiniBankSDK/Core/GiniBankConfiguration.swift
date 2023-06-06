//
// GiniBankConfiguration.swift
// GiniBank
//
//  Created by Nadya Karaban on 11.03.21.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

public final class GiniBankConfiguration: NSObject {

    /**
     Singleton to make configuration internally accessible in all classes of the Gini Bank SDK.
     */
    public static var shared = GiniBankConfiguration()

    /**
     Indicates whether the Return Assistant feature is enabled or not. In case of `true`,
     the user will be presented with a digital representation of their invoice where they
     can see individual line items and are able to amend them or choose to not to pay for them.
    */
    @objc public var returnAssistantEnabled = true

    /**
     Returns a `GiniBankConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Bank SDK.

     - returns: Instance of `GiniBankConfiguration`.
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
     Can be turned on during development to unlock extra information and to save captured images to camera roll.

     - warning: Should never be used outside of a development enviroment.
     */
    @objc public var debugModeOn = false

    /**
     Used to handle all the logging messages in order to log them in a different way.
     */
    @objc public var logger: GiniLogger = GiniConfiguration.shared.logger

    /**
     Indicates whether the multipage feature is enabled or not. In case of `true`,
     multiple pages can be processed, showing a different review screen when capturing.
     */
    @objc public var multipageEnabled = false

    /**
     Sets the custom navigation view controller as a root view controller for Gini Bank SDK screens.
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
     Indicates the status bar style in the Gini Bank SDK.
     */
    @objc public var statusBarStyle = UIStatusBarStyle.lightContent

    // MARK: Camera options

    /**
     Set the types supported by the file import feature. `GiniCaptureImportFileTypes.none` by default.
     */
    @objc public var fileImportSupportedTypes = GiniConfiguration.GiniCaptureImportFileTypes.none

    /**
     Indicates whether the flash toggle should be shown in the camera screen.
     */
    @objc public var flashToggleEnabled = false

    /**
     When the flash toggle is enabled, this flag indicates if the flash is on by default.
     */
    @objc public var flashOnByDefault = true

    // MARK: Onboarding screens

    /**
     Indicates whether the onboarding screen should be presented at each start of the Gini Bank SDK.
     */
    @objc public var onboardingShowAtLaunch = false

    /**
     Indicates whether the onboarding screen should be presented at the first
     start of the Gini Bank SDK. It is advised to do so.

     - note: Overwrites `onboardingShowAtLaunch` for the first launch.
     */
    @objc public var onboardingShowAtFirstLaunch = true

    /**
     Set custom onboarding pages
     - note: For your convenience we provide the `OnboardingPage` struct.
     */
    public var customOnboardingPages: [OnboardingPage]?

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
     * Set an adapter implementation to show a custom illustration on the return assistant onboarding page.
     */
   public var digitalInvoiceOnboardingIllustrationAdapter: OnboardingIllustrationAdapter?

    /**
     Enable/disable the bottom navigation bar.
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
      * Set an adapter implementation to show a custom bottom navigation bar on the onboarding screen.
     */
    public var onboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the review screen.
     */
    public var reviewNavigationBarBottomAdapter: ReviewScreenBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the image picker screen.
     */
    public var imagePickerNavigationBarBottomAdapter: ImagePickerBottomNavigationBarAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the digital invoice help screen
     */
    public var digitalInvoiceHelpNavigationBarBottomAdapter: DigitalInvoiceHelpNavigationBarBottomAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the digital invoice onboarding screen.
     */
    public var digitalInvoiceOnboardingNavigationBarBottomAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter?

    /**
      * Set an adapter implementation to show a custom bottom navigation bar on the digital invoice overview screen.
     */
    public var digitalInvoiceNavigationBarBottomAdapter: DigitalInvoiceNavigationBarBottomAdapter?

    /**
     * Set an adapter implementation to show a custom loading indicator on the buttons which support loading.
     */
    public var onButtonLoadingIndicator: OnButtonLoadingIndicatorAdapter?

    // MARK: Help screens
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
     Shows the return reasons dialog.
     */
    @objc public var enableReturnReasons: Bool = true

    /**
     * Set an adapter implementation to show a custom loading indicator on the document analysis screen.
     */
    public var customLoadingIndicator: CustomLoadingIndicatorAdapter?

    // MARK: Button configuration options
    /**
     * Cnfiguration used to define the appearance of the primary button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for buttons in different screens: `Onboarding`, `Review`, `Digital Invoice Onboarding`, `Digital Invoice Overview`, `No Results`, `Error`.
     */
    public lazy var primaryButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .GiniBank.accent1,
                                borderColor: .clear,
                                titleColor: .GiniBank.light1,
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)
    /**
     * Configuration used to define the appearance of the secondary button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for buttons in different screens: `No Results`, `Error`.
     */
    public lazy var secondaryButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .GiniBank.dark4,
                                borderColor: GiniColor(light: UIColor.GiniBank.light6,
                                                      dark: UIColor.clear).uiColor(),
                                titleColor: GiniColor(light: UIColor.GiniBank.dark6,
                                                      dark: UIColor.GiniBank.light1).uiColor(),
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 2,
                                shadowRadius: 14,
                                withBlurEffect: true)
    /**
     * Configuration used to define the appearance of the transparent button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used in Onboarding screen in the bottom navigation bar.
     */
    public lazy var transparentButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: .GiniBank.accent1,
                                shadowColor: .clear,
                                cornerRadius: 16,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)
    /**
     * Configuration used to define the appearance of the camera buttons, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for browse and flash buttons in Camera screen.
     */
    public lazy var cameraControlButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: .GiniBank.light1,
                                shadowColor: .clear,
                                cornerRadius: 0,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)
    /**
     *  Configuration used to define the appearance of the "Add Page" button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used in Review screen.
     */
    public lazy var addPageButtonConfiguration: ButtonConfiguration =
            ButtonConfiguration(backgroundColor: .clear,
                                borderColor: .clear,
                                titleColor: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light2).uiColor(),
                                shadowColor: .clear,
                                cornerRadius: 0,
                                borderWidth: 0,
                                shadowRadius: 0,
                                withBlurEffect: false)
    /**
     Set an array of additional custom help menu items. Those items will be presented as table view cells on the help menu screen. By selecting the cell the user will be redirected to the page, which represented by viewController provided by customer during the `HelpMenuViewController.Item` initialization.
    */
    public var customMenuItems: [HelpMenuItem] = []

    /**
     Sets if the default error logging implementation is on.
     */
    public var giniErrorLoggerIsOn: Bool = true

    /**
     Should be set if the custom error logging is implemented.
     */
    public var customGiniErrorLoggerDelegate: GiniCaptureErrorLoggerDelegate?

    /**
     Should be set if the default name "Localizable.strings" are not used.
     */
    public var localizedStringsTableName: String?

    /**
     Set dictionary of fonts for available text styles. Used internally.
     */
    var textStyleFonts: [UIFont.TextStyle: UIFont] = [
    .largeTitle: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.systemFont(ofSize: 34)),
    .title1: UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.systemFont(ofSize: 28)),
    .title1Bold: UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.boldSystemFont(ofSize: 28)),
    .title2: UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22)),
    .title2Bold: UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.boldSystemFont(ofSize: 22)),
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

    // swiftlint:disable function_body_length
    public func captureConfiguration() -> GiniConfiguration {
        let configuration = GiniConfiguration.shared
        configuration.customDocumentValidations = self.customDocumentValidations

        configuration.debugModeOn = self.debugModeOn

        configuration.logger = self.logger

        configuration.multipageEnabled = self.multipageEnabled
        configuration.customNavigationController = self.customNavigationController

        configuration.openWithEnabled = self.openWithEnabled

        configuration.qrCodeScanningEnabled = self.qrCodeScanningEnabled
        configuration.onlyQRCodeScanningEnabled = self.onlyQRCodeScanningEnabled

        configuration.statusBarStyle = self.statusBarStyle

        configuration.fileImportSupportedTypes = self.fileImportSupportedTypes

        configuration.flashToggleEnabled = self.flashToggleEnabled
        configuration.flashOnByDefault = self.flashOnByDefault

        configuration.bottomNavigationBarEnabled = self.bottomNavigationBarEnabled
        configuration.cameraNavigationBarBottomAdapter = self.cameraNavigationBarBottomAdapter
        configuration.helpNavigationBarBottomAdapter = self.helpNavigationBarBottomAdapter
        configuration.reviewNavigationBarBottomAdapter = self.reviewNavigationBarBottomAdapter
        configuration.imagePickerNavigationBarBottomAdapter = self.imagePickerNavigationBarBottomAdapter

        configuration.onboardingShowAtLaunch = self.onboardingShowAtLaunch
        configuration.onboardingShowAtFirstLaunch = self.onboardingShowAtFirstLaunch
        configuration.onboardingAlignCornersIllustrationAdapter = self.onboardingAlignCornersIllustrationAdapter
        configuration.onboardingLightingIllustrationAdapter = self.onboardingLightingIllustrationAdapter
        configuration.onboardingQRCodeIllustrationAdapter = self.onboardingQRCodeIllustrationAdapter
        configuration.onboardingMultiPageIllustrationAdapter = self.onboardingMultiPageIllustrationAdapter
        configuration.onboardingNavigationBarBottomAdapter = self.onboardingNavigationBarBottomAdapter

        configuration.onButtonLoadingIndicator = self.onButtonLoadingIndicator

        configuration.shouldShowSupportedFormatsScreen = self.shouldShowSupportedFormatsScreen

        configuration.openWithAppNameForTexts = self.openWithAppNameForTexts

        configuration.shouldShowDragAndDropTutorial = self.shouldShowDragAndDropTutorial

        configuration.customMenuItems = self.customMenuItems

        configuration.giniErrorLoggerIsOn = self.giniErrorLoggerIsOn
        configuration.customGiniErrorLoggerDelegate = self.customGiniErrorLoggerDelegate

        configuration.customLoadingIndicator = self.customLoadingIndicator

        configuration.localizedStringsTableName = self.localizedStringsTableName

        for textStyle in UIFont.TextStyle.allCases {
            if let newFont = textStyleFonts[textStyle] {
                configuration.updateFont(newFont, for: textStyle)
            }
        }

        configuration.primaryButtonConfiguration = self.primaryButtonConfiguration
        configuration.secondaryButtonConfiguration = self.secondaryButtonConfiguration
        configuration.transparentButtonConfiguration = self.transparentButtonConfiguration
        configuration.addPageButtonConfiguration = self.addPageButtonConfiguration
        configuration.cameraControlButtonConfiguration = self.cameraControlButtonConfiguration

        GiniCapture.setConfiguration(configuration)

        // Set onboarding pages after setting the GiniCapture's configuration
        // because the onboarding page initialisers need the configuration
        configuration.onboardingAlignCornersIllustrationAdapter = self.onboardingAlignCornersIllustrationAdapter

        return configuration
    }
    // swiftlint:enable function_body_length

    /**
     Sets the configuration flags back. Used only in the example app. See `SettingsViewController` for the details.
     */
    public func updateConfiguration(withCaptureConfiguration configuration: GiniConfiguration) {

        let giniBankConfiguration = GiniBankConfiguration.shared

        giniBankConfiguration.debugModeOn = configuration.debugModeOn

        giniBankConfiguration.multipageEnabled = configuration.multipageEnabled

        giniBankConfiguration.openWithEnabled = configuration.openWithEnabled

        giniBankConfiguration.qrCodeScanningEnabled = configuration.qrCodeScanningEnabled

        giniBankConfiguration.onlyQRCodeScanningEnabled = configuration.onlyQRCodeScanningEnabled

        giniBankConfiguration.fileImportSupportedTypes = configuration.fileImportSupportedTypes

        giniBankConfiguration.flashToggleEnabled = configuration.flashToggleEnabled
        giniBankConfiguration.flashOnByDefault = configuration.flashOnByDefault

        giniBankConfiguration.onboardingShowAtLaunch = configuration.onboardingShowAtLaunch
        giniBankConfiguration.onboardingShowAtFirstLaunch = configuration.onboardingShowAtFirstLaunch
        giniBankConfiguration.shouldShowSupportedFormatsScreen = configuration.shouldShowSupportedFormatsScreen

        giniBankConfiguration.shouldShowDragAndDropTutorial = configuration.shouldShowDragAndDropTutorial
        giniBankConfiguration.bottomNavigationBarEnabled = configuration.bottomNavigationBarEnabled

        giniBankConfiguration.primaryButtonConfiguration = configuration.primaryButtonConfiguration
        giniBankConfiguration.secondaryButtonConfiguration = configuration.secondaryButtonConfiguration
        giniBankConfiguration.transparentButtonConfiguration = configuration.transparentButtonConfiguration
        giniBankConfiguration.cameraControlButtonConfiguration = configuration.cameraControlButtonConfiguration
        giniBankConfiguration.addPageButtonConfiguration = configuration.addPageButtonConfiguration
    }

    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be assosiated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
    */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        textStyleFonts[textStyle] = font
    }

    var documentService: DocumentServiceProtocol?
    var lineItems: [[Extraction]]?

    // swiftlint:disable function_parameter_count
    /// Function for clean up
    /// - Parameters:
    ///   - paymentRecipient: paymentRecipient description
    ///   - paymentReference: paymentReference description
    ///   - iban: iban description
    ///   - bic: bic description
    ///   - amountToPay: amountToPay description
    public func cleanup(paymentRecipient: String,
                        paymentReference: String,
                        paymentPurpose: String,
                        iban: String,
                        bic: String,
                        amountToPay: ExtractionAmount) {
        guard let documentService = documentService else { return }

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

        let updatedExtractions: [Extraction] = [paymentRecipientExtraction,
                                                paymentReferenceExtraction,
                                                paymentPurposeExtraction,
                                                ibanExtraction,
                                                bicExtraction,
                                                amountExtraction]

        if let lineItems = lineItems {
            documentService.sendFeedback(with: updatedExtractions,
                                         updatedCompoundExtractions: ["lineItems": lineItems])
        } else {
            documentService.sendFeedback(with: updatedExtractions,
                                         updatedCompoundExtractions: nil)
        }

        documentService.resetToInitialState()
        self.documentService = nil
        self.lineItems = nil
    }
    // swiftlint:enable function_parameter_count
}
