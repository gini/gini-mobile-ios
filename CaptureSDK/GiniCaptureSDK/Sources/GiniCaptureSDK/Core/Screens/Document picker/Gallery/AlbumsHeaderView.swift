//
//  AlbumsHeaderView.swift
//  GiniCapture
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class AlbumsHeaderView: UITableViewHeaderFooterView {
    var didTapSelectButton: (() -> Void) = {
        // This closure will remain empty; no implementation is needed.
    }
    @IBOutlet var selectPhotosButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
        let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.albums.selectMorePhotosButton",
                                                           comment: "Title for select more photos button")
        selectPhotosButton.titleLabel?.font = configuration.textStyleFonts[.footnote]
        selectPhotosButton.setTitle(buttonTitle, for: .normal)
        selectPhotosButton.titleLabel?.isAccessibilityElement = true
        selectPhotosButton.titleLabel?.accessibilityValue = buttonTitle
        selectPhotosButton.setTitleColor(.GiniCapture.accent1, for: .normal)
        selectPhotosButton.sizeToFit()
        selectPhotosButton.titleLabel?.adjustsFontForContentSizeCategory = true
        selectPhotosButton.isExclusiveTouch = true
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func selectMorePhotosTapped(_ sender: Any) {
        didTapSelectButton()
    }
}
