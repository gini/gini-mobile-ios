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

    @IBOutlet weak var mainButton: MultilineTitleButton!
    @IBOutlet weak var secondaryButton: BottomLabelButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let configuration = GiniConfiguration.shared
        backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark1).uiColor()

        mainButton.configure(with: configuration.primaryButtonConfiguration)
        mainButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        mainButton.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                             comment: "Process button title"), for: .normal)
        mainButton.addTarget(self, action: #selector(mainButtonClicked), for: .touchUpInside)

        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.setupButton(with: UIImageNamedPreferred(named: "plus_icon") ?? UIImage(),
                                    name: NSLocalizedStringPreferredFormat(
                                        "ginicapture.multipagereview.secondaryButtonTitle",
                                            comment: "Add pages button title"))
        secondaryButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                                                "ginicapture.multipagereview.secondaryButton.accessibility",
                                                comment: "Add pages")
        secondaryButton.isHidden = !configuration.multipageEnabled

        secondaryButton.actionLabel.font = configuration.textStyleFonts[.bodyBold]
        secondaryButton.configure(with: configuration.addPageButtonConfiguration)
        secondaryButton.didTapButton = { [weak self] in
            self?.secondaryButtonClicked()
        }
        addLoadingView()
    }

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .large
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
