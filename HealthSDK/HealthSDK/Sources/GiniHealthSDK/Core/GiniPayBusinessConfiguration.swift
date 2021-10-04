//
//  GiniPayBusinessConfiguration.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
/**
 The `GiniPayBusinessConfiguration` class allows customizations to the look of the Gini Pay Business SDK.
 If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.
 
 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle.
         The library will prefer whatever value is set in the following order: attribute in configuration,
         key in strings file in project bundle, key in strings file in `GiniPayBusiness` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files
         in the projects bundle. The library will prefer whatever value is set in the following order: asset file
         in project bundle, asset file in `GiniPayBusiness` bundle. See the avalible images for overriding in `GiniImages.xcassets`.
 */
public final class GiniPayBusinessConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Pay Business SDK.
     */
    static var shared = GiniPayBusinessConfiguration()
    
    /**
     Returns a `GiniPayBusinessConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Pay Business SDK.
     
     - returns: Instance of `GiniPayBusinessConfiguration`.
     */
    public override init() {}
    
    /**
     Sets the backgroundColor on the payment review screen
     */
    @objc public var paymentScreenBackgroundColor = GiniColor(lightModeColor: UIColor.black, darkModeColor: UIColor.black)
    
    /**
     Sets the backgroundColor on the payment review screen for input fields container
     */
    @objc public var inputFieldsContainerBackgroundColor = GiniColor(lightModeColor: UIColor.white, darkModeColor: UIColor.white)
    
    /**
     Sets the backgroundColor  on the payment review screen for pay button
     */
    @objc public var payButtonBackgroundColor = GiniColor(lightModeColor: UIColor.from(hex:0xFF6800), darkModeColor: UIColor.from(hex:0xFF6800))
    
    /**
     Sets the text color of the pay button on the payment review screen
     */
    @objc public var payButtonTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
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
    @objc public var paymentInputFieldErrorStyleColor = UIColor.red
    
    /**
     Sets the selection style color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldSelectionStyleColor = UIColor.blue
    
    /**
     Sets the selection background color for the payment input fields on the payment review screen
     */
    @objc public var paymentInputFieldSelectionBackgroundColor = UIColor.white
    
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
     Sets the text color of the bank button on the payment review screen
     */
    @objc public var bankButtonTextColor = GiniColor(lightModeColor: UIColor.from(hex: 0x33406F), darkModeColor: UIColor.from(hex: 0x33406F))
    
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
     Sets the color of the loading indicator on the review  screen to the specified color.
     */
    @objc public var loadingIndicatorColor = UIColor.orange
    
    /**
     Sets the style of the loading indicator on the review screen.
     */
    @objc public var loadingIndicatorStyle: UIActivityIndicatorView.Style = .whiteLarge
    
    /**
     Sets the scale of the loading indicator on the review screen.
     */
    @objc public var loadingIndicatorScale: CGFloat = 1.0
    
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
}
