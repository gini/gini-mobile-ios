//
//  PaymentReviewViewController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary

public final class PaymentReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var inputContainer: UIView!
    @IBOutlet var containerCollectionView: UIView!
    @IBOutlet var paymentInfoStackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var infoBarLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!

    var model: PaymentReviewModel?
    private var showInfoBarOnce = true

    lazy var paymentInfoContainerView: PaymentReviewContainerView = {
        let view = PaymentReviewContainerView()
        view.frame = inputContainer.bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var selectedPaymentProvider: PaymentProvider!

    public weak var trackingDelegate: GiniMerchantTrackingDelegate?
    
    public static func instantiate(with giniMerchant: GiniMerchant, document: Document, extractions: [Extraction], selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniMerchantBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: document,
                                           extractions: extractions,
                                           selectedPaymentProvider: selectedPaymentProvider)
        viewController.model = viewModel
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        return viewController
    }
    
    public static func instantiate(with giniMerchant: GiniMerchant, data: DataForReview, selectedPaymentProvider: PaymentProvider, trackingDelegate: GiniMerchantTrackingDelegate? = nil) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniMerchantBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        let viewModel = PaymentReviewModel(with: giniMerchant,
                                           document: data.document,
                                           extractions: data.extractions,
                                           selectedPaymentProvider: selectedPaymentProvider)
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
                                                     color: UIColor.GiniMerchantColors.accent1,
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
                                           color: UIColor.GiniMerchantColors.accent1,
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
        inputContainer.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInputContainer)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniMerchantConfiguration.paymentReviewStatusBarStyle
    }
    
    // MARK: - congifureUI

    fileprivate func configureUI() {
        configureScreenBackgroundColor()
        configureCollectionView()
        configurePageControl()
        configureCloseButton()
        configurePaymentInfoContainerView()
    }
    
    // MARK: - Info bar

    fileprivate func configureInfoBar() {
        infoBar.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInfoBar)
        infoBar.backgroundColor = UIColor.GiniMerchantColors.success1
        infoBarLabel.textColor = UIColor.GiniMerchantColors.dark7
        infoBarLabel.font = giniMerchantConfiguration.textStyleFonts[.caption1]
        infoBarLabel.adjustsFontForContentSizeCategory = true
        infoBarLabel.text = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.infobar.message",
                                                             comment: "info bar message")
    }
    
    fileprivate func showInfoBar() {
        configureInfoBar()
        infoBar.isHidden = false
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [], animations: {
            self.infoBar.frame = CGRect(x: 0, y: self.inputContainer.frame.minY + Constants.moveHeightInfoBar - self.infoBar.frame.height, width: screenSize.width, height: self.infoBar.frame.height)
                       }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.animateSlideDownInfoBar()
        }
    }
    
    fileprivate func animateSlideDownInfoBar() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: [], animations: {
                           self.infoBar.frame = CGRect(x: 0, y: self.inputContainer.frame.minY, width: screenSize.width, height: self.infoBar.frame.height)
                       }, completion: { _ in
                           self.infoBar.isHidden = true
                       })
    }
    
    fileprivate func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func configurePageControl() {
        pageControl.layer.zPosition = Constants.zPositionPageControl
        pageControl.pageIndicatorTintColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark4,
                                                       darkModeColor: UIColor.GiniMerchantColors.light4).uiColor()
        pageControl.currentPageIndicatorTintColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark2,
                                                              darkModeColor: UIColor.GiniMerchantColors.light5).uiColor()
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = model?.document.pageCount ?? 1
        if pageControl.numberOfPages == 1 {
            pageControlHeightConstraint.constant = 0
        } else {
            pageControlHeightConstraint.constant = Constants.heightPageControl
        }
    }
    
    fileprivate func configureCloseButton() {
        closeButton.isHidden = !giniMerchantConfiguration.showPaymentReviewCloseButton
        closeButton.setImage(GiniMerchantImage.paymentReviewClose.preferredUIImage(), for: .normal)
    }
    
    fileprivate func configureScreenBackgroundColor() {
        let screenBackgroundColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.light7,
                                               darkModeColor: UIColor.GiniMerchantColors.light7).uiColor()
        mainView.backgroundColor = screenBackgroundColor
        collectionView.backgroundColor = screenBackgroundColor
        pageControl.backgroundColor = screenBackgroundColor
        inputContainer.backgroundColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark7,
                                                   darkModeColor: UIColor.GiniMerchantColors.light7).uiColor()
    }

    fileprivate func configurePaymentInfoContainerView() {
        inputContainer.addSubview(paymentInfoContainerView)

        paymentInfoContainerView.onPayButtonClicked = {
            self.payButtonClicked()
        }

        NSLayoutConstraint.activate([
            paymentInfoContainerView.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            paymentInfoContainerView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            paymentInfoContainerView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            paymentInfoContainerView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor)
        ])
    }

    
    // MARK: - Pay Button Action
    func payButtonClicked() {
        var event = TrackingEvent.init(type: PaymentReviewScreenEventType.onToTheBankButtonClicked)
        event.info = ["paymentProvider": selectedPaymentProvider.name]
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
        view.endEditing(true)
        
        if selectedPaymentProvider.gpcSupportedPlatforms.contains(.ios) {
            guard selectedPaymentProvider.appSchemeIOS.canOpenURLString() else {
                model?.openInstallAppBottomSheet()
                return
            }

            if paymentInfoContainerView.noErrorsFound() {
                createPaymentRequest()
            }
        } else if selectedPaymentProvider.openWithSupportedPlatforms.contains(.ios) {
            if model?.shouldShowOnboardingScreenFor(paymentProvider: selectedPaymentProvider) ?? false {
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
                                                    value: paymentInfoContainerView.textFieldText(texFieldType: .recipientFieldTag) ?? "",
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
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        if (keyboardWillShowCalled) {
            trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseKeyboardButtonClicked))
            view.endEditing(true)
        } else {
            trackingDelegate?.onPaymentReviewScreenEvent(event: TrackingEvent.init(type: .onCloseButtonClicked))
            dismiss(animated: true, completion: nil)
        }
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
        static let zPositionPageControl = 10.0
        static let heightPageControl = 20.0
        static let heightToolbar = 40.0
        static let bottomPaddingPageImageView = 20.0
        static let loadingIndicatorScale = 1.0
        static let loadingIndicatorStyle = UIActivityIndicatorView.Style.large
        static let pdfExtension = ".pdf"
    }
}
