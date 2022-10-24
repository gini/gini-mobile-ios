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
    lazy var mainButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.GiniCapture.accent1
        button.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                         comment: "Process button title"), for: .normal)
        button.addTarget(self, action: #selector(mainButtonClicked), for: .touchUpInside)
        return button
    }()

    lazy var secondaryButton: BottomLabelButton = {
        let addPagesButton = BottomLabelButton()
        addPagesButton.translatesAutoresizingMaskIntoConstraints = false
        addPagesButton.configureButton(image: UIImageNamedPreferred(named: "plus_icon") ?? UIImage(),
                                       name:
                        NSLocalizedStringPreferredFormat("ginicapture.multipagereview.secondaryButtonTitle",
                                                        comment: "Add pages button title"))
        addPagesButton.isHidden = !configuration.multipageEnabled
        if #available(iOS 13.0, *) {
            addPagesButton.iconView.tintColor = .GiniCapture.light1
            addPagesButton.iconView.image = addPagesButton.iconView.image?.withTintColor(.GiniCapture.light1,
                                                                                         renderingMode: .alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        addPagesButton.actionLabel.textColor = UIColor.GiniCapture.light1
        addPagesButton.didTapButton = { [weak self] in
            self?.secondaryButtonClicked()
        }
        return addPagesButton
    }()

    weak var delegate: ReviewBottomNavigationBarDelegate?

    init() {
        super.init(frame: .zero)
        setupView()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = GiniColor(light: UIColor.GiniCapture.dark2, dark: UIColor.GiniCapture.dark2).uiColor()

        addSubview(mainButton)
        addSubview(secondaryButton)
    }

    private func addConstraints() {
        let buttonLeadingConstraint = secondaryButton.leadingAnchor.constraint(equalTo: mainButton.trailingAnchor,
                                                                              constant: 13)
        buttonLeadingConstraint.priority = UILayoutPriority.defaultLow

        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            mainButton.widthAnchor.constraint(equalToConstant: 204),
            mainButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: 50),
            mainButton.bottomAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -50),

            secondaryButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            buttonLeadingConstraint,
            secondaryButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -4)
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
}
