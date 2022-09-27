//
//  ReturnAssistantConfiguration.swift
// GiniBank
//
//  Created by Nadya Karaban on 25.02.21.
//

import UIKit
import GiniCaptureSDK

public final class ReturnAssistantConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini PayBank SDK.
     */
   public static var shared = ReturnAssistantConfiguration()
    
    /**
     Returns a `ReturnAssistantConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Capture SDK.
     
     - returns: Instance of `ReturnAssistantConfiguration`.
     */
    public override init() {}
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
     Sets the color of the active elements on the digital invoice line item cells to the specified color.
     
     Can be overridden by the specific line item tint color customisation options: `lineItemBorderColor`, `digitalInvoiceLineItemEditButtonTintColor`,
     `digitalInvoiceLineItemToggleSwitchTintColor`, `digitalInvoiceLineItemDeleteButtonTintColor`.
     */
    @objc public var lineItemTintColor = Colors.Gini.blue
    
    /**
     Sets the border color on the digital invoice line item cells to the specified color.
     
     Overrides `lineItemTintColor` if not `nil`.
     */
    @objc public var lineItemBorderColor: UIColor? = nil
    
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
     Sets the edit button tint color on the digital invoice screen to the specified color.
     
     Overrides `lineItemTintColor` if not `nil`.
     */
    @objc public var digitalInvoiceLineItemEditButtonTintColor: UIColor? = nil
    
    /**
     Sets the toggle switch tint color on the digital invoice line item cells to the specified color.
     
     Overrides `lineItemTintColor` if not `nil`.
     */
    @objc public var digitalInvoiceLineItemToggleSwitchTintColor: UIColor? = nil
    
    /**
     Sets the delete button tint color on the digital invoice screen to the specified color.
     
     Overrides `lineItemTintColor` if not `nil`.
     */
    @objc public var digitalInvoiceLineItemDeleteButtonTintColor: UIColor? = nil
    
    /**
     Sets the font of the line item label that displays the quantity on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceLineItemQuantityFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        
    /**
     Sets the color of  the line item label that displays the quantity on the digital invoice line item cells to the specified color.
     */
    @objc public var digitalInvoiceLineItemQuantityColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
    /**
     Sets the color of  the line item label that displays the item name on the digital invoice line item cells to the specified color.
     */
    @objc public var digitalInvoiceLineItemNameColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
    /**
     Sets the color of  the line item label that displays the price on the digital invoice line item cells to the specified color.
     */
    @objc public var digitalInvoiceLineItemPriceColor = GiniColor(lightModeColor: .black, darkModeColor: .white)

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
     Sets the disabled color for the line items on the digital invoice screen.
     */
    @objc public var digitalInvoiceLineItemsDisabledColor =  UIColor.gray
    
    /**
     Sets the font of the footer message on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceFooterMessageTextFont = UIFont.systemFont(ofSize: 14)
    
    /**
     Sets the add article button tint color of the footer section on the digital invoice screen.
     */
    @objc public var digitalInvoiceFooterAddArticleButtonTintColor = Colors.Gini.blue
    
    /**
     Sets the font of the add article button of the footer section on the digital invoice screen.
     */
    @objc public var digitalInvoiceFooterAddArticleButtonTitleFont = UIFont.systemFont(ofSize: 18)
    
    /**
     Sets the text color of the footer message on the digital invoice screen.
     */
    @objc public var digitalInvoiceFooterMessageTextColor = GiniColor(lightModeColor: .darkGray, darkModeColor:.white)
    
    /**
     Sets the font of the items section header on the digital invoice screen to the specified font.
     */
    @objc public var digitalInvoiceItemsSectionHeaderTextFont = UIFont.systemFont(ofSize: 12)
    
    /**
     Sets the text color of the items section header on the digital invoice screen.
     */
    @objc public var digitalInvoiceItemsSectionHeaderTextColor = GiniColor(lightModeColor: .gray, darkModeColor:.white)
    
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
     Sets the text color of the total caption label on the digital invoice screen.
     */
    @objc public var digitalInvoiceTotalCaptionLabelTextColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
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
     Sets the color of the addon name labels in the digital invoice screen to the specified color
     */
    @objc public var digitalInvoiceAddonLabelColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
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
     Sets the highlighted color of the content labels in the line item details view controller to the specified color
     */
    @objc public var lineItemDetailsContentHighlightedColor: UIColor = Colors.Gini.blue
    
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
     Shows the return reasons dialog.
     */
    @objc public var enableReturnReasons: Bool = true
    
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
}
