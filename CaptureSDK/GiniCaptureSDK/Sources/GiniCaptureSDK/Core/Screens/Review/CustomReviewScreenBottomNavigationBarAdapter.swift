//
//  CustomReviewScreenBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 07.11.2022.
//

import UIKit

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
        view?.mainButton.setTitle(title, for: .normal)
    }

    public func set(loadingState isLoading: Bool) {
        view?.set(loadingState: isLoading)
    }

    public func injectedView() -> UIView {
        if let navigationBarView = CustomReviewScreenBottomNavigationBar().loadNib()
            as? CustomReviewScreenBottomNavigationBar {
            self.view = navigationBarView
            self.view?.delegate = self
            return navigationBarView
        } else {
            return UIView()
        }
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
