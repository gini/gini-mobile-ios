//
//  GiniHealthConfiguration.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GiniHealthConfiguration` class allows customizations to the look of the Gini Health SDK.
 If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.
 
 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle.
         The library will prefer whatever value is set in the following order: attribute in configuration,
         key in strings file in project bundle, key in strings file in `GiniHealth` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files
         in the projects bundle. The library will prefer whatever value is set in the following order: asset file
         in project bundle, asset file in `GiniHealth` bundle. See the avalible images for overriding in `GiniImages.xcassets`.
 */
public final class GiniHealthConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Health SDK.
     */
    static var shared = GiniHealthConfiguration()
    
    /**
     Returns a `GiniHealthConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Health SDK.
     
     - returns: Instance of `GiniHealthConfiguration`.
     */
    public override init() {}
    
    // MARK: - Payment review screen

    /**
     Set to `true` to show a close button on the payment review screen.
     */
    @objc public var showPaymentReviewCloseButton = false
    
    /**
     Sets the status bar style on the payment review screen. Only if `View controller-based status bar appearance` = `YES` in info.plist.
     */
    @objc public var paymentReviewStatusBarStyle: UIStatusBarStyle = .default
    
    // MARK: - Button configuration options
    /**
     A configuration that defines the appearance of the primary button, including its background color, border color, title color, shadow color, corner radius, border width, shadow radius, and whether to apply a blur effect. It is used for buttons on different UI elements: Payment Component View, Payment Review Screen.
     */
    public lazy var primaryButtonConfiguration = ButtonConfiguration(backgroundColor: .GiniHealthColors.accent1.withAlphaComponent(0.4),
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
    public lazy var secondaryButtonConfiguration = ButtonConfiguration(backgroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                                                                  darkModeColor: UIColor.GiniHealthColors.light6).uiColor(),
                                                                       borderColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                                                                              darkModeColor: UIColor.GiniHealthColors.light5).uiColor(),
                                                                       titleColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                                                             darkModeColor: UIColor.GiniHealthColors.light1).uiColor(),
                                                                       shadowColor: .clear,
                                                                       cornerRadius: 12,
                                                                       borderWidth: 1,
                                                                       shadowRadius: 0,
                                                                       withBlurEffect: true)
    
    // MARK: - Shared properties

    /**
     A default style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var defaultStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                                                                            darkModeColor: UIColor.GiniHealthColors.light6).uiColor(),
                                                                                 borderColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                                                                                        darkModeColor: UIColor.GiniHealthColors.light5).uiColor(),
                                                                                 textColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                                                                      darkModeColor: UIColor.GiniHealthColors.light1).uiColor(),
                                                                                 cornerRadius: 12.0,
                                                                                 borderWidth: 1.0,
                                                                                 placeholderForegroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                                                                                       darkModeColor: UIColor.GiniHealthColors.light4).uiColor())
    /**
     A error style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var errorStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                                                                          darkModeColor: UIColor.GiniHealthColors.light6).uiColor(),
                                                                                     borderColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.feedback1,
                                                                                                            darkModeColor: UIColor.GiniHealthColors.feedback1).uiColor(),
                                                                                     textColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                                                                          darkModeColor: UIColor.GiniHealthColors.light1).uiColor(),
                                                                                     cornerRadius: 12.0,
                                                                                     borderWidth: 1.0,
                                                                                     placeholderForegroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                                                                                           darkModeColor: UIColor.GiniHealthColors.light4).uiColor())
    /**
     A selection style configuration that defines the appearance of the text field, including its background color, border color, text color, corner radius, border width and the placeholder foreground color. It is used for input text fields on  Payment Review Screen.
     */
    public lazy var selectionStyleInputFieldConfiguration = TextFieldConfiguration(backgroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                                                                              darkModeColor: UIColor.GiniHealthColors.light6).uiColor(),
                                                                                     borderColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.accent1,
                                                                                                            darkModeColor: UIColor.GiniHealthColors.accent1).uiColor(),
                                                                                     textColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                                                                          darkModeColor: UIColor.GiniHealthColors.light1).uiColor(),
                                                                                     cornerRadius: 12.0,
                                                                                     borderWidth: 1.0,
                                                                                     placeholderForegroundColor: GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                                                                                           darkModeColor: UIColor.GiniHealthColors.light4).uiColor())
    
    // MARK: - Update to custom font
    /**
     Allows setting a custom font for specific text styles. The change will affect all screens where a specific text style was used.

     - parameter font: Font that is going to be assosiated with specific text style. You can use scaled font or scale your font with our util method `UIFont.scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle)`
     - parameter textStyle: Constants that describe the preferred styles for fonts. Please, find additional information [here](https://developer.apple.com/documentation/uikit/uifont/textstyle)
     */
    public func updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle) {
        textStyleFonts[textStyle] = font
    }
    
    /**
     Set dictionary of fonts for available text styles. Used internally.
     */
    var textStyleFonts: [UIFont.TextStyle: UIFont] = [
        .headline1: UIFontMetrics(forTextStyle: .headline1).scaledFont(for: UIFont.systemFont(ofSize: 26, weight: .regular)),
        .headline2: UIFontMetrics(forTextStyle: .headline2).scaledFont(for: UIFont.systemFont(ofSize: 20, weight: .bold)),
        .headline3: UIFontMetrics(forTextStyle: .headline3).scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold)),
        .caption1: UIFontMetrics(forTextStyle: .caption1).scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .regular)),
        .caption2: UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .regular)),
        .linkBold: UIFontMetrics(forTextStyle: .linkBold).scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold)),
        .subtitle1: UIFontMetrics(forTextStyle: .subtitle1).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold)),
        .subtitle2: UIFontMetrics(forTextStyle: .subtitle2).scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .medium)),
        .input: UIFontMetrics(forTextStyle: .input).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .medium)),
        .button: UIFontMetrics(forTextStyle: .button).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold)),
        .body1: UIFontMetrics(forTextStyle: .body1).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .regular)),
        .body2: UIFontMetrics(forTextStyle: .body2).scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .regular)),
    ]
}
