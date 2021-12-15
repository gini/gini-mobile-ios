//
// GiniBankConfiguration.swift
// GiniBank
//
//  Created by Nadya Karaban on 11.03.21.
//

import UIKit
import GiniCaptureSDK

public final class GiniBankConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Pay Bank SDK.
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
    public override init() {}
    
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

    @objc public var logger: GiniLogger = GiniConfiguration().logger
    
    /**
     Indicates whether the multipage feature is enabled or not. In case of `true`,
     multiple pages can be processed, showing a different review screen when capturing.
     */
    @objc public var multipageEnabled = false
    
    /**
     Sets the tint color of the navigation bar in all screens of the Gini Pay Bank SDK to
     the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarTintColor = UINavigationBar.appearance().barTintColor ?? Colors.Gini.raspberry
    
    /**
     Sets the tint color of all navigation items in all screens of the Gini Pay Bank SDK to
     the globally specified color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarItemTintColor = UINavigationBar.appearance().tintColor
    
    /**
     Sets the font of all navigation items in all screens of the Gini Pay Bank SDK to
     the globally specified font or a default font.
     
     - note: Screen API only.
     */
    @objc public var navigationBarItemFont = UIBarButtonItem.appearance()
        .titleTextAttributes(for: .normal).dictionary?[NSAttributedString.Key.font.rawValue] as? UIFont ??
        UIFont.systemFont(ofSize: 16, weight: .bold)
    
    /**
     Sets the title color in the navigation bar in all screens of the Gini Pay Bank SDK to
     the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarTitleColor = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .white
    
    /**
     Sets the title font in the navigation bar in all screens of the Gini Pay Bank SDK to
     the globally specified font or to a default font.

     - note: Screen API only.
     */
    @objc public var navigationBarTitleFont = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedString.Key.font] as? UIFont ?? UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /**
     Sets the tint color of the UIDocumentPickerViewController navigation bar.
     
     - note: Use only if you have a custom `UIAppearance` for your UINavigationBar
     - note: Only iOS >= 11.0
     */
    @objc public var documentPickerNavigationBarTintColor: UIColor?
    
    /**
     Sets the background color of an informal notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeInformationBackgroundColor = UIColor.black
    
    /**
     Sets the text color of an informal notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeInformationTextColor = UIColor.white
    
    /**
     Sets the background color of an error notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeErrorBackgroundColor = UIColor.red
    
    /**
     Sets the text color of an error notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeErrorTextColor = UIColor.white
    
    /**
     Indicates whether the open with feature is enabled or not. In case of `true`,
     a new option with the open with tutorial wil be shown in the Help menu
     */
    @objc public var openWithEnabled = false
    
    /**
     Indicates whether the QR Code scanning feature is enabled or not.
     */
    @objc public var qrCodeScanningEnabled = false
    
    /**
     Indicates the status bar style in the Gini Pay Bank SDK.
     
     - note: If `UIViewControllerBasedStatusBarAppearance` is set to `false` in the `Info.plist`,
     it may not work in future versions of iOS since the `UIApplication.setStatusBarStyle` method was
     deprecated on iOS 9.0
     */
    @objc public var statusBarStyle = UIStatusBarStyle.lightContent
    
    // MARK: Camera options
    
    /**
     Sets the text color of the descriptional text when camera access was denied.
     */
    @objc public var cameraNotAuthorizedTextColor = UIColor.white
    
    /**
     Sets the text color of the button title when camera access was denied.
     */
    @objc public var cameraNotAuthorizedButtonTitleColor = UIColor.white
    
    /**
     Sets the color of camera preview corner guides
     */
    @objc public var cameraPreviewCornerGuidesColor = UIColor.white
    
    /**
     Set the types supported by the file import feature. `GiniCaptureImportFileTypes.none` by default
     
     */
    @objc public var fileImportSupportedTypes = GiniConfiguration.GiniCaptureImportFileTypes.none
    
    /**
     Sets the background color of the new file import button hint
     */
    @objc public var fileImportToolTipBackgroundColor = UIColor.white
    
    /**
     Sets the text color of the new file import button hint
     */
    @objc public var fileImportToolTipTextColor = UIColor.black
    
    /**
     Sets the text color of the new file import button hint
     */
    @objc public var fileImportToolTipCloseButtonColor = Colors.Gini.grey
    
    /**
     Sets the background style when the tooltip is shown
     */
    public var toolTipOpaqueBackgroundStyle: OpaqueViewStyle {
        
        set {
            _toolTipOpaqueBackgroundStyle = newValue
        }
        
        get {
            
            if let setValue = _toolTipOpaqueBackgroundStyle {
                return setValue
            } else {
                
                if #available(iOS 13.0, *) {
                    return .blurred(style: .regular)
                } else {
                    return .blurred(style: .dark)
                }
            }
        }
    }
    
    private var _toolTipOpaqueBackgroundStyle: OpaqueViewStyle?
    
    /**
     Sets the text color of the item selected background check
     */
    @objc public var galleryPickerItemSelectedBackgroundCheckColor = Colors.Gini.blue
    
    /**
     Sets the background color for gallery screen.
     */
    
    @objc public var galleryScreenBackgroundColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
    
    /**
     Indicates whether the flash toggle should be shown in the camera screen.
     
     */
    @objc public var flashToggleEnabled = false
    
    /**
     When the flash toggle is enabled, this flag indicates if the flash is on by default.
     */
    @objc public var flashOnByDefault = true
    
    /**
     Sets the color of the captured images stack indicator label
     */
    @objc public var imagesStackIndicatorLabelTextcolor: UIColor = Colors.Gini.blue
    
    /**
     Sets the close button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarCameraTitleCloseButton = ""
    
    /**
     Sets the help button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarCameraTitleHelpButton = ""
    
    /**
     Sets the text color of the QR Code popup button
     */
    @objc public var qrCodePopupButtonColor = Colors.Gini.blue
    
    /**
     Sets the text color of the QR Code popup label
     */
    @objc public var qrCodePopupTextColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
    /**
     Sets the text color of the QR Code popup background
     */
    @objc public var qrCodePopupBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: UIColor.from(hex: 0x1c1c1e))
    
    // MARK: Onboarding screens

    /**
     Sets the continue button text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarOnboardingTitleContinueButton = ""
    
    /**
     Sets the color of the page controller's page indicator items.
     */
    @objc public var onboardingPageIndicatorColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the color of the page controller's current page indicator item.
     */
    @objc public var onboardingCurrentPageIndicatorColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets alpha to the color of the page controller's current page indicator item.
     */
    @objc public var onboardingCurrentPageIndicatorAlpha: CGFloat = 0.2
    
    /**
     Indicates whether the onboarding screen should be presented at each start of the Gini Pay Bank SDK.
     
     - note: Screen API only.
     */
    @objc public var onboardingShowAtLaunch = false
    
    /**
     Indicates whether the onboarding screen should be presented at the first
     start of the Gini Pay Bank SDK. It is advised to do so.
     
     - note: Overwrites `onboardingShowAtLaunch` for the first launch.
     - note: Screen API only.
     */
    @objc public var onboardingShowAtFirstLaunch = true
    
    /**
     Sets the color ot the text for all onboarding pages.
     */
    @objc public var onboardingTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the background color for all onboarding pages.
     */
        
    @objc public var onboardingScreenBackgroundColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
    
    /**
     All onboarding pages which will be presented in a horizontal scroll view to the user.
     By default the Gini Pay Bank SDK comes with three pages advising the user to keep the
     document flat, hold the device parallel and capture the whole document.
     
     - note: Any array of views can be passed, but for your convenience we provide the `GINIOnboardingPage` class.
     */
    @objc public var onboardingPages: [UIView] {
        get {
            if let pages = onboardingCustomPages {
                return pages
            }
            guard let page1 = OnboardingPage(imageNamed: "onboardingPage1",
                                             text: .localized(resource: OnboardingStrings.onboardingFirstPageText),
                                             rotateImageInLandscape: true),
                let page2 = OnboardingPage(imageNamed: "onboardingPage2",
                                           text: .localized(resource: OnboardingStrings.onboardingSecondPageText)),
                let page3 = OnboardingPage(imageNamed: "onboardingPage3",
                                           text: .localized(resource: OnboardingStrings.onboardingThirdPageText)),
                let page4 = OnboardingPage(imageNamed: "onboardingPage5",
                                           text: .localized(resource: OnboardingStrings.onboardingFifthPageText)) else {
                    return [UIView]()
            }
            
            onboardingCustomPages = [page1, page2, page3, page4]
            if let ipadTipPage = OnboardingPage(imageNamed: "onboardingPage4",
                                                text: .localized(resource: OnboardingStrings.onboardingFourthPageText)),
                UIDevice.current.isIpad {
                onboardingCustomPages?.insert(ipadTipPage, at: 0)
            }
            return onboardingCustomPages!
        }
        set {
            self.onboardingCustomPages = newValue
        }
    }
    fileprivate var onboardingCustomPages: [UIView]?
    
    /**
     Sets the back button text in the navigation bar on the review screen. Use this if you only want to show the title.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleBackButton = ""
    
    /**
     Sets the close button text in the navigation bar on the review screen. Use this if you only want to show the title.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleCloseButton = ""
    
    /**
     Sets the continue button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleContinueButton = ""
    
    /**
     Sets the background color of the bottom section on the review screen containing the rotation button.
     
     - note: Background will have a 20% transparency, to have enough space for the document image on smaller devices.
     */
    @objc public var reviewBottomViewBackgroundColor = UIColor.black
    
    /**
     Sets the font of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomFont = UIFont.systemFont(ofSize: 12, weight: .thin)
    
    /**
     Sets the color of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomColor = UIColor.white
    
    // MARK: Multipage options
    
    /**
     Sets the color of the pages container and toolbar
     */
    @objc public var multipagePagesContainerAndToolBarColor = GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: UIColor.from(hex: 0x1c1c1c))
    
    @objc private var _multipagePagesContainerAndToolBarColor: UIColor?
    
    /**
     Sets the color of the circle indicator
     */
    @objc public var indicatorCircleColor = GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: .lightGray)
    
    /**
     Sets the tint color of the toolbar items
     */
    @objc public var multipageToolbarItemsColor = Colors.Gini.blue
    
    /**
     Sets the tint color of the page indicator
     */
    @objc public var multipagePageIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the background color of the page selected indicator
     */
    @objc public var multipagePageSelectedIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the background color of the page background
     */
    @objc public var multipagePageBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: UIColor.from(hex: 0x1c1c1e))
    
    @objc private var _multipagePageBackgroundColor: UIColor?
    
    /**
     Sets the tint color of the draggable icon in the page collection cell
     */
    @objc public var multipageDraggableIconColor = Colors.Gini.veryLightGray

    /**
     Sets the background style when the tooltip is shown in the multipage screen
     */
    public var multipageToolTipOpaqueBackgroundStyle: OpaqueViewStyle = .blurred(style: .light)
    
    // MARK: Analysis options
    
    /**
     Sets the color of the loading indicator on the analysis screen to the specified color.
     */
    @objc public var analysisLoadingIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationBackgroundColor = Colors.Gini.bluishGreen
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationTextColor = UIColor.white
    
    /**
     Sets the back button text in the navigation bar on the analysis screen. Use this if you only want to show the title.
     
     - note: Screen API only.
     */
    @objc public var navigationBarAnalysisTitleBackButton = ""
    
    // MARK: Help screens
    
    /**
     Sets the background color for all help screens.
     */
    
    @objc public var helpScreenBackgroundColor =  GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: UIColor.from(hex: 0x1C1C1C))
    
    /**
     Sets the background color for the cells on help screen.
     */
    @objc public var helpScreenCellsBackgroundColor =  GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: UIColor.from(hex: 0x1C1C1C))
    
    /**
     Sets the back button text in the navigation bar on the help menu screen. Use this if you only want to show the title.
     
     - note: Screen API only.
     */
    @objc public var navigationBarHelpMenuTitleBackToCameraButton = ""
    
    /**
     Sets the back button text in the navigation bar on the help screen. Use this if you only want to show the title.
     
     - note: Screen API only.
     */
    @objc public var navigationBarHelpScreenTitleBackToMenuButton = ""
    
    /**
     Indicates whether the supported format screens should be shown. In case of `false`,
     the option won't be shown in the Help menu.
     */
    @objc public var shouldShowSupportedFormatsScreen = true
    
    // MARK: Supported formats
    
    /**
     Sets the color of the unsupported formats icon background to the specified color.
     */
    @objc public var nonSupportedFormatsIconColor = Colors.Gini.crimson
    
    /**
     Sets the color of the supported formats icon background to the specified color.
     */
    @objc public var supportedFormatsIconColor = Colors.Gini.paleGreen
    
    // MARK: Open with tutorial options
    
    /**
     Sets the text of the app name for the Open with tutorial texts
     
     */
    @objc public var openWithAppNameForTexts = Bundle.main.appName
    
    /**
     Sets the color of the step indicator for the Open with tutorial
     
     */
    @objc public var stepIndicatorColor = Colors.Gini.blue
    
    // MARK: No results options
    
    /**
     Sets the color of the bottom button to the specified color
     */
    @objc public var noResultsBottomButtonColor = Colors.Gini.blue
    
    /**
     Sets the color of the warning container background to the specified color
     */
    @objc public var noResultsWarningContainerIconColor = Colors.Gini.rose
    
    /**
     Sets if the Drag&Drop step should be shown in the "Open with" tutorial
     */
    @objc public var shouldShowDragAndDropTutorial = true
    
    // Undocumented--Xamarin only
    @objc public var closeButtonResource: PreferredButtonResource?
    @objc public var helpButtonResource: PreferredButtonResource?
    @objc public var backToCameraButtonResource: PreferredButtonResource?
    @objc public var backToMenuButtonResource: PreferredButtonResource?
    @objc public var nextButtonResource: PreferredButtonResource?
    @objc public var cancelButtonResource: PreferredButtonResource?
    
    // MARK: Return Assistant
    
    /**
     Sets the background color for the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenBackgroundColor =  GiniColor(lightModeColor: .white, darkModeColor:.black)
    
    /**
     Sets the text color for the section titles on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenSectionTitleColor =  GiniColor(lightModeColor: Colors.Gini.blue, darkModeColor: Colors.Gini.blue)
    
    /**
     Sets the font for the page title on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenPageTitleFont =  UIFont.systemFont(ofSize: 28, weight: .semibold)
    
    /**
     Sets the font for the section titles on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenSectionTitleFont =  UIFont.systemFont(ofSize: 28, weight: .bold)
    
    /**
     Sets the text color for the instructions on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenInstructionColor =  GiniColor(lightModeColor: .black, darkModeColor:.white)
    
    /**
     Sets the font for the instructions on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenInstructionFont =  UIFont.systemFont(ofSize: 18, weight: .regular)
    
    /**
     Sets the background color for the back button on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenBackButtonColor =  Colors.Gini.blue

    /**
     Sets the title color for the back button on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenBackButtonTitleColor =  GiniColor(lightModeColor: .white, darkModeColor:.black)
    
    /**
     Sets the font for the back button title on the return assistant help screen.
     */
    @objc public var helpReturnAssistantScreenBackButtonTitleFont =  UIFont.systemFont(ofSize: 18, weight: .regular)

        
    // MARK: Digital invoice

    /**
     Sets the color of the active elements on the digital invoice line item cells to the specified color
     */
    @objc public var lineItemTintColor = Colors.Gini.blue
    
    /**
     Sets the color of the active elements on the digital invoice line item count label to the specified color
     */
    @objc public var lineItemCountLabelColor = UIColor.lightGray
    
    /**
     Sets the font of the line item name on the digital invoice  line item count label to the specified font.
     */
    @objc public var lineItemCountLabelFont = UIFont.systemFont(ofSize: 16)
    
    /**
     Sets the font of the line item name on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceLineItemNameFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    /**
     Sets the font of the line item edit button title on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceLineItemEditButtonTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    /**
     Sets the font of the line item label that displays the quantity on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceLineItemQuantityFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    
    /**
     Sets the color of  the line item label that  displays the quantity on the digital invoice line item cells to the specified color
     */
    @objc public var digitalInvoiceLineItemQuantityColor =  GiniColor(lightModeColor: .black, darkModeColor: .white)
    
    /**
     Sets the font of the main currency unit of the price on the line item
     of the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceLineItemPriceMainUnitFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    
    /**
    Sets the font of the fractional currency unit of the price on the line item
    of the digital invoice screen to the specified font.
    */
    @objc public var digitalInvoiceLineItemPriceFractionalUnitFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    
    /**
     Sets the font of the secondary informational message on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceSecondaryMessageTextFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    /**
     Sets the color of the secondary message label on the digital invoice line item cells to the specified color
     */
    @objc public var digitalInvoiceSecondaryMessageTextColor = Colors.Gini.blue
    
    /**
     Sets the background color for digital invoice screen.
     */
    @objc public var digitalInvoiceBackgroundColor =  GiniColor(lightModeColor: .white, darkModeColor: .black)
    
    /**
     Sets the background color for the line items on the digital invoice screen.
     */
    @objc public var digitalInvoiceLineItemsBackgroundColor =  GiniColor(lightModeColor: .white, darkModeColor: .black)
    
    /**
     Sets the font of the footer message on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceFooterMessageTextFont = UIFont.systemFont(ofSize: 14)
    
    /**
     Sets the add article button tint color of the footer section on the digital invoice screen.
     */
    @objc public var digitalInvoiceFooterAddArticleButtonTintColor = Colors.Gini.blue
    
    /**
     Sets the text color of the footer message on the digital invoice screen.
     */
    @objc public var digitalInvoiceFooterMessageTextColor = GiniColor(lightModeColor: .darkGray, darkModeColor:.white)
    
    /**
     Sets the text color of the items section header on the digital invoice screen.
     */
    @objc public var digitalInvoiceItemsSectionHeaderTextColor = GiniColor(lightModeColor: .gray, darkModeColor:.white)

    /**
     Sets the font of the items section header on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceItemsSectionHeaderTextFont = UIFont.systemFont(ofSize: 12)
    
    /**
     Sets the background color of the digital invoice pay button to the specified color
     */
    @objc public var payButtonBackgroundColor = Colors.Gini.blue
    
    /**
     Sets the title text color of the digital invoice pay button to the specified color
     */
    @objc public var payButtonTitleTextColor = UIColor.white
    
    /**
     Sets the title text font of the digital invoice pay button to the specified font
     */
    @objc public var payButtonTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    /**
     Sets the background color of the digital invoice skip button to the specified color
     */
    @objc public var skipButtonBackgroundColor = UIColor.white
    
    /**
     Sets the title text color of the digital invoice skip button to the specified color
     */
    @objc public var skipButtonTitleTextColor = Colors.Gini.blue
    
    /**
     Sets the layer border color of the digital invoice skip button to the specified color
     */
    @objc public var skipButtonBorderColor = Colors.Gini.blue
    
    /**
     Sets the title text font of the digital invoice skip button to the specified font
     */
    @objc public var skipButtonTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    /**
     Sets the font of the addon labels on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceAddonLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    /**
     Sets the font of the total caption label on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceTotalCaptionLabelFont = UIFont.systemFont(ofSize: 32, weight: .semibold)
    
    /**
     Sets the font of the total explanation label on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceTotalExplanationLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /**
     Sets the text color of the explanation label on the digital invoice screen.
     */
    @objc public var digitalInvoiceTotalExplanationLabelTextColor = GiniColor(lightModeColor: .lightGray, darkModeColor: .lightGray)
    
    /**
     Sets the font of the main unit of the addon price labels to the specified font
     */
    @objc public var digitalInvoiceAddonPriceMainUnitFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    
    /**
     Sets the font of the fractional unit of the addon price labels to the specified font
     */
    @objc public var digitalInvoiceAddonPriceFractionalUnitFont = UIFont.systemFont(ofSize: 9, weight: .bold)
    
    /**
     Sets the color of the addon price labels in the digital invoice screen to the specified color
     */
    @objc public var digitalInvoiceAddonPriceColor: UIColor {
        
        set {
            _digitalInvoiceAddonPriceColor = newValue
        }

        get {

            if let setValue = _digitalInvoiceAddonPriceColor {
                return setValue
            } else {

                if #available(iOS 13.0, *) {

                    return .label

                } else {
                    return .black
                }
            }
        }
    }
    
    @objc private var _digitalInvoiceAddonPriceColor: UIColor?
    
    /**
     Sets the color of the total price label in the digital invoice screen to the specified color
     */
    @objc public var digitalInvoiceTotalPriceColor: UIColor {
        
        set {
            _digitalInvoiceTotalPriceColor = newValue
        }

        get {

            if let setValue = _digitalInvoiceTotalPriceColor {
                return setValue
            } else {

                if #available(iOS 13.0, *) {

                    return .label

                } else {
                    return .black
                }
            }
        }
    }
    
    @objc private var _digitalInvoiceTotalPriceColor: UIColor?
    
    /**
     Sets the font of the digital invoice main unit of the total price label to the specified font
     */
    @objc public var digitalInvoiceTotalPriceMainUnitFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    
    /**
     Sets the font of the digital invoice fractional unit of the total price label to the specified font
     */
    @objc public var digitalInvoiceTotalPriceFractionalUnitFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    
    /**
     Sets the font of the content description labels in the line item details view controller to the specified font
     */
    @objc public var lineItemDetailsDescriptionLabelFont = UIFont.systemFont(ofSize: 12)
    
    /**
     Sets the color of the content description labels in the line item details view controller to the specified color
     */
    
    @objc public var lineItemDetailsDescriptionLabelColor: UIColor {
        
        set {
            _lineItemDetailsDescriptionLabelColor = newValue
        }

        get {

            if let setValue = _lineItemDetailsDescriptionLabelColor {
                return setValue
            } else {

                if #available(iOS 13.0, *) {

                    return .secondaryLabel

                } else {
                    return .gray
                }
            }
        }
    }
    
    /**
     Sets the background color for  the line item details view.
     */
    @objc public var lineItemDetailsBackgroundColor =  GiniColor(lightModeColor: .white, darkModeColor: .black)
    
    @objc private var _lineItemDetailsDescriptionLabelColor: UIColor?
    
    /**
     Sets the font of the content labels in the line item details view controller to the specified font
     */
    @objc public var lineItemDetailsContentLabelFont = UIFont.systemFont(ofSize: 15, weight: .medium)
    
    /**
     Sets the color of the content labels in the line item details view controller to the specified color
     */
    @objc public var lineItemDetailsContentLabelColor: UIColor {
        
        set {
            _lineItemDetailsContentLabelColor = newValue
        }

        get {

            if let setValue = _lineItemDetailsContentLabelColor {
                return setValue
            } else {

                if #available(iOS 13.0, *) {

                    return .label

                } else {
                    return .black
                }
            }
        }
    }
    
    @objc private var _lineItemDetailsContentLabelColor: UIColor?
    
    /**
     Sets the font of the line item details screen main unit of the total price label to the specified font
     */
    @objc public var lineItemDetailsTotalPriceMainUnitFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    
    /**
     Sets the font of the line item details screen fractional unit of the total price label to the specified font
     */
    @objc public var lineItemDetailsTotalPriceFractionalUnitFont = UIFont.systemFont(ofSize: 12, weight: .bold)
    
    /**
     Sets the backgroundColor on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingBackgroundColor = GiniColor(lightModeColor: Colors.Gini.blue, darkModeColor: Colors.Gini.blue)
    
    /**
     Sets the color on the digital invoice onboarding screen for text labels
     */
    @objc public var digitalInvoiceOnboardingTextColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)

    /**
     Sets the font of the first text label on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingFirstLabelTextFont = UIFont.systemFont(ofSize: 32, weight: .semibold)
    
    /**
     Sets the font of the second text label on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingSecondLabelTextFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    /**
     Sets the backgroundColor  on the digital invoice onboarding screen for done button
     */
    @objc public var digitalInvoiceOnboardingDoneButtonBackgroundColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)
    
    /**
     Sets the font of the done button on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingDoneButtonTextFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    
    /**
     Sets the font of the hide button on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingHideButtonTextFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    /**
     Sets the text color of the done button on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingDoneButtonTextColor = GiniColor(lightModeColor: Colors.Gini.blue, darkModeColor: Colors.Gini.blue)
    
    /**
     Sets the text color of the done button on the digital invoice onboarding screen
     */
    @objc public var digitalInvoiceOnboardingHideButtonTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the background color of the warning info view on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewBackgroundColor = Colors.Gini.blue
    
    /**
     Sets the  chevron image tint color of the warning info view on the digital invoice screen
     */
    @objc public var  digitalInvoiceInfoViewChevronImageViewTintColor = UIColor.white
    
    /**
     Sets the text color for the warning info view warning labels on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewWarningLabelsTextColor = UIColor.white
    
    /**
     Sets the font for the warning info view top label on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewTopLabelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    
    /**
     Sets the font for the warning info view middle label on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewMiddleLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /**
     Sets the font for the warning info view bottom label on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewBottomLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /**
     Sets the background color for the warning info left button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewLeftButtonBackgroundColor = UIColor.white
    
    /**
     Sets the border color for the warning info left button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewLeftButtonBorderColor = UIColor.white
    
    /**
     Sets the title color for the warning info left button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewLeftkButtonTitleColor = Colors.Gini.blue
    
    /**
     Sets the background color for the warning info right button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewRightButtonBackgroundColor = UIColor.clear
    
    /**
     Sets the border color for the warning info right button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewRightButtonBorderColor = UIColor.white
    
    /**
     Sets the title color for the warning info right button on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewRightButtonTitleColor = UIColor.white
    
    /**
     Sets the font for the warning info buttons on the digital invoice screen
     */
    @objc public var digitalInvoiceInfoViewButtonsFont = UIFont.systemFont(ofSize: 16)
    
    /**
     Sets the font used in the Return Assistant screens by default.
     */
    
    @objc public lazy var customFont = GiniCaptureFont(regular: UIFont.systemFont(ofSize: 14,
                                                                                                 weight: .regular),
                                                                      bold: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .bold),
                                                                      light: UIFont.systemFont(ofSize: 14,
                                                                                               weight: .light),
                                                                      thin: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .thin),
                                                                      isEnabled: false)
    /**
     Set an array of additional custom help menu items . Those items will be presented as table view cells on the help menu screen. By selecting the cell the user will be redirected to the page, which represented by viewController provided by customer during the  `HelpMenuViewController.Item` initialization.
    */
    public var customMenuItems: [HelpMenuViewController.Item] = []
    
    /**
     Sets if the default error logging implementation is on
     */
    public var giniErrorLoggerIsOn: Bool = true
    
    /**
     Should sets if the custom error logging is implemented
     */
    public var customGiniErrorLoggerDelegate : GiniCaptureErrorLoggerDelegate?
    
    /**
     Should be set if the default name "Localizable.strings" are not used
     */
    public var localizedStringsTableName: String?
    
    public func captureConfiguration() -> GiniConfiguration {
     let configuration = GiniConfiguration()
        
        configuration.customDocumentValidations = self.customDocumentValidations
        
        configuration.customFont = self.customFont
        
        configuration.debugModeOn = self.debugModeOn
        
        configuration.logger = self.logger
        
        configuration.multipageEnabled = self.multipageEnabled

        configuration.navigationBarTintColor = self.navigationBarTintColor
        configuration.navigationBarItemTintColor = self.navigationBarItemTintColor
        configuration.navigationBarItemFont = self.navigationBarItemFont
        configuration.navigationBarTitleColor = self.navigationBarTitleColor
        configuration.navigationBarTitleFont = self.navigationBarTitleFont
        
        configuration.documentPickerNavigationBarTintColor = self.documentPickerNavigationBarTintColor

        configuration.noticeInformationBackgroundColor = self.noticeInformationBackgroundColor
        
        configuration.noticeInformationTextColor = self.noticeInformationTextColor
        configuration.noticeErrorBackgroundColor = self.noticeErrorBackgroundColor
        configuration.noticeErrorTextColor = self.noticeErrorTextColor
        
        configuration.openWithEnabled = self.openWithEnabled
        
        configuration.qrCodeScanningEnabled = self.qrCodeScanningEnabled
        
        configuration.statusBarStyle = self.statusBarStyle
        
        configuration.cameraNotAuthorizedTextColor = self.cameraNotAuthorizedTextColor
        configuration.cameraNotAuthorizedButtonTitleColor = self.cameraNotAuthorizedButtonTitleColor
        configuration.cameraPreviewCornerGuidesColor = self.cameraPreviewCornerGuidesColor
        
        configuration.fileImportSupportedTypes = self.fileImportSupportedTypes
        configuration.fileImportToolTipBackgroundColor = self.fileImportToolTipBackgroundColor
        configuration.fileImportToolTipTextColor = self.fileImportToolTipTextColor
        configuration.fileImportToolTipCloseButtonColor = self.fileImportToolTipCloseButtonColor
        
        configuration.toolTipOpaqueBackgroundStyle = self.toolTipOpaqueBackgroundStyle

        configuration.galleryPickerItemSelectedBackgroundCheckColor = self.galleryPickerItemSelectedBackgroundCheckColor
        configuration.galleryScreenBackgroundColor = self.galleryScreenBackgroundColor
        
        configuration.flashToggleEnabled = self.flashToggleEnabled
        configuration.flashOnByDefault = self.flashOnByDefault
        
        configuration.imagesStackIndicatorLabelTextcolor = self.imagesStackIndicatorLabelTextcolor
        
        configuration.navigationBarCameraTitleCloseButton = self.navigationBarCameraTitleCloseButton
        configuration.navigationBarCameraTitleHelpButton = self.navigationBarCameraTitleHelpButton
        
        configuration.qrCodePopupButtonColor = self.qrCodePopupButtonColor
        configuration.qrCodePopupTextColor = self.qrCodePopupTextColor
        configuration.qrCodePopupBackgroundColor = self.qrCodePopupBackgroundColor
        
        configuration.navigationBarOnboardingTitleContinueButton = self.navigationBarOnboardingTitleContinueButton
        
        configuration.onboardingPageIndicatorColor = self.onboardingPageIndicatorColor
        configuration.onboardingCurrentPageIndicatorColor = self.onboardingCurrentPageIndicatorColor
        configuration.onboardingCurrentPageIndicatorAlpha = self.onboardingCurrentPageIndicatorAlpha
        configuration.onboardingShowAtLaunch = self.onboardingShowAtLaunch
        configuration.onboardingShowAtFirstLaunch = self.onboardingShowAtFirstLaunch
        configuration.onboardingTextColor = self.onboardingTextColor
        configuration.onboardingScreenBackgroundColor = self.onboardingScreenBackgroundColor
        configuration.onboardingPages = self.onboardingPages
        
        configuration.navigationBarReviewTitleBackButton = self.navigationBarReviewTitleBackButton
        configuration.navigationBarReviewTitleCloseButton = self.navigationBarReviewTitleCloseButton
        configuration.navigationBarReviewTitleContinueButton = self.navigationBarReviewTitleContinueButton
        
        configuration.reviewBottomViewBackgroundColor = self.reviewBottomViewBackgroundColor
        configuration.reviewTextBottomFont = self.reviewTextBottomFont
        configuration.reviewTextBottomColor = self.reviewTextBottomColor
        
        configuration.indicatorCircleColor = self.indicatorCircleColor
        
        configuration.multipagePagesContainerAndToolBarColor = self.multipagePagesContainerAndToolBarColor
        configuration.multipageToolbarItemsColor = self.multipageToolbarItemsColor
        configuration.multipagePageIndicatorColor = self.multipagePageIndicatorColor
        configuration.multipagePageSelectedIndicatorColor = self.multipagePageSelectedIndicatorColor
        configuration.multipagePageBackgroundColor = self.multipagePageBackgroundColor
        configuration.multipageDraggableIconColor = self.multipageDraggableIconColor
        configuration.multipageToolTipOpaqueBackgroundStyle = self.multipageToolTipOpaqueBackgroundStyle
        
        configuration.analysisLoadingIndicatorColor = self.analysisLoadingIndicatorColor
        configuration.analysisPDFInformationBackgroundColor = self.analysisPDFInformationBackgroundColor
        configuration.analysisPDFInformationTextColor = self.analysisPDFInformationTextColor
        
        configuration.navigationBarAnalysisTitleBackButton = self.navigationBarAnalysisTitleBackButton
        
        configuration.helpScreenBackgroundColor = self.helpScreenBackgroundColor
        configuration.helpScreenCellsBackgroundColor = self.helpScreenCellsBackgroundColor
        
        configuration.navigationBarHelpMenuTitleBackToCameraButton = self.navigationBarHelpMenuTitleBackToCameraButton
        configuration.navigationBarHelpScreenTitleBackToMenuButton = self.navigationBarHelpScreenTitleBackToMenuButton
        
        configuration.shouldShowSupportedFormatsScreen = self.shouldShowSupportedFormatsScreen
        
        configuration.nonSupportedFormatsIconColor = self.nonSupportedFormatsIconColor
        
        configuration.supportedFormatsIconColor = self.supportedFormatsIconColor
        
        configuration.openWithAppNameForTexts = self.openWithAppNameForTexts
        
        configuration.stepIndicatorColor = self.stepIndicatorColor
        
        configuration.noResultsBottomButtonColor = self.noResultsBottomButtonColor
        
        configuration.noResultsWarningContainerIconColor = self.noResultsWarningContainerIconColor
        
        configuration.shouldShowDragAndDropTutorial = self.shouldShowDragAndDropTutorial
        
        configuration.customMenuItems = self.customMenuItems
        
        configuration.giniErrorLoggerIsOn = self.giniErrorLoggerIsOn
        configuration.customGiniErrorLoggerDelegate = self.customGiniErrorLoggerDelegate
        
        // Undocumented--Xamarin only
        configuration.closeButtonResource = self.closeButtonResource
        configuration.helpButtonResource = self.helpButtonResource
        configuration.backToCameraButtonResource = self.helpButtonResource
        configuration.backToMenuButtonResource = self.backToMenuButtonResource
        configuration.nextButtonResource = self.nextButtonResource
        configuration.cancelButtonResource = self.cancelButtonResource
        configuration.localizedStringsTableName = self.localizedStringsTableName
        
        GiniCapture.setConfiguration(configuration)
        return configuration
    }
    
    public func returnAssistantConfiguration() -> ReturnAssistantConfiguration {
     let configuration = ReturnAssistantConfiguration()
        
        configuration.helpReturnAssistantScreenBackgroundColor = self.helpReturnAssistantScreenBackgroundColor
        configuration.helpReturnAssistantScreenSectionTitleColor = self.helpReturnAssistantScreenSectionTitleColor
        configuration.helpReturnAssistantScreenPageTitleFont = self.helpReturnAssistantScreenPageTitleFont
        configuration.helpReturnAssistantScreenSectionTitleFont = self.helpReturnAssistantScreenSectionTitleFont
        configuration.helpReturnAssistantScreenInstructionColor = self.helpReturnAssistantScreenInstructionColor
        configuration.helpReturnAssistantScreenInstructionFont = self.helpReturnAssistantScreenInstructionFont
        configuration.helpReturnAssistantScreenBackButtonColor = self.helpReturnAssistantScreenBackButtonColor
        configuration.helpReturnAssistantScreenBackButtonTitleColor = self.helpReturnAssistantScreenBackButtonTitleColor
        configuration.helpReturnAssistantScreenBackButtonTitleFont = self.helpReturnAssistantScreenBackButtonTitleFont

        configuration.lineItemTintColor = self.lineItemTintColor
        configuration.lineItemCountLabelColor = self.lineItemCountLabelColor
        configuration.lineItemCountLabelFont = self.lineItemCountLabelFont
        
        configuration.digitalInvoiceLineItemNameFont = self.digitalInvoiceLineItemNameFont
        configuration.digitalInvoiceLineItemEditButtonTitleFont = self.digitalInvoiceLineItemEditButtonTitleFont
        configuration.digitalInvoiceLineItemQuantityFont = self.digitalInvoiceLineItemQuantityFont
        configuration.digitalInvoiceLineItemQuantityColor = self.digitalInvoiceLineItemQuantityColor
        configuration.digitalInvoiceLineItemPriceMainUnitFont = self.digitalInvoiceLineItemPriceMainUnitFont
        configuration.digitalInvoiceLineItemPriceFractionalUnitFont = self.digitalInvoiceLineItemPriceFractionalUnitFont
        
        configuration.digitalInvoiceSecondaryMessageTextFont = self.digitalInvoiceSecondaryMessageTextFont
        configuration.digitalInvoiceSecondaryMessageTextColor = self.digitalInvoiceSecondaryMessageTextColor
        configuration.digitalInvoiceBackgroundColor = self.digitalInvoiceBackgroundColor
        configuration.digitalInvoiceLineItemsBackgroundColor = self.digitalInvoiceLineItemsBackgroundColor
        configuration.digitalInvoiceFooterAddArticleButtonTintColor = self.digitalInvoiceFooterAddArticleButtonTintColor
        configuration.digitalInvoiceFooterMessageTextFont = self.digitalInvoiceFooterMessageTextFont
        configuration.digitalInvoiceFooterMessageTextColor = self.digitalInvoiceFooterMessageTextColor
        
        configuration.digitalInvoiceItemsSectionHeaderTextFont = self.digitalInvoiceItemsSectionHeaderTextFont
        configuration.digitalInvoiceItemsSectionHeaderTextColor = self.digitalInvoiceItemsSectionHeaderTextColor
        
        configuration.payButtonBackgroundColor = self.payButtonBackgroundColor
        configuration.payButtonTitleTextColor = self.payButtonTitleTextColor
        configuration.payButtonTitleFont = self.payButtonTitleFont
        
        configuration.skipButtonBackgroundColor = self.skipButtonBackgroundColor
        configuration.skipButtonTitleTextColor = self.skipButtonTitleTextColor
        configuration.skipButtonBorderColor = self.skipButtonBorderColor
        configuration.skipButtonTitleFont = self.skipButtonTitleFont
        
        configuration.digitalInvoiceInfoViewBackgroundColor = self.digitalInvoiceInfoViewBackgroundColor
        configuration.digitalInvoiceInfoViewChevronImageViewTintColor = self.digitalInvoiceInfoViewChevronImageViewTintColor
        configuration.digitalInvoiceInfoViewWarningLabelsTextColor = self.digitalInvoiceInfoViewWarningLabelsTextColor
        configuration.digitalInvoiceInfoViewTopLabelFont = self.digitalInvoiceInfoViewTopLabelFont
        configuration.digitalInvoiceInfoViewMiddleLabelFont = self.digitalInvoiceInfoViewMiddleLabelFont
        configuration.digitalInvoiceInfoViewBottomLabelFont = self.digitalInvoiceInfoViewBottomLabelFont
        configuration.digitalInvoiceInfoViewLeftButtonBackgroundColor = self.digitalInvoiceInfoViewLeftButtonBackgroundColor
        configuration.digitalInvoiceInfoViewLeftButtonBorderColor = self.digitalInvoiceInfoViewLeftButtonBorderColor
        configuration.digitalInvoiceInfoViewLeftkButtonTitleColor = self.digitalInvoiceInfoViewLeftkButtonTitleColor
        configuration.digitalInvoiceInfoViewRightButtonBackgroundColor = self.digitalInvoiceInfoViewRightButtonBackgroundColor
        configuration.digitalInvoiceInfoViewRightButtonBorderColor = self.digitalInvoiceInfoViewRightButtonBorderColor
        configuration.digitalInvoiceInfoViewRightButtonTitleColor = self.digitalInvoiceInfoViewRightButtonTitleColor
        configuration.digitalInvoiceInfoViewButtonsFont = self.digitalInvoiceInfoViewButtonsFont
        
        configuration.digitalInvoiceAddonLabelFont = self.digitalInvoiceAddonLabelFont
        configuration.digitalInvoiceTotalCaptionLabelFont = self.digitalInvoiceTotalCaptionLabelFont
        configuration.digitalInvoiceTotalExplanationLabelFont = self.digitalInvoiceTotalExplanationLabelFont
        configuration.digitalInvoiceTotalExplanationLabelTextColor = self.digitalInvoiceTotalExplanationLabelTextColor
        configuration.digitalInvoiceAddonPriceMainUnitFont = self.digitalInvoiceAddonPriceMainUnitFont
        configuration.digitalInvoiceAddonPriceFractionalUnitFont = self.digitalInvoiceAddonPriceFractionalUnitFont
        configuration.digitalInvoiceAddonPriceColor = self.digitalInvoiceAddonPriceColor
        configuration.digitalInvoiceTotalPriceColor = self.digitalInvoiceTotalPriceColor
        

        configuration.digitalInvoiceTotalPriceMainUnitFont = self.digitalInvoiceTotalPriceMainUnitFont
        configuration.digitalInvoiceTotalPriceFractionalUnitFont = self.digitalInvoiceTotalPriceFractionalUnitFont
        
        configuration.lineItemDetailsDescriptionLabelFont = self.lineItemDetailsDescriptionLabelFont
        configuration.lineItemDetailsDescriptionLabelColor = self.lineItemDetailsDescriptionLabelColor
        configuration.lineItemDetailsBackgroundColor = self.lineItemDetailsBackgroundColor
        configuration.lineItemDetailsContentLabelFont = self.lineItemDetailsContentLabelFont
        configuration.lineItemDetailsContentLabelColor = self.lineItemDetailsContentLabelColor
        configuration.lineItemDetailsTotalPriceMainUnitFont = self.lineItemDetailsTotalPriceMainUnitFont
        configuration.lineItemDetailsTotalPriceFractionalUnitFont = self.lineItemDetailsTotalPriceFractionalUnitFont
        
        configuration.digitalInvoiceOnboardingBackgroundColor = self.digitalInvoiceOnboardingBackgroundColor
        configuration.digitalInvoiceOnboardingTextColor = self.digitalInvoiceOnboardingTextColor
        configuration.digitalInvoiceOnboardingFirstLabelTextFont = self.digitalInvoiceOnboardingFirstLabelTextFont
        configuration.digitalInvoiceOnboardingSecondLabelTextFont = self.digitalInvoiceOnboardingSecondLabelTextFont
        configuration.digitalInvoiceOnboardingDoneButtonBackgroundColor = self.digitalInvoiceOnboardingDoneButtonBackgroundColor
        configuration.digitalInvoiceOnboardingDoneButtonTextFont = self.digitalInvoiceOnboardingDoneButtonTextFont
        configuration.digitalInvoiceOnboardingHideButtonTextFont = self.digitalInvoiceOnboardingHideButtonTextFont
        configuration.digitalInvoiceOnboardingDoneButtonTextColor = self.digitalInvoiceOnboardingDoneButtonTextColor
        configuration.digitalInvoiceOnboardingHideButtonTextColor = self.digitalInvoiceOnboardingHideButtonTextColor
        configuration.customFont = self.customFont
        
        // TODO! Add for Xamarin colors
        
     return configuration
    }
    
    public func updateConfiguration(withCaptureConfiguration configuration: GiniConfiguration) {
        let giniBankConfiguration = GiniBankConfiguration.shared
        giniBankConfiguration.customDocumentValidations = configuration.customDocumentValidations
        
        giniBankConfiguration.customFont = configuration.customFont
        
        giniBankConfiguration.debugModeOn = configuration.debugModeOn
        
        giniBankConfiguration.logger = configuration.logger
        
        giniBankConfiguration.multipageEnabled = configuration.multipageEnabled

        giniBankConfiguration.navigationBarTintColor = configuration.navigationBarTintColor
        giniBankConfiguration.navigationBarItemTintColor = configuration.navigationBarTintColor
        giniBankConfiguration.navigationBarItemFont = configuration.navigationBarItemFont
        giniBankConfiguration.navigationBarTitleColor = configuration.navigationBarTitleColor
        giniBankConfiguration.navigationBarTitleFont = configuration.navigationBarTitleFont
        
        giniBankConfiguration.documentPickerNavigationBarTintColor = configuration.documentPickerNavigationBarTintColor

        giniBankConfiguration.noticeInformationBackgroundColor = configuration.noticeInformationBackgroundColor
        
        giniBankConfiguration.noticeInformationTextColor = configuration.noticeInformationTextColor
        giniBankConfiguration.noticeErrorBackgroundColor = configuration.noticeErrorBackgroundColor
        giniBankConfiguration.noticeErrorTextColor = configuration.noticeErrorTextColor
        
        giniBankConfiguration.openWithEnabled = configuration.openWithEnabled
        
        giniBankConfiguration.qrCodeScanningEnabled = configuration.qrCodeScanningEnabled
        
        giniBankConfiguration.statusBarStyle = configuration.statusBarStyle
        
        giniBankConfiguration.cameraNotAuthorizedTextColor = configuration.cameraNotAuthorizedTextColor
        giniBankConfiguration.cameraNotAuthorizedButtonTitleColor = configuration.cameraNotAuthorizedButtonTitleColor
        giniBankConfiguration.cameraPreviewCornerGuidesColor = configuration.cameraPreviewCornerGuidesColor
        
        giniBankConfiguration.fileImportSupportedTypes = configuration.fileImportSupportedTypes
        giniBankConfiguration.fileImportToolTipBackgroundColor = configuration.fileImportToolTipBackgroundColor
        giniBankConfiguration.fileImportToolTipTextColor = configuration.fileImportToolTipTextColor
        giniBankConfiguration.fileImportToolTipCloseButtonColor = configuration.fileImportToolTipCloseButtonColor
        
        giniBankConfiguration.toolTipOpaqueBackgroundStyle = configuration.toolTipOpaqueBackgroundStyle

        giniBankConfiguration.galleryPickerItemSelectedBackgroundCheckColor = configuration.galleryPickerItemSelectedBackgroundCheckColor
        giniBankConfiguration.galleryScreenBackgroundColor = configuration.galleryScreenBackgroundColor
        
        giniBankConfiguration.flashToggleEnabled = configuration.flashToggleEnabled
        giniBankConfiguration.flashOnByDefault = configuration.flashOnByDefault
        
        giniBankConfiguration.imagesStackIndicatorLabelTextcolor = configuration.imagesStackIndicatorLabelTextcolor
        
        giniBankConfiguration.navigationBarCameraTitleCloseButton = configuration.navigationBarCameraTitleCloseButton
        giniBankConfiguration.navigationBarCameraTitleHelpButton = configuration.navigationBarCameraTitleHelpButton
        
        giniBankConfiguration.qrCodePopupButtonColor = configuration.qrCodePopupButtonColor
        giniBankConfiguration.qrCodePopupTextColor = configuration.qrCodePopupTextColor
        giniBankConfiguration.qrCodePopupBackgroundColor = configuration.qrCodePopupBackgroundColor
        
        giniBankConfiguration.navigationBarOnboardingTitleContinueButton = configuration.navigationBarOnboardingTitleContinueButton
        
        giniBankConfiguration.onboardingPageIndicatorColor = configuration.onboardingPageIndicatorColor
        giniBankConfiguration.onboardingCurrentPageIndicatorColor = configuration.onboardingCurrentPageIndicatorColor
        giniBankConfiguration.onboardingCurrentPageIndicatorAlpha = configuration.onboardingCurrentPageIndicatorAlpha
        giniBankConfiguration.onboardingShowAtLaunch = configuration.onboardingShowAtLaunch
        giniBankConfiguration.onboardingShowAtFirstLaunch = configuration.onboardingShowAtFirstLaunch
        giniBankConfiguration.onboardingTextColor = configuration.onboardingTextColor
        giniBankConfiguration.onboardingScreenBackgroundColor = configuration.onboardingScreenBackgroundColor
        giniBankConfiguration.onboardingPages = configuration.onboardingPages
        
        giniBankConfiguration.navigationBarReviewTitleBackButton = configuration.navigationBarReviewTitleBackButton
        giniBankConfiguration.navigationBarReviewTitleCloseButton = configuration.navigationBarReviewTitleCloseButton
        giniBankConfiguration.navigationBarReviewTitleContinueButton = configuration.navigationBarReviewTitleContinueButton
        
        giniBankConfiguration.reviewBottomViewBackgroundColor = configuration.reviewBottomViewBackgroundColor
        giniBankConfiguration.reviewTextBottomFont = configuration.reviewTextBottomFont
        giniBankConfiguration.reviewTextBottomColor = configuration.reviewTextBottomColor
        
        giniBankConfiguration.indicatorCircleColor = configuration.indicatorCircleColor
        
        giniBankConfiguration.multipagePagesContainerAndToolBarColor = configuration.multipagePagesContainerAndToolBarColor
        giniBankConfiguration.multipageToolbarItemsColor = configuration.multipageToolbarItemsColor
        giniBankConfiguration.multipagePageIndicatorColor = configuration.multipagePageIndicatorColor
        giniBankConfiguration.multipagePageSelectedIndicatorColor = configuration.multipagePageSelectedIndicatorColor
        giniBankConfiguration.multipagePageBackgroundColor = configuration.multipagePageBackgroundColor
        giniBankConfiguration.multipageDraggableIconColor = configuration.multipageDraggableIconColor
        giniBankConfiguration.multipageToolTipOpaqueBackgroundStyle = configuration.multipageToolTipOpaqueBackgroundStyle
        
        giniBankConfiguration.analysisLoadingIndicatorColor = configuration.analysisLoadingIndicatorColor
        giniBankConfiguration.analysisPDFInformationBackgroundColor = configuration.analysisPDFInformationBackgroundColor
        giniBankConfiguration.analysisPDFInformationTextColor = configuration.analysisPDFInformationTextColor
        
        giniBankConfiguration.navigationBarAnalysisTitleBackButton = configuration.navigationBarAnalysisTitleBackButton
        
        giniBankConfiguration.helpScreenBackgroundColor = configuration.helpScreenBackgroundColor
        giniBankConfiguration.helpScreenCellsBackgroundColor = configuration.helpScreenCellsBackgroundColor
        
        giniBankConfiguration.navigationBarHelpMenuTitleBackToCameraButton = configuration.navigationBarHelpMenuTitleBackToCameraButton
        giniBankConfiguration.navigationBarHelpScreenTitleBackToMenuButton = configuration.navigationBarHelpScreenTitleBackToMenuButton
        
        giniBankConfiguration.shouldShowSupportedFormatsScreen = configuration.shouldShowSupportedFormatsScreen
        
        giniBankConfiguration.nonSupportedFormatsIconColor = configuration.nonSupportedFormatsIconColor
        
        giniBankConfiguration.supportedFormatsIconColor = configuration.supportedFormatsIconColor
        
        giniBankConfiguration.openWithAppNameForTexts = configuration.openWithAppNameForTexts
        
        giniBankConfiguration.stepIndicatorColor = configuration.stepIndicatorColor
        
        giniBankConfiguration.noResultsBottomButtonColor = configuration.noResultsBottomButtonColor
        
        giniBankConfiguration.noResultsWarningContainerIconColor = configuration.noResultsWarningContainerIconColor
        
        giniBankConfiguration.shouldShowDragAndDropTutorial = configuration.shouldShowDragAndDropTutorial
        
        giniBankConfiguration.customMenuItems = configuration.customMenuItems
        
        giniBankConfiguration.giniErrorLoggerIsOn = configuration.giniErrorLoggerIsOn
        giniBankConfiguration.customGiniErrorLoggerDelegate = configuration.customGiniErrorLoggerDelegate
        giniBankConfiguration.localizedStringsTableName = configuration.localizedStringsTableName
        
        // Undocumented--Xamarin only
        giniBankConfiguration.closeButtonResource = configuration.closeButtonResource
        giniBankConfiguration.helpButtonResource = configuration.helpButtonResource
        giniBankConfiguration.backToCameraButtonResource = configuration.helpButtonResource
        giniBankConfiguration.backToMenuButtonResource = configuration.backToMenuButtonResource
        giniBankConfiguration.nextButtonResource = configuration.nextButtonResource
        giniBankConfiguration.cancelButtonResource = configuration.cancelButtonResource
    }
}
