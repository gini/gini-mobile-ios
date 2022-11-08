//
//  ReviewBottomNavigationBar.swift
//  
//
//  Created by David Vizaknai on 24.10.2022.
//

import UIKit

protocol ReviewBottomNavigationBarDelegate: AnyObject {
    func didTapMainButton(on navigationBar: ReviewBottomNavigationBar)
    func didTapSecondaryButton(on navigationBar: ReviewBottomNavigationBar)
}

final class ReviewBottomNavigationBar: UIView {
    private let configuration = GiniConfiguration.shared
    weak var delegate: ReviewBottomNavigationBarDelegate?

    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: BottomLabelButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let configuration = GiniConfiguration.shared
        backgroundColor = GiniColor(light: UIColor.GiniCapture.dark2, dark: UIColor.GiniCapture.dark2).uiColor()

        mainButton.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                             comment: "Process button title"), for: .normal)
        mainButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        mainButton.layer.cornerRadius = configuration.primaryButtonCornerRadius
        mainButton.backgroundColor = UIColor.GiniCapture.accent1
        mainButton.setTitleColor(UIColor.GiniCapture.light1, for: .normal)
        mainButton.addTarget(self, action: #selector(mainButtonClicked), for: .touchUpInside)

        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.configureButton(image: UIImageNamedPreferred(named: "plus_icon") ?? UIImage(),
                                        name: NSLocalizedStringPreferredFormat(
                                            "ginicapture.multipagereview.secondaryButtonTitle",
                                        comment: "Add pages button title"))
        secondaryButton.isHidden = !configuration.multipageEnabled
        secondaryButton.actionLabel.textColor = UIColor.GiniCapture.light1
        secondaryButton.didTapButton = { [weak self] in
            self?.secondaryButtonClicked()
        }
        // The button's asset changes with light/dark mode but right now we don't support light mode on bottom navigation
        if #available(iOS 13.0, *) {
            secondaryButton.iconView.tintColor = .GiniCapture.light1
            secondaryButton.iconView.image = secondaryButton.iconView.image?.withTintColor(.GiniCapture.light1,
                                                                                         renderingMode: .alwaysTemplate)
        } else {
            secondaryButton.iconView.image = secondaryButton.iconView.image?.tintedImageWithColor(.GiniCapture.light1)
        }

        addLoadingView()
    }

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.color = GiniColor(light: UIColor.GiniCapture.dark3, dark: UIColor.GiniCapture.light3).uiColor()
        return indicatorView
    }()

    private func addLoadingView() {
        let loadingIndicator: UIView

        if let customLoadingIndicator = configuration.onButtonLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        bringSubviewToFront(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 45),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc
    private func mainButtonClicked() {
        delegate?.didTapMainButton(on: self)
    }

    @objc
    private func secondaryButtonClicked() {
        delegate?.didTapSecondaryButton(on: self)
    }

    func setMainButtonTitle(with title: String) {
        mainButton.setTitle(title, for: .normal)
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

    private func showAnimation() {
        if let loadingIndicator = configuration.onButtonLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    private func hideAnimation() {
        if let loadingIndicator = configuration.onButtonLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
}
