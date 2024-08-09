//
//  InvoicePreviewViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

final class InvoicePreviewViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(GiniImages.closeIcon.image, for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.isExclusiveTouch = true
        return closeButton
    }()

    private var viewModel: InvoicePreviewViewModel?

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(viewModel: InvoicePreviewViewModel) {
        self.viewModel = viewModel
        showProcessedImages()
    }

    private func showProcessedImages() {
        guard let viewModel else { return }
        // Process each image and draw the corresponding bounding area
        
        imageView.image = viewModel.processImages()[0]
    }

    // MARK: Private methods
    private func setupViews() {
        view.backgroundColor = UIColor.GiniCapture.dark1
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)

        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }

    private func setupLayout() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        imageView.frame = scrollView.bounds

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: Constants.buttonPadding),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: Constants.buttonPadding),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}

private extension InvoicePreviewViewController {
    enum Constants {
        static let padding: CGFloat = 24
        static let spacing: CGFloat = 36
        static let buttonSize: CGFloat = 44
        static let buttonPadding: CGFloat = 16
    }
}
