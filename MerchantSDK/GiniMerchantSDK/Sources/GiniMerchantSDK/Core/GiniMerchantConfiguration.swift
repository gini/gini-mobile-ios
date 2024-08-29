//
//  GiniMerchantConfiguration.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

/**
 The `GiniMerchantConfiguration` class allows customizations to the look of the Gini Merchant SDK.
 If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.
 
 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle.
         The library will prefer whatever value is set in the following order: attribute in configuration,
         key in strings file in project bundle, key in strings file in `GiniMerchant` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files
         in the projects bundle. The library will prefer whatever value is set in the following order: asset file
         in project bundle, asset file in `GiniMerchant` bundle. See the avalible images for overriding in `GiniImages.xcassets`.
 */
public final class GiniMerchantConfiguration: NSObject {
    private let fontProvider = FontProvider()

    /**
     Singleton to make configuration internally accessible in all classes of the Gini Merchant SDK.
     */
    public static var shared = GiniMerchantConfiguration()
    
    /**
     Returns a `GiniMerchantConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Merchant SDK.
     
     - returns: Instance of `GiniMerchantConfiguration`.
     */
    public override init() {
        super.init()
    }
    
    // MARK: - Payment component view

    /**
    Height of the buttons from the Payment Component View
     */
    public var paymentComponentButtonsHeight: CGFloat = Constants.defaultButtonsHeight {
        didSet {
            if paymentComponentButtonsHeight < Constants.minimumButtonsHeight {
                paymentComponentButtonsHeight = Constants.minimumButtonsHeight
            }
        }
    }

    // MARK: - Payment review screen

    /**
     Set to `false` to hide the payment review screen and jump straight to payment
     */
    public var showPaymentReviewScreen = true

    // MARK: - Button configuration options
    /**
     A configuration that defines the appearance of the primary button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for buttons on different UI elements: Payment Component View, Payment Review Screen.
     */
    public lazy var primaryButtonConfiguration = ButtonConfiguration(backgroundColor: GiniMerchantColorPalette.accent1.preferredColor().withAlphaComponent(0.4),
                                                                     borderColor: .clear,
                                                                     titleColor: .white,
                                                                     shadowColor: .clear,
                                                                     cornerRadius: 12,
                                                                     borderWidth: 0,
                                                                     shadowRadius: 0,
                                                                     withBlurEffect: false)
    /**
     A configuration that defines the appearance of the secondary button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for buttons on different UI elements: Payment Component View.
     */
    public lazy var secondaryButtonConfiguration = ButtonConfiguration(backgroundColor: GiniColor.standard6.uiColor(),
                                                                       borderColor: GiniColor.standard5.uiColor(),
                                                                       titleColor: GiniColor.standard1.uiColor(),
                                                                       shadowColor: .clear,
                                                                       cornerRadius: 12,
                                                                       borderWidth: 1,
                                                                       shadowRadius: 0,
                                                                       withBlurEffect: true)
    
    // MARK: - Shared properties

    /**
     A default style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var defaultStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor.standard6.uiColor(),
                                                                                 borderColor: GiniColor.standard5.uiColor(),
                                                                                 textColor: GiniColor.standard1.uiColor(),
                                                                                 cornerRadius: 12.0,
                                                                                 borderWidth: 1.0,
                                                                                 placeholderForegroundColor: GiniColor.standard4.uiColor())
    /**
     A error style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var errorStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor.standard6.uiColor(),
                                                                                     borderColor: GiniColor(lightModeColorName: .feedback1, darkModeColorName: .feedback1).uiColor(),
                                                                                     textColor: GiniColor.standard1.uiColor(),
                                                                                     cornerRadius: 12.0,
                                                                                     borderWidth: 1.0,
                                                                                     placeholderForegroundColor: GiniColor.standard4.uiColor())
    /**
     A selection style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var selectionStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor.standard6.uiColor(),
                                                                                   borderColor: GiniColor.accent1.uiColor(),
                                                                                     textColor: GiniColor.standard1.uiColor(),
                                                                                     cornerRadius: 12.0,
                                                                                     borderWidth: 1.0,
                                                                                     placeholderForegroundColor: GiniColor.standard4.uiColor())
    
    // MARK: - Update to custom font
    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be assosiated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
     */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        fontProvider.updateFont(font, for: textStyle)
    }

    public func font(for textStyle: UIFont.TextStyle) -> UIFont {
        return fontProvider.font(for: textStyle)
    }

    // We will switch this option internally to stil handle documents with extractions on GiniHealthSDK and still handle invoices without document on GiniMerchantSDK
    var useInvoiceWithoutDocument: Bool = false
}

extension GiniMerchantConfiguration {
    private enum Constants {
        static let defaultButtonsHeight = 56.0
        static let minimumButtonsHeight = 44.0
    }
}
