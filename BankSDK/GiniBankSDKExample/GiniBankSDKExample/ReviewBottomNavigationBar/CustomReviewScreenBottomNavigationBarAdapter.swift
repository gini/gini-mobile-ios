//
//  CustomReviewScreenBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 07.11.2022.
//

import UIKit
import GiniCaptureSDK

final public class CustomReviewScreenBottomNavigationBarAdapter: ReviewScreenBottomNavigationBarAdapter {
    private var mainButtonCallback: (() -> Void)?
    private var secondaryButtonCallback: (() -> Void)?
    var view: CustomReviewScreenBottomNavigationBar?

    public init() {}

    public func setMainButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        mainButtonCallback = callback
    }

    public func setSecondaryButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        secondaryButtonCallback = callback
    }

    public func setMainButtonTitle(with title: String) {
        view?.processButton.setTitle(title, for: .normal)
    }

    public func set(loadingState isLoading: Bool) {
        view?.set(loadingState: isLoading)
    }

    public func injectedView() -> UIView {
		let navigationBarView = CustomReviewScreenBottomNavigationBar()
		self.view = navigationBarView
		self.view?.delegate = self
		return navigationBarView
	}

    public func onDeinit() {

    }
}

extension CustomReviewScreenBottomNavigationBarAdapter: CustomReviewScreenBottomNavigationBarDelegate {
    func didTapMainButton(on navigationBar: CustomReviewScreenBottomNavigationBar) {
        mainButtonCallback?()
    }

    func didTapSecondaryButton(on navigationBar: CustomReviewScreenBottomNavigationBar) {
        secondaryButtonCallback?()
    }
}
