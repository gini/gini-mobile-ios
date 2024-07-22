//
//  PaymentReviewViewController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary

public final class PaymentReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    let pageControl = UIPageControl()
    @IBOutlet weak var mainView: UIView!
    lazy var containerCollectionView = buildContainerCollectionView()
    lazy var collectionView = buildCollectionView()
    lazy var paymentInfoContainerView = PaymentReviewContainerView()
    private let closeButton = UIButton()
    private let infoBar = UIView()
    private let infoBarLabel = UILabel()

    var model: PaymentReviewModel?
    private var showInfoBarOnce = true

    var selectedPaymentProvider: PaymentProvider!

    public weak var trackingDelegate: GiniMerchantTrackingDelegate?

    public static func instantiate(with giniMerchant: GiniMerchant, document: Document, extractions: [Extraction], selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil, paymentComponentsController: PaymentComponentsController) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniMerchantBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: document,
                                           extractions: extractions,
                                           selectedPaymentProvider: selectedPaymentProvider,
                                           paymentComponentsController: paymentComponentsController)
        viewController.model = viewModel
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        return viewController
    }
    
    public static func instantiate(with giniMerchant: GiniMerchant, data: DataForReview, selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil, paymentComponentsController: PaymentComponentsController) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniMerchantBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: data.document,
                                           extractions: data.extractions,
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
        configureUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showInfoBarOnce {
            showInfoBar()
            showInfoBarOnce = false
        }
    }
    
    fileprivate func setupViewModel() {
            model?.updateImagesLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.model?.isImagesLoading ?? false
                if isLoading {
                    self?.collectionView.showLoading(style: .large,
                                                     color: GiniMerchantColorPalette.accent1.preferredColor(),
                                                     scale: Constants.loadingIndicatorScale)
                } else {
                    self?.collectionView.stopLoading()
                }
            }
        }
       
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
            
       model?.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        model?.onPreviewImagesFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        model?.onErrorHandling = {[weak self] error in
            DispatchQueue.main.async {
                self?.showError(message: NSLocalizedStringPreferredFormat("gini.merchant.errors.default",
                                                                         comment: "default error message") )
            }
        }
        
        model?.onCreatePaymentRequestErrorHandling = {[weak self] () in
            DispatchQueue.main.async {
                self?.showError(message: NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.payment.request.creation",
                                                                      comment: "error for creating payment request"))
            }
        }
        
        model?.fetchImages()
        
        model?.viewModelDelegate = self

        paymentInfoContainerView.model = PaymentReviewContainerViewModel(extractions: model?.extractions ?? [], selectedPaymentProvider: selectedPaymentProvider)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromNotifications()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        paymentInfoContainerView.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInputContainer)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniMerchantConfiguration.paymentReviewStatusBarStyle
    }
    
    // MARK: - congifureUI

    fileprivate func configureUI() {
        configureScreenBackgroundColor()
        configurePageControl()
        configureCloseButton()
        configurePaymentInfoContainerView()

        layoutContainerCollectionView()
        layoutInfoBar()
        layoutCloseButton()
    }

    fileprivate func configureScreenBackgroundColor() {
        let screenBackgroundColor = GiniColor(lightModeColorName: .light7, darkModeColorName: .light7).uiColor()
        mainView.backgroundColor = screenBackgroundColor
        collectionView.backgroundColor = screenBackgroundColor
        pageControl.backgroundColor = screenBackgroundColor
        paymentInfoContainerView.backgroundColor = GiniColor.standard7.uiColor()
    }

    fileprivate func configurePaymentInfoContainerView() {
        paymentInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(paymentInfoContainerView)

        paymentInfoContainerView.onPayButtonClicked = {
            self.payButtonClicked()
        }

        NSLayoutConstraint.activate([
            paymentInfoContainerView.heightAnchor.constraint(equalToConstant: Constants.inputContainerHeight),
            paymentInfoContainerView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            paymentInfoContainerView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            paymentInfoContainerView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)
        ])
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
    
    // MARK: - Keyboard handling
    
    private var keyboardWillShowCalled = false
    
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
        mainView.bounds.origin.y = keyboardSize.height - view.safeAreaInsets.bottom
        
        keyboardWillShowCalled = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? Constants.animationDuration
        let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationCurve.easeOut.rawValue)
        
        self.keyboardWillShowCalled = false
        
        /**
        Moves back the root view origin to zero. Schedules it on the main dispatch queue to prevent
        the view jumping if another keyboard is shown right after this one is hidden.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            if !self.keyboardWillShowCalled {
                UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
                    self.mainView.bounds.origin.y = 0
                }, completion: nil)
            }
        }
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
        mainView.addGestureRecognizer(tap)
    }
}
//MARK -
fileprivate extension PaymentReviewViewController {
}

//MARK: -
fileprivate extension PaymentReviewViewController {
    func buildContainerCollectionView() -> UIStackView {
        let container = UIStackView(arrangedSubviews: [collectionView, pageControl])
        container.spacing = 0
        container.axis = .vertical
        container.distribution = .fill
        return container
    }

    func layoutContainerCollectionView() {
        containerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(containerCollectionView)
        NSLayoutConstraint.activate([
            containerCollectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            containerCollectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            containerCollectionView.topAnchor.constraint(equalTo: mainView.topAnchor),
            containerCollectionView.bottomAnchor.constraint(equalTo: paymentInfoContainerView.topAnchor),

            pageControl.heightAnchor.constraint(equalToConstant: Constants.pageControlHeight),
            collectionView.widthAnchor.constraint(equalTo: containerCollectionView.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: containerCollectionView.heightAnchor),
        ])
    }
}

//MARK: - Collection View
fileprivate extension PaymentReviewViewController {
    func buildCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Constants.collectionViewPadding
        flowLayout.minimumLineSpacing = Constants.collectionViewPadding

        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(cellType: PageCollectionViewCell.self)
        return collection
    }
}

//MARK: - Close Button
fileprivate extension PaymentReviewViewController {
    func configureCloseButton() {
        closeButton.isHidden = !giniMerchantConfiguration.showPaymentReviewCloseButton
        closeButton.setImage(GiniMerchantImage.paymentReviewClose.preferredUIImage(), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
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
}

//MARK: - Page Control
fileprivate extension PaymentReviewViewController {
    func configurePageControl() {
        pageControl.pageIndicatorTintColor = GiniColor.standard4.uiColor()
        pageControl.currentPageIndicatorTintColor = GiniColor(lightModeColorName: .dark2, darkModeColorName: .light5).uiColor()
        pageControl.hidesForSinglePage = true
        pageControl.backgroundColor = .orange
        pageControl.numberOfPages = model?.document.pageCount ?? 1
    }

    @objc func closeButtonClicked(_ sender: UIButton) {
        if (keyboardWillShowCalled) {
            trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseKeyboardButtonClicked))
            view.endEditing(true)
        } else {
            trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseButtonClicked))
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Info Bar
fileprivate extension PaymentReviewViewController {
    func layoutInfoBar() {
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        infoBarLabel.translatesAutoresizingMaskIntoConstraints = false

        mainView.insertSubview(infoBar, belowSubview: paymentInfoContainerView)
        infoBar.addSubview(infoBarLabel)

        NSLayoutConstraint.activate([
            infoBar.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            infoBar.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            infoBar.bottomAnchor.constraint(equalTo: paymentInfoContainerView.topAnchor, constant: Constants.infoBarHeight),
            infoBar.heightAnchor.constraint(equalToConstant: Constants.infoBarHeight),

            infoBarLabel.centerXAnchor.constraint(equalTo: infoBar.centerXAnchor),
            infoBarLabel.topAnchor.constraint(equalTo: infoBar.topAnchor, constant: Constants.infoBarLabelPadding)
        ])
    }

    func configureInfoBar() {
        infoBar.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInfoBar)
        infoBar.backgroundColor = GiniMerchantColorPalette.success1.preferredColor()
        infoBarLabel.textColor = GiniMerchantColorPalette.dark7.preferredColor()
        infoBarLabel.font = giniMerchantConfiguration.textStyleFonts[.caption1]
        infoBarLabel.adjustsFontForContentSizeCategory = true
        infoBarLabel.text = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.infobar.message",
                                                             comment: "info bar message")
    }

    func showInfoBar() {
        configureInfoBar()
        infoBar.isHidden = false
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [], animations: {
            self.infoBar.frame = CGRect(x: 0, y: self.paymentInfoContainerView.frame.minY + Constants.moveHeightInfoBar - self.infoBar.frame.height, width: screenSize.width, height: self.infoBar.frame.height)
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.animateSlideDownInfoBar()
        }
    }

    func animateSlideDownInfoBar() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [], animations: {
            self.infoBar.frame = CGRect(x: 0, y: self.paymentInfoContainerView.frame.minY, width: screenSize.width, height: self.infoBar.frame.height)
        }, completion: { _ in
            self.infoBar.isHidden = true
        })
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
        present(alertController, animated: true, completion: nil)
    }
}

extension PaymentReviewViewController {
    enum Constants {
        static let buttonViewHeight: CGFloat = 56
        static let animationDuration: CGFloat = 0.3
        static let cornerRadiusInputContainer = 12.0
        static let cornerRadiusInfoBar = 12.0
        static let moveHeightInfoBar = 32.0
        static let bottomPaddingPageImageView = 20.0
        static let loadingIndicatorScale = 1.0
        static let loadingIndicatorStyle = UIActivityIndicatorView.Style.large

        static let closeButtonSide = 48.0
        static let closeButtonPadding = 16.0
        static let infoBarHeight = 60.0
        static let infoBarLabelPadding = 8.0
        static let pageControlHeight = 20.0
        static let collectionViewPadding = 10.0
        static let inputContainerHeight = 375.0
    }
}
