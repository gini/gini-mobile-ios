//
//  CustomReviewScreenBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 07.11.2022.
//

import UIKit

protocol CustomReviewScreenBottomNavigationBarDelegate: AnyObject {
    func didTapMainButton(on navigationBar: CustomReviewScreenBottomNavigationBar)
    func didTapSecondaryButton(on navigationBar: CustomReviewScreenBottomNavigationBar)
}

final class CustomReviewScreenBottomNavigationBar: UIView {

    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!

    weak var delegate: CustomReviewScreenBottomNavigationBarDelegate?

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.color = .white
        return indicatorView
    }()

    private let configuration = GiniConfiguration.shared

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        mainButton.addTarget(self, action: #selector(mainButtonClicked), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryButtonClicked), for: .touchUpInside)
        addLoadingView()
    }

    func set(loadingState isLoading: Bool) {
        if self.configuration.multipageEnabled {
            if !isLoading {
                self.mainButton.alpha = 1
                self.mainButton.isEnabled = true
                self.hideAnimation()
                return
            }

            self.mainButton.alpha = 0.3
            self.mainButton.isEnabled = false
            self.showAnimation()
        }
    }

    private func addLoadingView() {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicatorView)
        bringSubviewToFront(loadingIndicatorView)

        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            loadingIndicatorView.widthAnchor.constraint(equalToConstant: 45),
            loadingIndicatorView.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    private func showAnimation() {
        loadingIndicatorView.startAnimating()
    }

    private func hideAnimation() {
        loadingIndicatorView.stopAnimating()
    }

    @objc
    private func mainButtonClicked() {
        delegate?.didTapMainButton(on: self)
    }

    @objc
    private func secondaryButtonClicked() {
        delegate?.didTapSecondaryButton(on: self)
    }
}
