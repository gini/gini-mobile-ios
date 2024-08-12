//
//  DocumentPagesViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

final class DocumentPagesViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewItemSpacing
        return stackView
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

    private lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect.zero)
        return loadingIndicatorContainer
    }()

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.startAnimating()
        return indicatorView
    }()

    private var viewModel: DocumentPagesViewModel?
    private let configuration = GiniBankConfiguration.shared

    // Constraints
    private var stackViewTopConstraint: NSLayoutConstraint?

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(viewModel: DocumentPagesViewModel) {
        self.viewModel = viewModel
        showProcessedImages()
    }

    // MARK: Toggle animation

    /// Displays a loading activity indicator
    public func showAnimation() {
        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /// Hides the loading activity indicator
   func hideAnimation() {
        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }

    /**
     Set up the view elements on the screen
     */

    private func setupViews() {
        view.backgroundColor = UIColor.GiniCapture.dark1
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)
        // Set up the scroll view
        setupScrollView()
        scrollView.addSubview(stackView)
        configureLoadingIndicator()
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecognizeDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

    }

    private func setupLayout() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let stackViewTopConstraintConstant = Constants.navigationBarHeight + Constants.stackViewTopConstraintToNavBar
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                                                constant: stackViewTopConstraintConstant)
        stackViewTopConstraint?.isActive = true
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Stack view
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                               constant: Constants.containerHorizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                constant: -Constants.containerHorizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerHorizontalPadding),

            // CLose button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: Constants.buttonPadding),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: Constants.buttonPadding),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])

        scrollView.layoutIfNeeded()
    }

    // MARK: - Handle Loading indicator
    private func configureLoadingIndicator() {
        loadingIndicatorView.color = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()

        addLoadingContainer()
        addLoadingView(intoContainer: loadingIndicatorContainer)
    }

    private func addLoadingView(intoContainer container: UIView? = nil) {
        let loadingIndicator: UIView

        if let customLoadingIndicator = configuration.customLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(container)
            container.addSubview(loadingIndicator)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                container.heightAnchor.constraint(equalToConstant: Constants.loadingIndicatorContainerHeight),
                container.widthAnchor.constraint(equalTo: container.heightAnchor),
                loadingIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        } else {
            view.addSubview(loadingIndicatorView)

            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }

    private func addLoadingContainer() {
        loadingIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicatorContainer)
        NSLayoutConstraint.activate([
            loadingIndicatorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicatorContainer.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            loadingIndicatorContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                               constant: Constants.padding)])
    }

    // MARK: Private methods

    private func showProcessedImages() {
        guard let viewModel else { return }
        let images = viewModel.processImages()
        // Calculate dynamic height (65% of screen height)
        let imageViewHeight = UIScreen.main.bounds.height * 0.65

        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false

            // Apply the dynamic height constraint
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true

            stackView.addArrangedSubview(imageView)
        }

        if images.count == 1 {
            stackViewTopConstraint?.constant = Constants.navigationBarHeight + Constants.stackViewTopConstraintToNavBar
        } else {
            stackViewTopConstraint?.constant = Constants.stackViewTopConstraintToNavBar
        }
    }
    // MARK: - Actions

    @objc private func didRecognizeDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let shouldZoomOut = scrollView.zoomScale != 1.0
        if shouldZoomOut {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let tapPoint = gestureRecognizer.location(in: stackView)
            let newZoomScale = scrollView.maximumZoomScale
            let zoomedRectSize = CGSize(width: scrollView.bounds.size.width / newZoomScale,
                                        height: scrollView.bounds.size.height / newZoomScale)
            let zoomedRectOrigin = CGPoint(x: tapPoint.x - zoomedRectSize.width / 2,
                                           y: tapPoint.y - zoomedRectSize.height / 2)
            let rectToZoom = CGRect(origin: zoomedRectOrigin, size: zoomedRectSize)
            scrollView.zoom(to: rectToZoom, animated: true)
        }
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}

extension DocumentPagesViewController: UIScrollViewDelegate {
    // Delegate method to specify the view to zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return stackView
    }
}

private extension DocumentPagesViewController {
    enum Constants {
        static let padding: CGFloat = 24
        static let spacing: CGFloat = 36
        static let buttonSize: CGFloat = 44
        static let buttonPadding: CGFloat = 16
        static let stackViewItemSpacing: CGFloat = 4
        static let containerHorizontalPadding: CGFloat = 4
        static let loadingIndicatorContainerHeight: CGFloat = 60
        static let navigationBarHeight: CGFloat = 90
        static let stackViewTopConstraintToNavBar: CGFloat = 56
    }
}
