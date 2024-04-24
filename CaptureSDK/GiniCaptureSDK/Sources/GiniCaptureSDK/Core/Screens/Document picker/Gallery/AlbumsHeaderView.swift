//
//  AlbumsHeaderView.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.08.21.
//

import UIKit

final class AlbumsHeaderView: UITableViewHeaderFooterView {
    var didTapSelectButton: (() -> Void) = {}
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
