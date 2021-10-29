//
//  CapturedImagesStackView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/25/18.
//

import UIKit

final class CapturedImagesStackView: UIView {
    
    enum State {
        case filled(count: Int, lastImage: UIImage), empty
    }
    
    let thumbnailSize: CGSize = {
        if UIDevice.current.isIpad {
            return CGSize(width: 40, height: 60)
        } else {
            return CGSize(width: 30, height: 45)
        }
    }()
    var didTapImageStackButton: (() -> Void)?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let stackCountCircleSize = CGSize(width: 25, height: 25)
    fileprivate var imagesCount: Int = 0
    
    lazy var thumbnailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: -2, height: 2)
        button.addTarget(self, action: #selector(thumbnailButtonAction), for: .touchUpInside)
        button.layer.shadowPath = UIBezierPath(rect: button.bounds).cgPath
        
        return button
    }()
    
    lazy var thumbnailStackBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()
    
    lazy var stackIndicatorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = giniConfiguration.imagesStackIndicatorLabelTextcolor
        return label
    }()
    
    fileprivate lazy var stackIndicatorCircleView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stackCountCircleSize
        view.backgroundColor = .white
        view.layer.cornerRadius = self.stackCountCircleSize.width / 2
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        return view
    }()
    
    fileprivate lazy var capturedImagesStackSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(resource: CameraStrings.capturedImagesStackSubtitleLabel)
        label.textAlignment = .center
        label.textColor = .white
        label.font = giniConfiguration.customFont.with(weight: .regular, size: 12, style: .footnote)
        label.numberOfLines = 0
        label.minimumScaleFactor = 10 / label.font.pointSize
        label.adjustsFontSizeToFitWidth = true

        return label
    }()
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(frame: .zero)
        addSubview(thumbnailStackBackgroundView)
        addSubview(thumbnailButton)
        addSubview(stackIndicatorCircleView)
        addSubview(capturedImagesStackSubtitleLabel)
        stackIndicatorCircleView.addSubview(stackIndicatorLabel)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(frame:) initializer instead")
    }

}

// MARK: - Public methods

extension CapturedImagesStackView {
    /**
     Return the thumbnail frame relative to a given view coordinate space.
     Used to make a transition from the thumbnail to a new screen.
     */
    func thumbnailFrameRelative(to view: UIView) -> CGRect {
        return convert(thumbnailButton.frame, to: view)
    }
    
    func replaceStackImages(with images: [UIImage]) {
        if let lastImage = images.last {
            updateStackStatus(to: .filled(count: images.count, lastImage: lastImage))
        } else {
            updateStackStatus(to: .empty)
        }
    }
    
    func addImageToStack(image: UIImage) {
        updateStackStatus(to: .filled(count: imagesCount + 1, lastImage: image))
    }
    
    private func updateStackStatus(to status: State) {
        switch status {
        case .filled(let count, let lastImage):
            imagesCount = count
            thumbnailStackBackgroundView.isHidden = count < 2
            thumbnailButton.setImage(lastImage, for: .normal)
            isHidden = false
        case .empty:
            imagesCount = 0
            thumbnailStackBackgroundView.isHidden = true
            thumbnailButton.setImage(nil, for: .normal)
            isHidden = true
        }
        
        stackIndicatorLabel.text = "\(imagesCount)"
    }
}

// MARK: - Private methods

extension CapturedImagesStackView {
    @objc fileprivate func thumbnailButtonAction() {
        didTapImageStackButton?()
    }
    
    fileprivate func addConstraints() {
        // multipageReviewButton
        Constraints.active(item: thumbnailButton, attr: .centerX, relatedBy: .equal,
                           to: self, attr: .centerX)
        Constraints.active(item: thumbnailButton, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height, priority: 999)
        Constraints.active(item: thumbnailButton, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width, priority: 999)
        
        // multipageReviewBackgroundView
        Constraints.active(item: thumbnailStackBackgroundView, attr: .centerY, relatedBy: .equal,
                           to: thumbnailButton, attr: .centerY, constant: 3)
        Constraints.active(item: thumbnailStackBackgroundView, attr: .centerX, relatedBy: .equal,
                           to: thumbnailButton, attr: .centerX, constant: -3)
        Constraints.active(item: thumbnailStackBackgroundView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height, priority: 999)
        Constraints.active(item: thumbnailStackBackgroundView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width, priority: 999)
        
        // stackIndicatorCircleView
        Constraints.active(item: stackIndicatorCircleView, attr: .trailing, relatedBy: .equal,
                           to: thumbnailButton, attr: .trailing, constant: stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .top, relatedBy: .equal,
                           to: thumbnailButton, attr: .top, constant: -stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.height)
        Constraints.active(item: stackIndicatorCircleView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.width)
        Constraints.active(item: stackIndicatorCircleView, attr: .top, relatedBy: .greaterThanOrEqual,
                           to: self, attr: .top, constant: 10)
        // stackIndicatorLabel
        Constraints.active(item: stackIndicatorLabel, attr: .centerX, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerX)
        Constraints.active(item: stackIndicatorLabel, attr: .centerY, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerY)
        
        // capturedImagesStackSubtitleLabel
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .bottom, relatedBy: .equal,
                           to: self, attr: .bottom)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .top, relatedBy: .equal,
                           to: thumbnailStackBackgroundView, attr: .bottom, constant: 4, priority: 999)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .leading, relatedBy: .equal,
                           to: self, attr: .leading)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .trailing, relatedBy: .equal,
                           to: self, attr: .trailing)
        
    }
}
