//
//  SaveToGalleryView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class SaveToGalleryView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = Strings.titleLabel
        label.font = configuration.textStyleFonts[.callout]
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.text = Strings.descriptionLabel
        label.numberOfLines = 0
        label.font = configuration.textStyleFonts[.caption2]
        
        return label
    }()
    
    private lazy var enabledSwitch: UISwitch = {
        let toggle = UISwitch()
        
        toggle.onTintColor = GiniColor(light: .GiniCapture.accent1,
                                       dark: .GiniCapture.accent1).uiColor()
        
        toggle.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        
        return toggle
    }()

    private let configuration = GiniConfiguration.shared

    var isOn: Bool {
        enabledSwitch.isOn
    }

    @Published var valueChanged = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setCornerRadius()
        setOffState()
        addTitleLabel()
        addDescriptionLabel()
        addEnabledSwitch()
    }

    private func addTitleLabel() {
        addSubview(titleLabel)

        titleLabel.giniMakeConstraints {
            $0.top.equalToSuperview().constant(Constants.titleTopPadding)
            $0.leading.equalToSuperview().constant(Constants.labelsLeadingPadding)
        }
    }

    private func addDescriptionLabel() {
        addSubview(descriptionLabel)

        descriptionLabel.giniMakeConstraints {
            $0.top.equalTo(titleLabel.bottom).constant(Constants.descriptionTopSpacing)
            $0.leading.equalToSuperview().constant(Constants.labelsLeadingPadding)
            $0.bottom.equalToSuperview().constant(Constants.descriptionBottomPadding)
        }
    }

    private func addEnabledSwitch() {
        addSubview(enabledSwitch)

        enabledSwitch.giniMakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.trailing).constant(Constants.switchLeadingSpacing)
            $0.leading.equalTo(descriptionLabel.trailing).constant(Constants.switchLeadingSpacing)
            $0.trailing.equalToSuperview().constant(Constants.switchTrailingPadding)
        }
    }

    private func setCornerRadius() {
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }

    private func setOnState() {
        backgroundColor = GiniColor(light: .GiniCapture.light1,
                                    dark: .GiniCapture.dark3).uiColor()
        layer.borderWidth = 0.0
    }

    private func setOffState() {
        backgroundColor = GiniColor(light: .GiniCapture.light2,
                                    dark: .GiniCapture.dark2).uiColor()

        layer.borderWidth = 1.0
        layer.borderColor = GiniColor(light: .GiniCapture.light3,
                                      dark: .GiniCapture.dark4).uiColor().cgColor
    }

    @objc private func didToggleSwitch(_ enabledSwitch: UISwitch) {
        enabledSwitch.isOn ? setOnState() : setOffState()
        valueChanged = enabledSwitch.isOn
    }

    private struct Constants {
        static let titleTopPadding = 20.0
        static let descriptionBottomPadding = -20.0
        static let descriptionTopSpacing = 4.0
        static let labelsLeadingPadding = 16.0
        static let switchLeadingSpacing = 16.0
        static let switchTrailingPadding = -16.0
    }

    private struct Strings {
        static let titleLabel = NSLocalizedStringPreferredFormat("ginicapture.saveinvoice.local.title",
                                                                 comment: "Save locally title")
        static let descriptionLabel = NSLocalizedStringPreferredFormat("ginicapture.saveinvoice.local.description",
                                                                       comment: "Save locally description")
    }
}

#if DEBUG
import SwiftUI

struct SaveToGalleryViewController_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            let viewController = UIViewController()
            let saveToGalleryView = SaveToGalleryView()

            viewController.view.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                                            dark: .GiniCapture.dark2).uiColor()
            viewController.view.addSubview(saveToGalleryView)

            saveToGalleryView.giniMakeConstraints {
                $0.top.equalTo(viewController.view.safeAreaLayoutGuide).constant(0)
                $0.horizontal.equalTo(viewController.view.safeAreaLayoutGuide).constant(16.0)
            }

            return viewController
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
