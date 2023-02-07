//
//  CustomReviewScreenBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 07.11.2022.
//

import UIKit
import GiniBankSDK

protocol CustomReviewScreenBottomNavigationBarDelegate: AnyObject {
    func didTapMainButton(on navigationBar: CustomReviewScreenBottomNavigationBar)
    func didTapSecondaryButton(on navigationBar: CustomReviewScreenBottomNavigationBar)
}

final class CustomReviewScreenBottomNavigationBar: UIView {

    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var addPagesButton: UIButton!

    weak var delegate: CustomReviewScreenBottomNavigationBarDelegate?

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.color = .white
        return indicatorView
    }()

    private let configuration = GiniBankConfiguration.shared

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        processButton.addTarget(self, action: #selector(mainButtonClicked), for: .touchUpInside)
        addPagesButton.addTarget(self, action: #selector(secondaryButtonClicked), for: .touchUpInside)
        addLoadingView()
    }

    func set(loadingState isLoading: Bool) {
        if self.configuration.multipageEnabled {
            if !isLoading {
                self.processButton.alpha = 1
                self.processButton.isEnabled = true
                self.hideAnimation()
                return
            }

            self.processButton.alpha = 0.3
            self.processButton.isEnabled = false
            self.showAnimation()
        }
    }

    private func addLoadingView() {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicatorView)
        bringSubviewToFront(loadingIndicatorView)

        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: processButton.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: processButton.centerYAnchor),
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
