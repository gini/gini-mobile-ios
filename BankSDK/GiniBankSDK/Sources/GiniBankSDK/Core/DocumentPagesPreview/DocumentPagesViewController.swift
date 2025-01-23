//
//  DocumentPagesViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

final class DocumentPagesViewController: UIViewController {
    private lazy var statusBarBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .GiniBank.dark1.withAlphaComponent(0.5)
        return view
    }()

    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = .GiniBank.dark1.withAlphaComponent(0.5)
        navBar.titleTextAttributes = [.font: configuration.textStyleFonts[.bodyBold] as Any,
                                      .foregroundColor: UIColor.GiniBank.light1]
        return navBar
    }()

    private lazy var cancelButton: GiniBarButton = {
        let button = GiniBarButton(ofType: .cancel)
        button.addAction(self, #selector(didTapClose))
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewItemSpacing
        return stackView
    }()

    private lazy var footerView: DocumentPagesFooterView = {
        let footerView = DocumentPagesFooterView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()

    private lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect.zero)
        return loadingIndicatorContainer
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        return indicatorView
    }()

    private var viewModel: DocumentPagesViewModelProtocol?
    private let configuration = GiniBankConfiguration.shared
    private let screenTitle: String?
    private let errorButtonTitle: String
    private var errorView: DocumentPagesErrorView?

    // Constraints
    private var contentStackViewTopConstraint: NSLayoutConstraint?

    private var zoomAnalyticsEventSent: Bool = false
    
    // MARK: - Init
    init(screenTitle: String? = nil, errorButtonTitle: String) {
        self.screenTitle = screenTitle
        self.errorButtonTitle = errorButtonTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        startLoadingIndicatorAnimation()
    }

    func setData(viewModel: DocumentPagesViewModelProtocol) {
        self.viewModel = viewModel
        if viewModel.rightBarButtonAction != nil {
            let buttonImage = GiniImages.transactionDocsOptionsIcon.image
            let optionsButton = UIBarButtonItem(image: buttonImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(didTapOptionsButton))
            navigationBar.topItem?.rightBarButtonItem = optionsButton
        }

        GiniAnalyticsManager.trackScreenShown(screenName: .skontoInvoicePreview)
        showProcessedImages()
        showSkontoDetailsInFooter()
    }

    func setError(errorType: ErrorType, tryAgainAction: @escaping () -> Void) {
        let errorView = DocumentPagesErrorView(errorType: errorType,
                                               buttonTitle: errorButtonTitle,
                                               buttonAction: { [weak self] in
            self?.handleTryAgainAction(tryAgainAction)
        })

        sendAnalyticsErrorScreenShown(with: errorType)
        view.addSubview(errorView)

        errorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.errorView = errorView
    }

    private func handleTryAgainAction(_ tryAgainAction: @escaping () -> Void) {
        GiniAnalyticsManager.track(event: .tryAgainTapped, screenName: .skontoInvoicePreviewError)
        tryAgainAction()
        removeErrorView()
    }

    private func sendAnalyticsErrorScreenShown(with errorType: ErrorType) {
        var eventProperties = [GiniAnalyticsProperty]()

        let errorAnalytics = errorType.errorAnalytics()
        eventProperties.append(GiniAnalyticsProperty(key: .errorType, value: errorAnalytics.type))
        if let code = errorAnalytics.code {
            eventProperties.append(GiniAnalyticsProperty(key: .errorCode, value: code))
        }

        if let reason = errorAnalytics.reason {
            eventProperties.append(GiniAnalyticsProperty(key: .errorMessage, value: reason))
        }

        GiniAnalyticsManager.trackScreenShown(screenName: .skontoInvoicePreviewError,
                                              properties: eventProperties)
    }

    private func removeErrorView() {
        guard let errorView = errorView else { return }
        errorView.removeFromSuperview()
        self.errorView = nil
    }

    // MARK: Toggle animation

    /// Start the loading activity indicator animation
    func startLoadingIndicatorAnimation() {
        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /// Stops the loading activity indicator
   func stopLoadingIndicatorAnimation() {
        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }

    /// Set up the view elements on the screen

    private func setupViews() {
        view.backgroundColor = .GiniCapture.dark1
        view.addSubview(scrollView)

        setupStatusBarBackground()

        setupNavigationBar()
        setupFooterView()
        setupScrollView()
        scrollView.addSubview(contentStackView)
        configureLoadingIndicator()
    }

    private func setupStatusBarBackground() {
        view.addSubview(statusBarBackgroundView)

        NSLayoutConstraint.activate([
            statusBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    private func setupNavigationBar() {
        view.addSubview(navigationBar)

        // Create a navigation item with a title and a cancel button
        let navigationItem = UINavigationItem(title: screenTitle ?? "")
        navigationItem.leftBarButtonItem = cancelButton.barButton

        // Assign the navigation item to the navigation bar
        navigationBar.setItems([navigationItem], animated: false)

        // Set constraints for the navigation bar
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: Constants.defaultNavigationBarHeight)
        ])
    }

    @objc private func didTapOptionsButton() {
        viewModel?.rightBarButtonAction?()
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = Constants.minimumZoomScale
        scrollView.maximumZoomScale = Constants.maximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let doubleTapRecognizer = UITapGestureRecognizer(target: self,
                                                         action: #selector(didRecognizeDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }

    private func setupLayout() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Stack view
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                               constant: Constants.containerHorizontalPadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                constant: -Constants.containerHorizontalPadding),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                              constant: -Constants.stackViewBottomPadding),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerHorizontalPadding)

        ])

        let stackViewTopConstraintConstant = Constants.stackViewTopConstraintToNavBar
        contentStackViewTopConstraint = contentStackView.topAnchor
            .constraint(equalTo: scrollView.contentLayoutGuide.topAnchor,
                        constant: stackViewTopConstraintConstant)
        contentStackViewTopConstraint?.isActive = true
    }

    private func setupFooterView() {
        view.addSubview(footerView)
        view.bringSubviewToFront(footerView)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Handle Loading indicator
    private func configureLoadingIndicator() {
        loadingIndicatorView.color = GiniColor(light: .GiniCapture.light1,
                                               dark: .GiniCapture.light1).uiColor()

        addLoadingContainer()
        addLoadingView(intoContainer: loadingIndicatorContainer)
    }

    private func addLoadingView(intoContainer container: UIView) {
        let loadingIndicator = configuration.customLoadingIndicator?.injectedView() ?? loadingIndicatorView
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

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
        let images = viewModel.imagesForDisplay()

        for image in images {
            // Create a container view for the image view
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false

            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)

            // Constrain image view within its container view
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            contentStackView.addArrangedSubview(containerView)

            // Calculate the image's aspect ratio
            let aspectRatio = image.size.width / image.size.height

            // Apply constraints based on device and aspect ratio
            if !UIDevice.current.isIpad {
                // For iPhones, calculate the dynamic width and height based on aspect ratio
                let screenWidth = UIScreen.main.bounds.width
                let contentWidth = screenWidth - contentStackView.layoutMargins.left
                - contentStackView.layoutMargins.right
                let imageViewHeight = contentWidth / aspectRatio

                // Set the width and height constraints with flexible priorities
                imageView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
                let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
                heightConstraint.priority = .defaultHigh // Set lower priority to allow flexibility
                heightConstraint.isActive = true
            } else {
                // For iPads, scale the image to fit the stack view width and maintain aspect ratio
                imageView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor,
                                                  multiplier: 1/aspectRatio).isActive = true
            }

            // Set content compression resistance and hugging priority to prevent clipping
            imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }

        adjustStackViewTopConstraint(for: images.count)

        adjustContentSize()
    }

    private func showSkontoDetailsInFooter() {
        guard let viewModel, !viewModel.imagesForDisplay().isEmpty else { return }

        footerView.updateFooter(with: viewModel.bottomInfoItems)
    }

    // MARK: - Utilities

    private func adjustContentSize() {
        var contentHeight: CGFloat = 0

        // Calculate the total height of the stackView content
        for view in contentStackView.arrangedSubviews {
            contentHeight += view.frame.size.height
        }

        // Update the scrollView contentSize
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width,
                                        height: max(contentHeight, scrollView.frame.size.height))

        adjustContentToCenter()
    }

    private func adjustContentToCenter() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset,
                                               left: horizontalInset,
                                               bottom: verticalInset,
                                               right: horizontalInset)
    }

    private func adjustStackViewTopConstraint() {
        let isZoomedOut = scrollView.zoomScale == Constants.minimumZoomScale
        contentStackViewTopConstraint?.constant = isZoomedOut
        ? Constants.navigationBarHeight + Constants.stackViewTopConstraintToNavBar
        : Constants.stackViewTopConstraintToNavBar
    }

    private func adjustStackViewTopConstraint(for imageCount: Int) {
        contentStackViewTopConstraint?.constant = imageCount == 1
        ? Constants.navigationBarHeight + Constants.stackViewTopConstraintToNavBar
        : Constants.stackViewTopConstraintToNavBar
    }

    // MARK: - Actions

    @objc private func didRecognizeDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let shouldZoomOut = scrollView.zoomScale != Constants.minimumZoomScale
        if shouldZoomOut {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let tapPoint = gestureRecognizer.location(in: contentStackView)
            let newZoomScale = scrollView.maximumZoomScale
            let zoomedRectSize = CGSize(width: scrollView.bounds.size.width / newZoomScale,
                                        height: scrollView.bounds.size.height / newZoomScale)
            let zoomedRectOrigin = CGPoint(x: tapPoint.x - zoomedRectSize.width / 2,
                                           y: tapPoint.y - zoomedRectSize.height / 2)
            let rectToZoom = CGRect(origin: zoomedRectOrigin, size: zoomedRectSize)
            scrollView.zoom(to: rectToZoom, animated: true)
        }
    }

    @objc private func didTapClose() {
        var screenName = GiniAnalyticsScreen.skontoInvoicePreview
        if errorView != nil {
            screenName = .skontoInvoicePreviewError
        }
        GiniAnalyticsManager.track(event: .closeTapped,
                                   screenName: screenName)
        dismiss(animated: true)
    }
}

extension DocumentPagesViewController: UIScrollViewDelegate {
    // Delegate method to specify the view to zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentStackView
    }

    // UIScrollViewDelegate method to handle zooming
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustContentToCenter()
        adjustStackViewTopConstraint()
        if !zoomAnalyticsEventSent {
            zoomAnalyticsEventSent = true
            GiniAnalyticsManager.track(event: .previewZoomed,
                                       screenName: .skontoInvoicePreview)
        }
    }
}

private extension DocumentPagesViewController {
    enum Constants {
        static let padding: CGFloat = 24
        static let spacing: CGFloat = 36
        static let stackViewItemSpacing: CGFloat = 4
        static let containerHorizontalPadding: CGFloat = UIDevice.current.isIpad ? 31 : 4
        static let loadingIndicatorContainerHeight: CGFloat = 60
        static let navigationBarHeight: CGFloat = 90
        static let stackViewTopConstraintToNavBar: CGFloat = UIDevice.current.isIpad ? 0 : 56
        static let stackViewBottomPadding: CGFloat = 50
        static let minimumZoomScale: CGFloat = 1.0
        static let maximumZoomScale: CGFloat = 2.0
        static let defaultNavigationBarHeight: CGFloat = 44
    }
}
