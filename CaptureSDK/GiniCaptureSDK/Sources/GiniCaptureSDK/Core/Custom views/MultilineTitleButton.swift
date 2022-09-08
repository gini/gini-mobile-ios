//
//  MultilineTitleButton.swift
//  
//
//  Created by Krzysztof Kryniecki on 29/08/2022.
//

import UIKit

class MultilineTitleButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() -> Void {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
    }

    override var intrinsicContentSize: CGSize {
        let size = self.titleLabel!.intrinsicContentSize
        return CGSize(width: size.width + contentEdgeInsets.left + contentEdgeInsets.right, height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}
