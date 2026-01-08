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

    public init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

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
		guard let navigationBarView = CustomReviewScreenBottomNavigationBar().loadNib()
				as? CustomReviewScreenBottomNavigationBar else {
			return UIView()
		}
		view = navigationBarView
		view?.delegate = self
		return navigationBarView
	}

    public func onDeinit() {
        // This method will remain empty; no implementation is needed.
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
