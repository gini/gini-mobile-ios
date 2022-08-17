//
//  CaptureSuggestionsCollectionHeader.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsCollectionHeader: UICollectionReusableView {

    static let topContainerHeight: CGFloat = 100
    static let subHeaderHeight: CGFloat = 60

    private let topViewIconWidth: CGFloat = 25
    private var leadingTopViewTextConstraint: NSLayoutConstraint?
    private var bottomTopViewContainerConstraint: NSLayoutConstraint?

    var shouldShowTopViewIcon: Bool = true {
        didSet {
            if !shouldShowTopViewIcon {
                topViewIcon.removeFromSuperview()
                leadingTopViewTextConstraint?.isActive = true
            }
        }
    }

    var shouldShowSubHeader: Bool = true {
        didSet {
            if !shouldShowSubHeader {
                subHeaderTitle.removeFromSuperview()
                topViewContainerBottomLine.removeFromSuperview()
                bottomTopViewContainerConstraint?.isActive = true
            }
        }
    }

    // Views
    lazy var topViewContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    lazy var topViewContainerBottomLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .lightGray
        return line
    }()

    lazy var topViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = GiniConfiguration.shared.noResultsWarningContainerIconColor
        return icon
    }()

    lazy var topViewText: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.numberOfLines = 0
        return text
    }()

    lazy var subHeaderTitle: UILabel = {
        let subHeaderTitle = UILabel()
        subHeaderTitle.translatesAutoresizingMaskIntoConstraints = false
        subHeaderTitle.numberOfLines = 0
        return subHeaderTitle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        topViewContainer.addSubview(topViewContainerBottomLine)
        topViewContainer.addSubview(topViewText)
        topViewContainer.addSubview(topViewIcon)
        addSubview(topViewContainer)
        addSubview(subHeaderTitle)
        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }

    private func addConstraints() {
        // Top view container bottom line
        Constraints.active(item: topViewContainerBottomLine, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: 0.5)
        Constraints.active(item: topViewContainerBottomLine, attr: .width, relatedBy: .equal, to: topViewContainer,
                          attr: .width)
        Constraints.active(item: topViewContainerBottomLine, attr: .top, relatedBy: .equal, to: topViewContainer,
                          attr: .bottom)

        // Top Container
        Constraints.active(item: topViewContainer, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: topViewContainer, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Constraints.active(item: topViewContainer, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        Constraints.active(item: topViewContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 100)
        bottomTopViewContainerConstraint = NSLayoutConstraint(item: topViewContainer, attribute: .bottom,
                                                              relatedBy: .equal, toItem: self, attribute: .bottom,
                                                              multiplier: 1, constant: 0)

        // Top Icon
        Constraints.active(item: topViewIcon, attr: .top, relatedBy: .equal, to: topViewContainer, attr: .top,
                          constant: 16)
        Constraints.active(item: topViewIcon, attr: .bottom, relatedBy: .equal, to: topViewContainer, attr: .bottom,
                          constant: -16)
        Constraints.active(item: topViewIcon, attr: .leading, relatedBy: .equal, to: topViewContainer, attr: .leading,
                          constant: 16)
        Constraints.active(item: topViewIcon, attr: .trailing, relatedBy: .equal, to: topViewText, attr: .leading,
                          constant: -16)
        Constraints.active(item: topViewIcon, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: topViewIconWidth)

        // Top text
        Constraints.active(item: topViewText, attr: .top, relatedBy: .equal, to: topViewContainer, attr: .top,
                          constant: 16)
        Constraints.active(item: topViewText, attr: .bottom, relatedBy: .equal, to: topViewContainer, attr: .bottom,
                          constant: -16)
        Constraints.active(item: topViewText, attr: .trailing, relatedBy: .equal, to: topViewContainer, attr: .trailing,
                          constant: -16, priority: 999)
        leadingTopViewTextConstraint = NSLayoutConstraint(item: topViewText, attribute: .leading, relatedBy: .equal,
                                                          toItem: topViewContainer, attribute: .leading, multiplier: 1,
                                                          constant: 16)

        // Sub header title
        Constraints.active(item: subHeaderTitle, attr: .top, relatedBy: .equal, to: topViewContainerBottomLine,
                          attr: .bottom, constant: 20)
        Constraints.active(item: subHeaderTitle, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: 20)
        Constraints.active(item: subHeaderTitle, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -20)
        Constraints.active(item: subHeaderTitle, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
    }
}
