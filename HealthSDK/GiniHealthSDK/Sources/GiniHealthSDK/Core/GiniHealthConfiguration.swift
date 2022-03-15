//
//  GiniHealthConfiguration.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 30.03.21.
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
     Sets the backgroundColor on the payment review screen
     */
    @objc public var paymentScreenBackgroundColor = GiniColor(lightModeColor: UIColor.black, darkModeColor: UIColor.black)
    
    /**
     Sets the backgroundColor on the payment review screen for input fields container
     */
    @objc public var inputFieldsContainerBackgroundColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)
    
    /**
     Sets the backgroundColor on the payment review screen for pay button when it's disabled
     */
    @objc public var payButtonDisabledBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex:0xCCCFDB), darkModeColor: UIColor.from(hex:0xCCCFDB))
    
    /**
     Sets the textColor on the payment review screen for pay button when it's disabled
     */
    @objc public var payButtonDisabledTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the corner radius of the pay button on the payment review screen
     */
    @objc public var payButtonCornerRadius: CGFloat = 6.0
    
    /**
     Sets the corner radius of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldCornerRadius: CGFloat = 6.0
    
    /**
     Sets the border width of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldBorderWidth: CGFloat = 0.0
    
    /**
     Sets the border width of the payment input field with selection style on the payment review screen
     */
    @objc public var paymentInputFieldSelectionStyleBorderWidth: CGFloat = 1.0
    
    /**
     Sets the border width of the payment input field with error style on the payment review screen
     */
    @objc public var paymentInputFieldErrorStyleBorderWidth: CGFloat = 1.0
    
    /**
     Sets the error style color and error text color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldErrorStyleColor = GiniColor(lightModeColor: .red, darkModeColor: .red)
    
    /**
     Sets the selection style color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldSelectionStyleColor = GiniColor(lightModeColor: .blue, darkModeColor: .blue)
    
    /**
     Sets the selection background color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldSelectionBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the background color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex: 0xF2F3F6), darkModeColor: UIColor.from(hex: 0xF2F3F6))
    
    /**
     Sets the text color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x33406F), darkModeColor: UIColor.from(hex: 0x33406F))
    
    /**
     Sets the placeholder text color of the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldPlaceholderTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x999FB7), darkModeColor: UIColor.from(hex: 0x999FB7))
    
    /**
     Sets the text color of the bank selection button on the payment review screen
     */
    @objc public var bankButtonTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x33406F), darkModeColor: UIColor.from(hex: 0x33406F))
    
    /**
     Sets the background color of the bank selection button on the payment review screen
     */
    @objc public var bankButtonBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the border width of the the bank button on the payment review screen
     */
    @objc public var bankButtonBorderWidth: CGFloat = 1.0
    
    /**
     Sets the border color of the bank selection button on the payment review screen
     */
    @objc public var bankButtonBorderColor = GiniColor(lightModeColor: UIColor.from(hex: 0xE6E7ED), darkModeColor: UIColor.from(hex: 0xE6E7ED))
    
    /**
     Sets the corner radius of the bank selection button on the payment review screen
     */
    @objc public var bankButtonCornerRadius: CGFloat = 6.0
    
    /**
     Sets the edit icon color  of the bank selection button on the payment review screen
     */
    @objc public var bankButtonEditIconColor = GiniColor(lightModeColor: UIColor.from(hex: 0x222222), darkModeColor: UIColor.from(hex: 0x222222))
        
    /**
     Sets the current page indicator on the review screen to the specified color.
     */
    @objc public var currentPageIndicatorTintColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)
    
    /**
     Sets the page indicator on the review screen to the specified color.
     */
    @objc public var pageIndicatorTintColor = GiniColor(lightModeColor: UIColor.lightGray, darkModeColor: UIColor.lightGray)
    
    /**
     Set to `true` to show a close button on the payment review screen.
     */
    @objc public var showPaymentReviewCloseButton = false
    
    // MARK: - Bank selection screen
    
    /**
     Sets the backgroundColor on the bank selection screen.
     */
    @objc public var bankSelectionScreenBackgroundColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)
    
    /**
     Sets the backgroundColor of the dimmend overlay on the bank selection screen.
     */
    @objc public var bankSelectionDimmedOverlayBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex: 0x00104B66).withAlphaComponent(0.4), darkModeColor: UIColor.from(hex: 0x00104B66).withAlphaComponent(0.4))
    
    /**
     Sets the color of the scroll down view on the bank selection screen.
     */
    @objc public var bankSelectionScrollDownIndicatorViewColor = GiniColor(lightModeColor: UIColor.from(hex: 0xCCCFDB), darkModeColor: UIColor.from(hex: 0xCCCFDB))
    
    /**
     Sets the text color of the title on the bank selection screen.
     */
    @objc public var bankSelectionTitleTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x00104B), darkModeColor: UIColor.from(hex: 0x00104B))
    
    /**
     Sets the color of the cells separator view on the bank selection screen.
     */
    @objc public var bankSelectionCellSeparatorColor = GiniColor(lightModeColor: UIColor.from(hex: 0xE6E7ED), darkModeColor: UIColor.from(hex: 0xE6E7ED))
    
    /**
     Sets the text color of the cells on the bank selection screen.
     */
    @objc public var bankSelectionCellTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x00104B), darkModeColor: UIColor.from(hex: 0x00104B))
    
    /**
     Sets the corner radius of the bank icons on the bank selection screen.
     */
    @objc public var bankSelectionCellIconCornerRadius: CGFloat = 0.0
    
    /**
     Sets the text color of the info bar on the payment review screen.
     */
    @objc public var infoBarTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the background color of the info bar on the payment review screen.
     */
    @objc public var infoBarBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex: 0x7263D0), darkModeColor: UIColor.from(hex: 0x7263D0))
    
    /**
     Sets the corner radius of the info bar on the payment review screen.
     */
    @objc public var infoBarCornerRadius: CGFloat = 12.0
    
    
    // MARK: - Shared properties
    
    /**
     Sets the font used in the screens by default.
     */
    
    @objc public lazy var customFont = GiniFont(regular: UIFont.systemFont(ofSize: 14,
                                                                                                 weight: .regular),
                                                                      bold: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .bold),
                                                                      light: UIFont.systemFont(ofSize: 14,
                                                                                               weight: .light),
                                                                      thin: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .thin),
                                                                      isEnabled: false)
    /**
     Sets the color of the loading indicator to the specified color.
     */
    @objc public var loadingIndicatorColor = GiniColor(lightModeColor: .orange, darkModeColor: .orange)
    
    /**
     Sets the style of the loading indicator.
     */
    @objc public var loadingIndicatorStyle: UIActivityIndicatorView.Style = .whiteLarge
    
    /**
     Sets the scale of the loading indicator.
     */
    @objc public var loadingIndicatorScale: CGFloat = 1.0
    
}
