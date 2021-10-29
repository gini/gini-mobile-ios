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
        selectPhotosButton.titleLabel?.font = configuration.customFont.with(weight: .regular, size: 16, style: .footnote)
        selectPhotosButton.setTitle(buttonTitle, for: .normal)
        selectPhotosButton.setTitleColor(configuration.navigationBarTintColor, for: .normal)
        selectPhotosButton.sizeToFit()
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
