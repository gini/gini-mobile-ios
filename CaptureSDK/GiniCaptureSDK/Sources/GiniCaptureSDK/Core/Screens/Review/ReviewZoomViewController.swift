//
//  ReviewZoomViewController.swift
//  
//
//  Created by David Vizaknai on 04.10.2022.
//

import UIKit

final class ReviewZoomViewController: UIViewController {
    private lazy var scrollView = UIScrollView()
    private lazy var imageView = UIImageView()
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImageNamedPreferred(named: "close_icon"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return closeButton
    }()
    private var page: GiniCapturePage

    // MARK: - Init

    init(page: GiniCapturePage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationStyle = .fullScreen
        setupView()
        setupLayout()
        setupImage(page.document.previewImage)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustContentSize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        scrollView.setZoomScale(1, animated: false)
    }

    // MARK: - Setup View

    private func setupView() {
        view.backgroundColor = UIColor.GiniCapture.dark1

        scrollView.backgroundColor = view.backgroundColor
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
        view.addSubview(scrollView)

        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecognizeDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }

    private func setupLayout() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        imageView.frame = scrollView.bounds

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Setup content

    private func setupImage(_ image: UIImage?) {
        imageView.image = image
    }

    // MARK: - Callbacks

    @objc
    private func didRecognizeDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let shouldZoomOut = scrollView.zoomScale != 1.0
        if shouldZoomOut {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let tapPoint = gestureRecognizer.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            let zoomedRectSize = CGSize(width: scrollView.bounds.size.width / newZoomScale,
                                        height: scrollView.bounds.size.height / newZoomScale)
            let zoomedRectOrigin = CGPoint(x: tapPoint.x - zoomedRectSize.width / 2,
                                           y: tapPoint.y - zoomedRectSize.height / 2)
            let rectToZoom = CGRect(origin: zoomedRectOrigin, size: zoomedRectSize)
            scrollView.zoom(to: rectToZoom, animated: true)
        }
    }

    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
    }

    // MARK: - Utilities

    fileprivate func adjustContentSize() {
        guard let image = self.imageView.image else {
            imageView.frame = scrollView.bounds
            return
        }

        let fitSize = scrollView.frame.size
        let widthRatio = fitSize.width / image.size.width
        let heightRatio = fitSize.height / image.size.height
        let ratio = min(widthRatio, heightRatio)
        let imageSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        imageView.frame = CGRect(origin: CGPoint.zero, size: imageSize)
        scrollView.contentSize = imageSize
        adjustImageToCenter()
    }

    fileprivate func adjustImageToCenter() {
        let scrollViewSize = scrollView.bounds.size
        var contentFrame = imageView.frame

        let yOffset = max(0, (scrollViewSize.height - contentFrame.height) / 2)
        contentFrame.origin.y = yOffset

        let xOffset = max(0, (scrollViewSize.width - contentFrame.width) / 2)
        contentFrame.origin.x = xOffset

        imageView.frame = contentFrame
    }
}

// MARK: - UIScrollViewDelegate

extension ReviewZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustImageToCenter()
    }
}
