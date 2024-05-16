//
//  ThumbnailView.swift
//  
//
//  Created by Krzysztof Kryniecki on 07/09/2022.
//

import UIKit

final class ThumbnailView: UIView {

    enum State {
        case filled(count: Int, lastImage: UIImage), empty
    }

    var didTapImageStackButton: (() -> Void)?
    let thumbnailSize = CGSize(width: 44, height: 52)
    private var giniConfiguration: GiniConfiguration = .shared
    private let stackCountCircleSize = CGSize(width: 20, height: 20)
    private var imagesCount: Int = 0

    lazy var thumbnailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(thumbnailButtonAction), for: .touchUpInside)
        button.isExclusiveTouch = true
        return button
    }()

    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var stackIndicatorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.font = giniConfiguration.textStyleFonts[.caption1]
        label.textColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.light1).uiColor()
        label.adjustsFontSizeToFitWidth = true
        label.text = ""
        return label
    }()

    fileprivate lazy var stackIndicatorCircleView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stackCountCircleSize
        view.layer.cornerRadius = stackCountCircleSize.height * 0.5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.GiniCapture.dark5.cgColor
        view.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.accent1,
            dark: UIColor.GiniCapture.accent1).uiColor()
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbnailImageView)
        addSubview(stackIndicatorCircleView)
        addSubview(thumbnailButton)
        stackIndicatorCircleView.addSubview(stackIndicatorLabel)
        addConstraints()
    }

    func configureView(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
    }

    func addImageToStack(image: UIImage) {
        updateStackStatus(to: .filled(count: imagesCount + 1, lastImage: image))
    }

    func updateStackStatus(to status: State) {
        switch status {
        case .filled(let count, let lastImage):
            imagesCount = count
            thumbnailImageView.image = lastImage
            isHidden = false
            accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.thumbnail.Voice.Over",
                comment: "Thumbnail button") + " \(count)"
        case .empty:
            imagesCount = 0
            thumbnailImageView.image = nil
            isHidden = true
            accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.thumbnail.Voice.Over",
                comment: "Thumbnail button") + " 0"
        }

        stackIndicatorLabel.text = "\(imagesCount)"
    }

    @objc fileprivate func thumbnailButtonAction() {
        didTapImageStackButton?()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            thumbnailButton.topAnchor.constraint(equalTo: topAnchor),
            thumbnailButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackIndicatorCircleView.topAnchor.constraint(equalTo: topAnchor),
            stackIndicatorCircleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackIndicatorCircleView.heightAnchor.constraint(equalToConstant: stackCountCircleSize.height),
            stackIndicatorCircleView.widthAnchor.constraint(equalToConstant: stackCountCircleSize.width),
            stackIndicatorLabel.leadingAnchor.constraint(equalTo: stackIndicatorCircleView.leadingAnchor),
            stackIndicatorLabel.trailingAnchor.constraint(equalTo: stackIndicatorCircleView.trailingAnchor),
            stackIndicatorLabel.topAnchor.constraint(equalTo: stackIndicatorCircleView.topAnchor),
            stackIndicatorLabel.bottomAnchor.constraint(equalTo: stackIndicatorCircleView.bottomAnchor),
            heightAnchor.constraint(equalToConstant: thumbnailSize.height),
            widthAnchor.constraint(equalToConstant: thumbnailSize.width)
        ])
    }
}
