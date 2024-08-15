//
//  PaymentReviewViewController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites
import GiniHealthAPILibrary

public final class PaymentReviewViewController: BottomSheetController, UIGestureRecognizerDelegate {
    private lazy var infoBar = buildInfoBar()
    private lazy var infoBarLabel = buildInfoBarLabel()
    private var isInfoBarHidden = true
    lazy var paymentInfoContainerView = buildPaymentInfoContainerView()

    private var infoBarBottomConstraint: NSLayoutConstraint?
    private var showInfoBarOnce = true
    private var keyboardWillShowCalled = false

    var model: PaymentReviewModel?
    var selectedPaymentProvider: PaymentProvider!

    public weak var trackingDelegate: GiniMerchantTrackingDelegate?

    public static func instantiate(with giniMerchant: GiniMerchant, document: Document?, extractions: [Extraction]?, paymentInfo: PaymentInfo?, selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil, paymentComponentsController: PaymentComponentsController, isInfoBarHidden: Bool = true) -> PaymentReviewViewController {
        let viewController = PaymentReviewViewController()
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: document,
                                           extractions: extractions,
                                           paymentInfo: paymentInfo,
                                           selectedPaymentProvider: selectedPaymentProvider,
                                           paymentComponentsController: paymentComponentsController)
        viewController.model = viewModel
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        viewController.isInfoBarHidden = isInfoBarHidden
        return viewController
    }

    public static func instantiate(with giniMerchant: GiniMerchant, data: DataForReview?, paymentInfo: PaymentInfo?, selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil, paymentComponentsController: PaymentComponentsController) -> PaymentReviewViewController {
        let viewController = PaymentReviewViewController()
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: data?.document,
                                           extractions: data?.extractions,
                                           paymentInfo: paymentInfo,
                                           selectedPaymentProvider: selectedPaymentProvider,
                                           paymentComponentsController: paymentComponentsController)
        viewController.model = viewModel
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        return viewController
    }

    let giniMerchantConfiguration = GiniMerchantConfiguration.shared

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
    }

    fileprivate func setupViewModel() {

        model?.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.model?.isLoading ?? false
                if isLoading {
                    self?.view.showLoading(style: Constants.loadingIndicatorStyle,
                                           color: GiniMerchantColorPalette.accent1.preferredColor(),
                                           scale: Constants.loadingIndicatorScale)
                } else {
                    self?.view.stopLoading()
                }
            }
        }

        model?.onErrorHandling = { [weak self] error in
            self?.showError(message: NSLocalizedStringPreferredFormat("gini.merchant.errors.default", comment: "default error message"))
        }

        model?.onCreatePaymentRequestErrorHandling = { [weak self] () in
            self?.showError(message: NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.payment.request.creation", comment: "error for creating payment request"))
        }

        model?.viewModelDelegate = self

        paymentInfoContainerView.model = PaymentReviewContainerViewModel(extractions: model?.extractions, paymentInfo: model?.paymentInfo, selectedPaymentProvider: selectedPaymentProvider)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromNotifications()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniMerchantConfiguration.paymentReviewStatusBarStyle
    }

    fileprivate func layoutUI() {
        layoutPaymentInfoContainerView()
        layoutInfoBar()
        setContent(content: paymentInfoContainerView)
    }

    // MARK: - Pay Button Action
    func payButtonClicked() {
        var event = TrackingEvent.init(type: PaymentReviewScreenEventType.onToTheBankButtonClicked)
        event.info = ["paymentProvider": selectedPaymentProvider.name]
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
        view.endEditing(true)

        if model?.paymentComponentsController.supportsGPC() == true {
            guard selectedPaymentProvider.appSchemeIOS.canOpenURLString() else {
                model?.openInstallAppBottomSheet()
                return
            }

            if paymentInfoContainerView.noErrorsFound() {
                createPaymentRequest()
            }
        } else if model?.paymentComponentsController.supportsOpenWith() == true {
            if model?.paymentComponentsController.shouldShowOnboardingScreenFor() == true {
                model?.openOnboardingShareInvoiceBottomSheet()
            } else {
                obtainPDFFromPaymentRequest()
            }
        }
    }

    func createPaymentRequest() {
        if !paymentInfoContainerView.isTextFieldEmpty(texFieldType: .amountFieldTag) {
            let paymentInfo = paymentInfoContainerView.obtainPaymentInfo()
            model?.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] requestId in
                self?.model?.openPaymentProviderApp(requestId: requestId, universalLink: paymentInfo.paymentUniversalLink)
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
        model?.sendFeedback(updatedExtractions: updatedExtractions)
    }
}

// MARK: - Keyboard handling
extension PaymentReviewViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            /**
             If keyboard size is not available for some reason, dont do anything
             */
            return
        }
        /**
         Moves the root view up by the distance of keyboard height  taking in account safeAreaInsets.bottom
         */
        view.bounds.origin.y = keyboardSize.height - view.safeAreaInsets.bottom

        keyboardWillShowCalled = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? Constants.animationDuration
        let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationCurve.easeOut.rawValue)

        keyboardWillShowCalled = false

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: { [weak self] in
            self?.view.bounds.origin.y = 0
        }, completion: nil)
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
        view.addGestureRecognizer(tap)
    }
}

//MARK: - PaymentReviewContainerView
fileprivate extension PaymentReviewViewController {
    func buildPaymentInfoContainerView() -> PaymentReviewContainerView {
        let containerView = PaymentReviewContainerView()
        containerView.backgroundColor = GiniColor.standard7.uiColor()
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadius)
        containerView.onPayButtonClicked = { [weak self] in
            self?.payButtonClicked()
        }
        return containerView
    }

    func layoutPaymentInfoContainerView() {
        paymentInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paymentInfoContainerView)

        NSLayoutConstraint.activate([
            paymentInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Info Bar
fileprivate extension PaymentReviewViewController {
    func buildInfoBar() -> UIView {
        let view = UIView()
        view.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadius)
        view.backgroundColor = GiniMerchantColorPalette.success1.preferredColor()
        view.isHidden = isInfoBarHidden
        return view
    }

    func buildInfoBarLabel() -> UILabel {
        let label = UILabel()
        label.textColor = GiniMerchantColorPalette.dark7.preferredColor()
        label.font = GiniMerchantConfiguration.shared.font(for: .captions1)
        label.adjustsFontForContentSizeCategory = true
        label.text = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.infobar.message", comment: "info bar message")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    func layoutInfoBar() {
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        infoBarLabel.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(infoBar, belowSubview: paymentInfoContainerView)
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
        let okAction = UIAlertAction(title: NSLocalizedStringPreferredFormat("gini.merchant.alert.ok.title",
                                                                             comment: "ok title for action"), style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PaymentReviewViewController {
    enum Constants {
        static let animationDuration: CGFloat = 0.3
        static let bottomPaddingPageImageView = 20.0
        static let loadingIndicatorScale = 1.0
        static let loadingIndicatorStyle = UIActivityIndicatorView.Style.large
        static let closeButtonSide = 48.0
        static let closeButtonPadding = 16.0
        static let infoBarHeight = 60.0
        static let infoBarLabelPadding = 8.0
        static let pageControlHeight = 20.0
        static let collectionViewPadding = 10.0
        static let inputContainerHeight = 300.0
        static let cornerRadius = 12.0
        static let moveHeightInfoBar = 32.0
    }
}
