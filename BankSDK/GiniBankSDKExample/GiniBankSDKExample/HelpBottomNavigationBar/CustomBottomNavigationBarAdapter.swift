//
//  CustomHelpBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 07/10/2022.
//

import UIKit
import GiniCaptureSDK
import GiniBankSDK

/**
The CustomBottomNavigationBarAdapter class is a composite adapter conforming to multiple adapter protocols for displaying a custom bottom navigation bar in various views. It also provides a back button callback functionality that can be customized to respond to user interaction.
*/

typealias BottomNavigationBarAdapters = HelpBottomNavigationBarAdapter & ImagePickerBottomNavigationBarAdapter & DigitalInvoiceHelpNavigationBarBottomAdapter & SkontoHelpNavigationBarBottomAdapter & ErrorNavigationBarBottomAdapter

public final class CustomBottomNavigationBarAdapter: BottomNavigationBarAdapters {
    private var backButtonCallback: (() -> Void)?

    /**
     Sets the callback block to be executed when the back button on the custom navigation bar is clicked.

     - Parameter callback: The block to be executed when the back button is clicked.
     */
    public func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    /**
     Returns a CustomBottomNavigationBar instance to be used as the bottom navigation bar for the view.

     - Returns: A CustomBottomNavigationBar instance.
     */
    public func injectedView() -> UIView {
		guard let navigationBarView = CustomBottomNavigationBar().loadNib() as? CustomBottomNavigationBar else {
			return UIView()
		}
		navigationBarView.backButton.addTarget(self,
											   action: #selector(backButtonClicked),
											   for: .touchUpInside)
		return navigationBarView
	}

    @objc func backButtonClicked() {
        backButtonCallback?()
    }

    /**
     Called when the CustomBottomNavigationBarAdapter object is deallocated.
     */
    public func onDeinit() {
        backButtonCallback = nil
    }
}
