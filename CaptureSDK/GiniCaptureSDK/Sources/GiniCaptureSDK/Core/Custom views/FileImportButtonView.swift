//
//  FileImportButtonView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/15/19.
//

import UIKit

final class FileImportButtonView: UIView {

    var didTapButton: (() -> Void)?

    fileprivate var documentImportButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "documentImportButton")
    }

    lazy var importFileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.documentImportButtonImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(showImportFileSheet), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()

    lazy var importFileSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(resource: CameraStrings.importFileButtonLabel)
        label.font = GiniConfiguration.shared.customFont.with(weight: .regular, size: 12, style: .footnote)
        label.textAlignment = .center
        label.textColor = .white
        label.minimumScaleFactor = 10 / label.font.pointSize
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    init(giniConfiguration: GiniConfiguration = .shared) {
        super.init(frame: .zero)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        addSubview(importFileButton)
        addSubview(importFileSubtitleLabel)

        importFileButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        importFileButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        importFileButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        importFileButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        importFileButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        importFileSubtitleLabel.centerXAnchor.constraint(equalTo: importFileButton.centerXAnchor).isActive = true
        importFileSubtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        importFileSubtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        importFileSubtitleLabel.topAnchor.constraint(equalTo: importFileButton.bottomAnchor,
                                                     constant: 0).isActive = true
    }

    @objc fileprivate func showImportFileSheet(_ sender: UIButton) {
        didTapButton?()
    }

}
