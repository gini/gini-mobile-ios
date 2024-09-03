//
//  AttachmentsView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public protocol AttachmentsViewDelegate: AnyObject {
    func attachmentsViewDidUpdateContent(_ attachmentsView: AttachmentsView)
}

public class AttachmentsView: UIView {

    public weak var delegate: AttachmentsViewDelegate?

    private var attachments: [Attachment] = []

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Constants.containerViewBorderColor.cgColor
        view.layer.borderWidth = Constants.containerViewBorderWidth
        view.layer.cornerRadius = Constants.containerViewBorderCornerRadius
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.stackViewSpacing
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var headerView: AttachmentHeaderView = {
        return AttachmentHeaderView()
    }()

    private lazy var footerView: AttachmentFooterView = {
        let footerView = AttachmentFooterView()
        footerView.addButtonAction = { [weak self] in
            self?.addAttachment()
        }
        return footerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        addSubview(containerView)
        containerView.addSubview(stackView)

        setupStackViewContent()
        setupConstraints()
    }

    public func updateAttachments(_ newAttachments: [Attachment]) {
        attachments = newAttachments
        setupStackViewContent()
    }

    private func setupStackViewContent() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.addArrangedSubview(headerView)

        for (index, attachment) in attachments.enumerated() {
            let attachmentView = AttachmentView(attachment: attachment)
            attachmentView.optionsAction = { [weak self] in
                self?.optionsForAttachment(at: index)
            }
            stackView.addArrangedSubview(attachmentView)
        }

        stackView.addArrangedSubview(footerView)
        delegate?.attachmentsViewDidUpdateContent(self)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                               constant: Constants.stackViewPadding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                constant: -Constants.stackViewPadding),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                           constant: Constants.stackViewPadding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                              constant: -Constants.stackViewPadding)
        ])
    }

    @objc private func addAttachment() {
        attachments.append(.init(fileName: UUID().uuidString, type: .document))
        setupStackViewContent()
    }

    private func optionsForAttachment(at index: Int) {
        attachments.remove(at: index)
        setupStackViewContent()
    }
}

private extension AttachmentsView {
    enum Constants {
        static let containerViewBorderColor: UIColor = .giniColorScheme().bg.border.uiColor()
        static let containerViewBorderWidth: CGFloat = 1.0
        static let containerViewBorderCornerRadius: CGFloat = 8.0
        static let containerViewLeadingAnchor: CGFloat = 16
        static let containerViewTrailingAnchor: CGFloat = -16

        static let stackViewSpacing: CGFloat = 0
        static let stackViewPadding: CGFloat = 0
    }
}
