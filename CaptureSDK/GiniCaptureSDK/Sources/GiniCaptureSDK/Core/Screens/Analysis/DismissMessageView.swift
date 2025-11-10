//
//  DismissMessageView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class DismissMessageView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.dismissTitle
        label.font = GiniConfiguration.shared.textStyleFonts[.bodyBold]
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .GiniCapture.accent1
        progress.trackTintColor = .darkGray
        progress.progress = 0.3
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.systemGray5.cgColor
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true

        addSubview(titleLabel)
        addSubview(progressView)
    }

    private func setupConstraints() {
        titleLabel.giniMakeConstraints {
            $0.top.equalToSuperview().constant(Constants.padding)
            $0.leading.equalToSuperview().constant(Constants.horizontalPadding)
            $0.trailing.equalToSuperview().constant(-Constants.horizontalPadding)
        }

        progressView.giniMakeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Constants.progressHeight)
        }
    }

    // MARK: - Public Method
    func setProgress(_ value: Float, animated: Bool = true) {
        progressView.setProgress(value, animated: animated)
    }

}

// MARK: - Strings
private extension DismissMessageView {
    enum Strings {
        static let dismissTitle = NSLocalizedStringPreferredFormat(
            "ginicapture.dismiss.message.title",
            comment: "Title for the dismiss message view"
        )
    }

    // MARK: - Constants
    enum Constants {
        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1
        static let progressHeight: CGFloat = 6
        static let padding: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
    }
}

#if DEBUG
import SwiftUI

struct DismissMessageView_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            let viewController = UIViewController()
            viewController.view.backgroundColor = .lightGray

            let dismissMessageView = DismissMessageView()
            viewController.view.addSubview(dismissMessageView)

            dismissMessageView.giniMakeConstraints {
                $0.center.equalToSuperview()
                $0.height.equalTo(50)
                $0.horizontal.equalToSuperview().constant(20)
            }
            return viewController
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
