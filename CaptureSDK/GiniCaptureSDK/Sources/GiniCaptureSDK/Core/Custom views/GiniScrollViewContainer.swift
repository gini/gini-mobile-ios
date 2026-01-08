//
//  GiniScrollViewContainer.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

/**
 A scroll view container that provides a content view for adding subviews and publishes size changes.

 This class wraps a `UIScrollView` with a content view and automatically handles layout constraints.
 It publishes content size changes through a `@Published` property for reactive programming.
 */
public final class GiniScrollViewContainer: UIScrollView {

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var cancellables = Set<AnyCancellable>()

    @Published public var size: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addContentSubview(_ view: UIView) {
        contentView.addSubview(view)
    }

    private func setupView() {
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        bindToSizeUpdates()
    }

    private func bindToSizeUpdates() {
        publisher(for: \.contentSize)
            .filter({ $0.height > 0 })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.size = value
            }.store(in: &cancellables)
    }
}
