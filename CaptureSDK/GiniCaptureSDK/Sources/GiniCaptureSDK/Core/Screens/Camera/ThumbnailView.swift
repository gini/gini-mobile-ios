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
    private var giniConfiguration: GiniConfiguration!
    fileprivate let stackCountCircleSize = CGSize(width: 20, height: 20)
    fileprivate var imagesCount: Int = 0
    
    lazy var thumbnailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(thumbnailButtonAction), for: .touchUpInside)
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
        label.text = "3"
        label.textColor = UIColor.gray//giniConfiguration.imagesStackIndicatorLabelTextcolor
        return label
    }()
    
    fileprivate lazy var stackIndicatorCircleView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stackCountCircleSize
        view.backgroundColor = .green
        return view
    }()
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbnailImageView)
        addSubview(stackIndicatorCircleView)
        addSubview(thumbnailButton)
        
        stackIndicatorCircleView.addSubview(stackIndicatorLabel)
        addConstraints()
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
            //thumbnailStackBackgroundView.isHidden = count < 2
            thumbnailButton.setImage(lastImage, for: .normal)
            isHidden = false
        case .empty:
            imagesCount = 0
            //thumbnailStackBackgroundView.isHidden = true
            thumbnailButton.setImage(nil, for: .normal)
            isHidden = true
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
            stackIndicatorLabel.centerXAnchor.constraint(equalTo: stackIndicatorCircleView.centerXAnchor),
            stackIndicatorLabel.centerYAnchor.constraint(equalTo: stackIndicatorCircleView.centerYAnchor)
        ])
    }
}
