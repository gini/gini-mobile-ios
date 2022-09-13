//
//  MultipageReviewMainCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import UIKit

final class MultipageReviewMainCollectionCell: UICollectionViewCell {
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        imageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.documentImageTitle",
                                                                        comment: "Document")
        
        return imageView
    }()

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
