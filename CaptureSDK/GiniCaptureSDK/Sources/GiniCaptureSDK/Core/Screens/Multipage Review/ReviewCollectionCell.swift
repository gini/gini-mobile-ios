//
//  ReviewCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import UIKit

final class ReviewCollectionCell: UICollectionViewCell {
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.documentImageTitle",
                                                                        comment: "Document")
        imageView.backgroundColor = GiniColor(light: UIColor.GiniCapture.light3,
                                              dark: UIColor.GiniCapture.dark3).uiColor()
        return imageView
    }()

    var isActive: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.documentImage.layer.borderColor = self.isActive ? UIColor.GiniCapture.accent1.cgColor : UIColor.clear.cgColor
                self.documentImage.layer.borderWidth = self.isActive ? 2 : 0
            }
        }
    }

    lazy var errorView: NoticeView = {
        let noticeView = NoticeView(text: "",
                                    type: .error,
                                    noticeAction: NoticeAction(title: "", action: {}))
        noticeView.translatesAutoresizingMaskIntoConstraints = false

        noticeView.hide(false, completion: nil)
        return noticeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(documentImage)
        addSubview(errorView)

        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    private func addConstraints() {
        Constraints.pin(view: documentImage, toSuperView: self)
        Constraints.pin(view: errorView, toSuperView: self, positions: [.top, .left, .right])
        Constraints.center(view: documentImage, with: self)
    }
}
