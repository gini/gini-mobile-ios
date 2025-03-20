//
//  PaymentReviewViewController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites
import GiniHealthAPILibrary

/// Modes for displaying PaymentReview content in the UI.
public enum DisplayMode: Int {
    case bottomSheet
    case documentCollection
}

/// A view controller for reviewing payment details
public final class PaymentReviewViewController: BottomSheetViewController, UIGestureRecognizerDelegate {
    private lazy var mainView = buildMainView()
    private lazy var closeButton = buildCloseButton()
    private lazy var infoBar = buildInfoBar()
    private lazy var infoBarLabel = buildInfoBarLabel()
    private var isInfoBarHidden = true
    lazy var paymentInfoContainerView = buildPaymentInfoContainerView()
    lazy var collectionView = buildCollectionView()
    lazy var pageControl = buildPageControl()
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    private var infoBarBottomConstraint: NSLayoutConstraint?

    private var showInfoBarOnce = true
    private var keyboardWillShowCalled = false

    /// The model instance containing data and methods for handling the payment review process.
    public let model: PaymentReviewModel
    private var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider

    init(viewModel: PaymentReviewModel,
         selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        self.model = viewModel
        self.selectedPaymentProvider = selectedPaymentProvider
        self.isInfoBarHidden = viewModel.configuration.isInfoBarHidden
        super.init(configuration: self.model.bottomSheetConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnNotifications()
        dismissKeyboardOnTap()
        setupViewModel()
        layoutUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showInfoBarOnce && !isInfoBarHidden {
            showInfoBar()
            showInfoBarOnce = false
        }
        if model.previousPaymentComponentScreenType == .bankPicker {
            model.openBankSelectionBottomSheet()
            model.previousPaymentComponentScreenType = nil
        }
    }

    fileprivate func setupViewModel() {
        model.onErrorHandling = { [weak self] error in
            guard let self = self else { return }
            self.showError(message: self.model.strings.defaultErrorMessage)
        }

        model.onCreatePaymentRequestErrorHandling = { [weak self] () in
            guard let self = self else { return }
            self.showError(message: self.model.strings.createPaymentErrorMessage)
        }

        if model.displayMode == .documentCollection {
            setupViewModelWithDocument()
        }

        model.onNewPaymentProvider = { [weak self] () in
            self?.updatePaymentInfoContainerView()
        }

        model.viewModelDelegate = self
    }

    private func setupViewModelWithDocument() {
        model.fetchImages()

        model.updateImagesLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let isLoading = self.model.isImagesLoading
                if isLoading {
                    self.collectionView.showLoading(style: self.model.configuration.loadingIndicatorStyle,
                                                    color: self.model.configuration.loadingIndicatorColor,
                                                    scale: Constants.loadingIndicatorScale)
                } else {
                    self.collectionView.stopLoading()
                }
            }
        }

        model.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let isLoading = self.model.isLoading
                if isLoading {
                    self.view.showLoading(style: self.model.configuration.loadingIndicatorStyle,
                                          color: self.model.configuration.loadingIndicatorColor,
                                          scale: Constants.loadingIndicatorScale)
                } else {
                    self.view.stopLoading()
                }
            }
        }

        model.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }

        model.onPreviewImagesFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromNotifications()
        model.viewDidDisappear()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return model.configuration.statusBarStyle
    }

    fileprivate func layoutUI() {
        switch model.displayMode {
        case .documentCollection:
            layoutMainView()
            layoutPaymentInfoContainerView()
            layoutContainerCollectionView()
            layoutInfoBar()
            layoutCloseButton()
        case .bottomSheet:
            layoutPaymentInfoContainerView()
            layoutInfoBar()
            setContent(content: paymentInfoContainerView)
        }
        setupInitialLayout()
    }

    // MARK: - Pay Button Action
    func payButtonClicked() {
        model.delegate?.trackOnPaymentReviewBankButtonClicked(providerName: selectedPaymentProvider.name)
        view.endEditing(true)

        guard paymentInfoContainerView.noErrorsFound() else { return }
        guard paymentInfoContainerView.inputFieldsHaveNoErrors() else { return }
        guard let delegate = model.delegate else { return }
        if delegate.supportsGPC() {
            guard selectedPaymentProvider.appSchemeIOS.canOpenURLString() else {
                model.openInstallAppBottomSheet()
                return
            }
            createPaymentRequest()
        } else if delegate.supportsOpenWith() {
            if !paymentInfoContainerView.isTextFieldEmpty(textFieldType: .amountFieldTag) {
                let paymentInfo = paymentInfoContainerView.obtainPaymentInfo()
                model.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] requestId in
                    self?.model.openOnboardingShareInvoiceBottomSheet(paymentRequestId: requestId, paymentInfo: paymentInfo)
                })
                sendFeedback(paymentInfo: paymentInfo)
            }
        }
    }

    func createPaymentRequest() {
        if !paymentInfoContainerView.isTextFieldEmpty(textFieldType: .amountFieldTag) {
            let paymentInfo = paymentInfoContainerView.obtainPaymentInfo()
            model.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] requestId in
                self?.model.openPaymentProviderApp(requestId: requestId, universalLink: paymentInfo.paymentUniversalLink)
            })
            sendFeedback(paymentInfo: paymentInfo)
        }
    }

    private func sendFeedback(paymentInfo: PaymentInfo) {
        let paymentRecipientExtraction = Extraction(box: nil,
                                                    candidates: "",
                                                    entity: "text",
                                                    value: paymentInfo.recipient,
                                                    name: "payment_recipient")
        let ibanExtraction = Extraction(box: nil,
                                        candidates: "",
                                        entity: "iban",
                                        value: paymentInfo.iban,
                                        name: "iban")
        let referenceExtraction = Extraction(box: nil,
                                             candidates: "",
                                             entity: "text",
                                             value: paymentInfo.purpose,
                                             name: "payment_purpose")
        let amoutToPayExtraction = Extraction(box: nil,
                                              candidates: "",
                                              entity: "amount",
                                              value: paymentInfo.amount,
                                              name: "amount_to_pay")
        let updatedExtractions = [paymentRecipientExtraction, ibanExtraction, referenceExtraction, amoutToPayExtraction]
        model.sendFeedback(updatedExtractions: updatedExtractions)
    }
}

// MARK: - Instantiation
extension PaymentReviewViewController {
    public static func instantiate(viewModel: PaymentReviewModel,
                                   selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider) -> PaymentReviewViewController {
        let viewController = PaymentReviewViewController(viewModel: viewModel,
                                                         selectedPaymentProvider: selectedPaymentProvider)
        return viewController
    }
}

// MARK: - Keyboard handling
extension PaymentReviewViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = getKeyboardSize(from: notification) else { return }

        if UIDevice.isPortrait() {
            adjustViewForPortrait(with: keyboardSize.height)
        } else {
            handleLandscapeKeyboard(with: keyboardSize.height)
        }

        keyboardWillShowCalled = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if UIDevice.isPortrait() {
            resetViewOriginForPortrait(using: notification)
        } else {
            resetViewTransformForLandscape()
        }

        keyboardWillShowCalled = false
    }

    // MARK: - Keyboard Helpers

    private func getKeyboardSize(from notification: NSNotification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    private func adjustViewForPortrait(with keyboardHeight: CGFloat) {
        (model.displayMode == .bottomSheet ? view : mainView)
            .bounds.origin.y = keyboardHeight - view.safeAreaInsets.bottom
    }

    private func handleLandscapeKeyboard(with keyboardHeight: CGFloat) {
        guard let editedTextField = paymentInfoContainerView.textFieldEdited() else { return }

        if isAmountField(editedTextField) {
            resetViewTransform()
        }

        adjustViewIfNeeded(for: editedTextField, keyboardHeight: keyboardHeight)
    }

    private func isAmountField(_ textField: UITextField) -> Bool {
        guard let type = TextFieldType(rawValue: textField.tag) else { return false }
        return type == .amountFieldTag
    }

    private func resetViewTransform() {
        UIView.animate(withDuration: 0.1) {
            self.view.transform = .identity
        }
    }

    private func adjustViewIfNeeded(for textField: UITextField, keyboardHeight: CGFloat) {
        guard let textFieldFrame = textField.superview?.convert(textField.frame, to: nil) else { return }

        let overlap = calculateOverlap(for: textFieldFrame, keyboardHeight: keyboardHeight)
        if overlap > 0 {
            animateViewUp(by: overlap + Constants.keyboardOverlapPadding)
        }
    }

    private func calculateOverlap(for textFieldFrame: CGRect, keyboardHeight: CGFloat) -> CGFloat {
        let textFieldBottom = textFieldFrame.maxY
        let screenHeight = UIScreen.main.bounds.height
        return textFieldBottom - (screenHeight - keyboardHeight)
    }

    private func animateViewUp(by distance: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -distance)
        }
    }

    private func resetViewOriginForPortrait(using notification: NSNotification) {
        let animationDuration = getAnimationDuration(from: notification)
        let animationCurve = getAnimationCurve(from: notification)

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: UIView.AnimationOptions(rawValue: animationCurve),
            animations: { [weak self] in
                guard let self = self else { return }
                (self.model.displayMode == .bottomSheet ? self.view : self.mainView)?.bounds.origin.y = 0
            },
            completion: nil
        )
    }

    private func resetViewTransformForLandscape() {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    private func getAnimationDuration(from notification: NSNotification) -> Double {
        return notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? Constants.animationDuration
    }

    private func getAnimationCurve(from notification: NSNotification) -> UInt {
        return notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationCurve.easeOut.rawValue)
    }

    func subscribeOnNotifications() {
        subscribeOnKeyboardNotifications()
    }

    func subscribeOnKeyboardNotifications() {
        /**
         Calls the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        /**
         Calls the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
         */
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentReviewViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate func unsubscribeFromNotifications() {
        unsubscribeFromKeyboardNotifications()
    }

    fileprivate func dismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        (model.displayMode == .bottomSheet ? view : mainView).addGestureRecognizer(tap)
    }
}

//MARK: - MainView
fileprivate extension PaymentReviewViewController {
    func buildMainView() -> UIView {
        let view = UIView()
        view.backgroundColor = model.configuration.mainViewBackgroundColor
        return view
    }

    func layoutMainView() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainView)
        mainView.backgroundColor = model.configuration.backgroundColor
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - PaymentReviewContainerView
fileprivate extension PaymentReviewViewController {
    func buildPaymentInfoContainerView() -> PaymentReviewContainerView {
        let containerView = PaymentReviewContainerView(viewModel: model.paymentReviewContainerViewModel())
        containerView.backgroundColor = model.configuration.infoContainerViewBackgroundColor
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadius)
        containerView.onPayButtonClicked = { [weak self] in
            self?.payButtonClicked()
        }
        containerView.onBankSelectionButtonClicked = { [weak self] in
            self?.model.openBankSelectionBottomSheet()
        }
        return containerView
    }

    func layoutPaymentInfoContainerView() {
        paymentInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let container = model.displayMode == .bottomSheet ? (view ?? UIView()) : mainView
        container.addSubview(paymentInfoContainerView)
        container.backgroundColor = .clear

        NSLayoutConstraint.activate([
            paymentInfoContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            paymentInfoContainerView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        if model.displayMode == .documentCollection {
            NSLayoutConstraint.activate([
                paymentInfoContainerView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
            ])
        }
    }

    func updatePaymentInfoContainerView() {
        self.presentedViewController?.dismiss(animated: true)
        self.selectedPaymentProvider = model.selectedPaymentProvider
        paymentInfoContainerView.updateSelectedPaymentProvider(model.selectedPaymentProvider)
    }
}

//MARK: - Collection View Container
fileprivate extension PaymentReviewViewController {
    func buildCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Constants.collectionViewPadding
        flowLayout.minimumLineSpacing = Constants.collectionViewPadding
        flowLayout.scrollDirection = .horizontal // Enable horizontal scrolling

        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = model.configuration.backgroundColor
        collection.delegate = self
        collection.dataSource = self
        collection.register(cellType: PageCollectionViewCell.self)
        return collection
    }

    func buildPageControl() -> UIPageControl {
        let control = UIPageControl()
        control.pageIndicatorTintColor = model.configuration.pageIndicatorTintColor
        control.currentPageIndicatorTintColor = model.configuration.currentPageIndicatorTintColor
        control.backgroundColor = .clear
        control.hidesForSinglePage = true
        control.numberOfPages = model.document?.pageCount ?? 0
        return control
    }

    func layoutContainerCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(pageControl)
        mainView.sendSubviewToBack(pageControl)

        mainView.addSubview(collectionView)
        mainView.sendSubviewToBack(collectionView)

        let navigationBarHeight = self.navigationController?.navigationBar.frame.maxY ?? 0

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: navigationBarHeight),

            pageControl.heightAnchor.constraint(equalToConstant: Constants.pageControlHeight),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -Constants.collectionViewPadding),
            pageControl.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.heightAnchor),
            paymentInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - Close Button used in Gini Health SDK
fileprivate extension PaymentReviewViewController {
    func buildCloseButton() -> UIButton {
        let button = UIButton()
        button.isHidden = !model.showPaymentReviewCloseButton
        button.setImage(model.configuration.paymentReviewClose , for: .normal)
        button.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        return button
    }

    func layoutCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSide),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSide),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.closeButtonPadding),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.closeButtonPadding)
        ])

    }

    @objc func closeButtonClicked(_ sender: UIButton) {
        if (keyboardWillShowCalled) {
            model.delegate?.trackOnPaymentReviewCloseKeyboardClicked()
            view.endEditing(true)
        } else {
            model.delegate?.trackOnPaymentReviewCloseButtonClicked()
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Info Bar
fileprivate extension PaymentReviewViewController {
    func buildInfoBar() -> UIView {
        let view = UIView()
        view.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadius)
        view.backgroundColor = model.configuration.infoBarBackgroundColor
        view.isHidden = isInfoBarHidden
        return view
    }

    func buildInfoBarLabel() -> UILabel {
        let label = UILabel()
        label.textColor = model.configuration.infoBarLabelTextColor
        label.font = model.configuration.infoBarLabelFont
        label.adjustsFontForContentSizeCategory = true
        label.text = model.strings.infoBarMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    func layoutInfoBar() {
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        infoBarLabel.translatesAutoresizingMaskIntoConstraints = false

        let container = model.displayMode == .bottomSheet ? (view ?? UIView()) : mainView
        container.insertSubview(infoBar, belowSubview: paymentInfoContainerView)
        infoBar.addSubview(infoBarLabel)

        let bottomConstraint = infoBar.bottomAnchor.constraint(equalTo: paymentInfoContainerView.topAnchor, constant: Constants.infoBarHeight)
        infoBarBottomConstraint = bottomConstraint
        NSLayoutConstraint.activate([
            bottomConstraint,
            infoBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoBar.heightAnchor.constraint(equalToConstant: Constants.infoBarHeight),

            infoBarLabel.centerXAnchor.constraint(equalTo: infoBar.centerXAnchor),
            infoBarLabel.topAnchor.constraint(equalTo: infoBar.topAnchor, constant: Constants.infoBarLabelPadding)
        ])
    }

    func showInfoBar() {
        guard !isInfoBarHidden else { return }
        infoBar.isHidden = false
        animateInfoBar(verticalConstant: Constants.moveHeightInfoBar)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.animateSlideDownInfoBar()
        }
    }

    func animateSlideDownInfoBar() {
        guard !isInfoBarHidden else { return }
        animateInfoBar(verticalConstant: Constants.infoBarHeight) { [weak self] _ in
            self?.infoBar.isHidden = true
        }
    }

    func animateInfoBar(verticalConstant: CGFloat, completion: ((Bool) -> Void)? = nil) {
        guard !isInfoBarHidden else { return }
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       animations: {
            self.infoBarBottomConstraint?.constant = verticalConstant
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}

extension PaymentReviewViewController {
    func showError(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: model.strings.alertOkButtonTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PaymentReviewViewController {
    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation()
    }

    private func updateLayoutForCurrentOrientation() {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
        collectionView.reloadData()
    }
    
    private func setupPortraitConstraints() {
        setupConstraints(for: .vertical)
    }
    
    private func setupLandscapeConstraints() {
        setupConstraints(for: .horizontal)
    }
    
    private func setupConstraints(for orientation: NSLayoutConstraint.Axis) {
        // Deactivate previous constraints
        NSLayoutConstraint.deactivate(orientation == .vertical ? landscapeConstraints : portraitConstraints)
        
        paymentInfoContainerView.setupView()
        
        let isPortrait = orientation == .vertical
        let showCollectionView = model.displayMode == .documentCollection
        
        var constraints = [] as [NSLayoutConstraint]
        
        if showCollectionView {
            constraints.append(collectionView.bottomAnchor.constraint(equalTo: isPortrait ? paymentInfoContainerView.topAnchor : mainView.bottomAnchor, constant: Constants.collectionViewBottomPadding))
        }
        
        if isPortrait {
            portraitConstraints = constraints
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            landscapeConstraints = constraints
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    // Handle orientation change
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayoutForCurrentOrientation()

        // Perform layout updates with animation
        coordinator.animate(alongsideTransition: { context in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension PaymentReviewViewController {
    enum Constants {
        static let animationDuration = 0.3
        static let bottomPaddingPageImageView = 20.0
        static let loadingIndicatorScale = 1.0
        static let closeButtonSide = 48.0
        static let closeButtonPadding = 16.0
        static let infoBarHeight = 55.0
        static let infoBarLabelPadding = 8.0
        static let pageControlHeight = 20.0
        static let collectionViewPadding = 10.0
        static let inputContainerHeightPortait = 375.0
        static let inputContainerHeightLandscape = 307.0
        static let cornerRadius = 12.0
        static let moveHeightInfoBar = 24.0
        static let collectionViewBottomPadding = 10.0
        static let keyboardOverlapPadding = 20.0
    }
}
