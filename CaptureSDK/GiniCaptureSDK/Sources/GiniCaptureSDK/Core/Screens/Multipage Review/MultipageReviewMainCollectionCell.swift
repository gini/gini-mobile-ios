//
//  MultipageReviewMainCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import UIKit

final class MultipageReviewMainCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewMainCollectionCellIdentifier"
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        imageView.accessibilityLabel = NSLocalizedString("ginicapture.review.documentImageTitle",
                                                         bundle: Bundle.module,
                                                         comment: "Document")
        
        return imageView
    }()
    
    lazy var zoomableScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        return scrollView
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
        zoomableScrollView.addSubview(documentImage)
        addSubview(zoomableScrollView)
        addSubview(errorView)

        addConstraints()
        addDoubleTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    private func addConstraints() {
        Constraints.pin(view: documentImage, toSuperView: zoomableScrollView)
        Constraints.pin(view: zoomableScrollView, toSuperView: self)
        Constraints.pin(view: errorView, toSuperView: self, positions: [.top, .left, .right])
        Constraints.center(view: documentImage, with: zoomableScrollView)
    }
    
    private func addDoubleTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.addTarget(self, action: #selector(doubleTapToZoom))
        zoomableScrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func doubleTapToZoom() {
        if zoomableScrollView.zoomScale == 1.0 {
            zoomableScrollView.setZoomScale(2.0, animated: true)
        } else {
            zoomableScrollView.setZoomScale(1.0, animated: true)
        }
    }
        
}

// MARK: - UIScrollViewDelegate

extension MultipageReviewMainCollectionCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return documentImage
    }
}
