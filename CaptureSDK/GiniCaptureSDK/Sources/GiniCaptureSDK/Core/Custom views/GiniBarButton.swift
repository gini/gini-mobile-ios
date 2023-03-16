//
// GiniBarButton.swift
//  
//
//  Created by David Vizaknai on 15.03.2023.
//

import UIKit

public enum BarButtonType {
    case cancel, help, back(title: String), done
}

public final class GiniBarButton {
    private let configuration = GiniConfiguration.shared
    private let button = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()

    // MARK: - Public methods
    public func addAction(_ target: Any?, _ action: Selector) {
        let tapRecognizer = UITapGestureRecognizer(target: target, action: action)
        stackView.addGestureRecognizer(tapRecognizer)
    }

    public var barButton: UIBarButtonItem {
        return UIBarButtonItem(customView: stackView)
    }

    public init(ofType type: BarButtonType) {
        setupContent(basedOnType: type)
        setupViews()
    }

    // MARK: - Private methods
    private func setupViews() {
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.backgroundColor = .yellow

        imageView.contentMode = .scaleAspectFit

        button.font = configuration.textStyleFonts[.bodyBold]
        button.textColor = .GiniCapture.accent1

        if imageView.image != nil {
            stackView.addArrangedSubview(imageView)
        }

        if button.text != nil {
            stackView.addArrangedSubview(button)
        }
    }

    private func setupContent(basedOnType type: BarButtonType) {
        var buttonTitle: String?
        var icon: UIImage?

        switch type {
        case .cancel:
            buttonTitle = "Cancel+"

            if let cancelIcon = configuration.giniNavigationBarButtonCancelButtonIcon {
                icon = cancelIcon
            }
        case .help:
            buttonTitle = "Help+"

            if let helpIcon = configuration.giniNavigationBarButtonHelpButtonIcon {
                icon = helpIcon
            }
        case .back(title: let title):
            buttonTitle = title

            if let backIcon = configuration.giniNavigationBarButtonBackButtonIcon {
                icon = backIcon
            } else {
                icon = UIImageNamedPreferred(named: "arrowBack")
            }
        case .done:
            buttonTitle = "Done+"

            if let doneIcon = configuration.giniNavigationBarButtonDoneButtonIcon {
                icon = doneIcon
            }
        }

        var buttonTitleIsEmpty: Bool
        if let buttonTitle = buttonTitle, !buttonTitle.isEmpty {
            buttonTitleIsEmpty = false
        } else {
            buttonTitleIsEmpty = true
        }

        if buttonTitleIsEmpty && icon == nil {
            assertionFailure("You need to provide at least a valid string or an icon" +
                             " for the navigation bar button of type: \(type)")
        }

        imageView.image = icon

        if let buttonTitle = buttonTitle, buttonTitle.isNotEmpty {
            button.text = buttonTitle
        }
    }
}
