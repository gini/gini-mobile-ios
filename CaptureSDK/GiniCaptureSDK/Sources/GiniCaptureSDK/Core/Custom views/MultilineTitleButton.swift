//
//  MultilineTitleButton.swift
//  
//
//  Created by Krzysztof Kryniecki on 29/08/2022.
//

import UIKit

/**
- internal only

 `MultilineTitleButton` is a subclass of `UIButton`and it allows for multiple lines of text
 to be displayed in the button's title, and the button's size is adjusted to fit the text. The content hugging priority is set s
 o that the button's width and height can be adjusted by the Auto Layout system.
 **/

public class MultilineTitleButton: GiniCaptureButton {

    /**
     `init?(coder:)` is used for creating an instance of the class from a nib file
     **/
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     `init(frame:)` is used for creating an instance of the class programmatically
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
        setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
        isExclusiveTouch = true
    }

    /**
     The class overrides the `intrinsicContentSize` property to adjust the size of the button
     based on the intrinsic size of the title label and the content edge insets.
     */
    public override var intrinsicContentSize: CGSize {
        let size = titleLabel!.intrinsicContentSize
        return CGSize(
            width: size.width + contentEdgeInsets.left + contentEdgeInsets.right,
            height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }

    /**
     It also overrides the `layoutSubviews()` function to set the preferred maximum
     layout width of the title label to the width of the button.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}
