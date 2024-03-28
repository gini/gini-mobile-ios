//
//  PaymentReviewViewController.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary

public final class PaymentReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recipientTextFieldView: TextFieldWithLabelView!
    @IBOutlet weak var ibanTextFieldView: TextFieldWithLabelView!
    @IBOutlet weak var amountTextFieldView: TextFieldWithLabelView!
    @IBOutlet weak var usageTextFieldView: TextFieldWithLabelView!
    @IBOutlet weak var payButtonStackView: UIStackView!
    @IBOutlet var paymentInputFieldsErrorLabels: [UILabel]!
    @IBOutlet var usageErrorLabel: UILabel!
    @IBOutlet var amountErrorLabel: UILabel!
    @IBOutlet var ibanErrorLabel: UILabel!
    @IBOutlet var recipientErrorLabel: UILabel!
    @IBOutlet var paymentInputFields: [TextFieldWithLabelView]!
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
    private var amountToPay = Price(value: 0, currencyCode: "€")
    private var lastValidatedIBAN = ""
    private var showInfoBarOnce = true
    
    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        return button
    }()
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        return view
    }()

    private var selectedPaymentProvider: PaymentProvider?
    
    public weak var trackingDelegate: GiniHealthTrackingDelegate?
    
    enum TextFieldType: Int {
        case recipientFieldTag = 1
        case ibanFieldTag
        case amountFieldTag
        case usageFieldTag
    }
    
    public static func instantiate(with giniHealth: GiniHealth, document: Document, extractions: [Extraction], selectedPaymentProvider: PaymentProvider?, trackingDelegate: GiniHealthTrackingDelegate? = nil) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniHealthBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        viewController.model = PaymentReviewModel(with: giniHealth, document: document, extractions: extractions)
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        return viewController
    }
    
    public static func instantiate(with giniHealth: GiniHealth, data: DataForReview, selectedPaymentProvider: PaymentProvider?, trackingDelegate: GiniHealthTrackingDelegate? = nil) -> PaymentReviewViewController {
        let viewController = (UIStoryboard(name: "PaymentReview", bundle: giniHealthBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        viewController.model = PaymentReviewModel(with: giniHealth, document: data.document, extractions: data.extractions)
        viewController.trackingDelegate = trackingDelegate
        viewController.selectedPaymentProvider = selectedPaymentProvider
        return viewController
    }

    var giniHealthConfiguration = GiniHealthConfiguration.shared
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnNotifications()
        dismissKeyboardOnTap()
        configureUI()
        setupViewModel()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showInfoBarOnce {
            showInfoBar()
            showInfoBarOnce = false
        }
    }
    
    fileprivate func setupViewModel() {
        model?.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.fillInInputFields()
            }
        }
        
        model?.updateImagesLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.model?.isImagesLoading ?? false
                if isLoading {
                    self?.collectionView.showLoading(style: .whiteLarge,
                                                     color: UIColor.GiniHealthColors.accent1,
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
                    if #available(iOS 13.0, *) {
                        self?.view.showLoading(style: Constants.loadingIndicatorStyle,
                                               color: UIColor.GiniHealthColors.accent1,
                                               scale: Constants.loadingIndicatorScale)
                    } else {
                        self?.view.showLoading(style: .whiteLarge,
                                               color: UIColor.GiniHealthColors.accent1,
                                               scale: Constants.loadingIndicatorScale)
                    }
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
                self?.showError(message: NSLocalizedStringPreferredFormat("ginihealth.errors.default",
                                                                         comment: "default error message") )
            }
        }
        
        model?.onCreatePaymentRequestErrorHandling = {[weak self] () in
            DispatchQueue.main.async {
                self?.showError(message: NSLocalizedStringPreferredFormat("ginihealth.errors.failed.payment.request.creation",
                                                                      comment: "error for creating payment request"))
            }
        }
        
        model?.fetchImages()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromNotifications()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        inputContainer.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInputContainer)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniHealthConfiguration.paymentReviewStatusBarStyle
    }
    
    // MARK: - congifureUI

    fileprivate func configureUI() {
        configureScreenBackgroundColor()
        configureCollectionView()
        configurePaymentInputFields()
        configurePageControl()
        configureCloseButton()
        configurePayButtonInitialState()
        configurePoweredByGiniView()
        hideErrorLabels()
        fillInInputFields()
        addDoneButtonForNumPad(amountTextFieldView)
    }
    
    // MARK: - Info bar

    fileprivate func configureInfoBar() {
        infoBar.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusInfoBar)
        infoBar.backgroundColor = UIColor.GiniHealthColors.success1
        infoBarLabel.textColor = UIColor.GiniHealthColors.dark7
        infoBarLabel.font = giniHealthConfiguration.textStyleFonts[.caption1]
        infoBarLabel.adjustsFontForContentSizeCategory = true
        infoBarLabel.text = NSLocalizedStringPreferredFormat("ginihealth.reviewscreen.infobar.message",
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
    
    fileprivate func configurePayButtonInitialState() {
        payButtonStackView.addArrangedSubview(payInvoiceButton)
        guard let model else { return }
        payInvoiceButton.configure(with: giniHealthConfiguration.primaryButtonConfiguration)
        payInvoiceButton.customConfigure(paymentProviderColors: selectedPaymentProvider?.colors,
                                         isPaymentProviderInstalled: true,
                                         text: model.payInvoiceLabelText,
                                         leftImageData: selectedPaymentProvider?.iconData)
        disablePayButtonIfNeeded()
        payInvoiceButton.didTapButton = { [weak self] in
            self?.payButtonClicked()
        }
    }
    
    fileprivate func configurePaymentInputFields() {
        for field in paymentInputFields {
            applyDefaultStyle(field)
        }
    }
    
    fileprivate func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func configurePageControl() {
        pageControl.layer.zPosition = Constants.zPositionPageControl
        pageControl.pageIndicatorTintColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                       darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
        pageControl.currentPageIndicatorTintColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                              darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = model?.document.pageCount ?? 1
        if pageControl.numberOfPages == 1 {
            pageControlHeightConstraint.constant = 0
        } else {
            pageControlHeightConstraint.constant = Constants.heightPageControl
        }
    }
    
    fileprivate func configureCloseButton() {
        closeButton.isHidden = !giniHealthConfiguration.showPaymentReviewCloseButton
        closeButton.setImage(UIImageNamedPreferred(named: "paymentReviewCloseButton"), for: .normal)
    }
    
    fileprivate func configureScreenBackgroundColor() {
        let screenBackgroundColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.light7,
                                               darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
        mainView.backgroundColor = screenBackgroundColor
        collectionView.backgroundColor = screenBackgroundColor
        pageControl.backgroundColor = screenBackgroundColor
        inputContainer.backgroundColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                                   darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    }
    
    fileprivate func configurePoweredByGiniView() {
        bottomView.addSubview(poweredByGiniView)
        setupPoweredByGiniConstraints()
    }
    
    private func setupPoweredByGiniConstraints() {
        let poweredByGiniBottomAnchorConstraint = poweredByGiniView.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor)
        poweredByGiniBottomAnchorConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            poweredByGiniView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            poweredByGiniBottomAnchorConstraint
        ])
    }
    
    // MARK: - Input fields configuration

    fileprivate func applyDefaultStyle(_ textFieldView: TextFieldWithLabelView) {
        textFieldView.configure(configuration: giniHealthConfiguration.defaultStyleInputFieldConfiguration)
        textFieldView.customConfigure(labelTitle: inputFieldPlaceholderText(textFieldView))
        textFieldView.textField.delegate = self
        textFieldView.textField.tag = textFieldView.tag
        textFieldView.layer.masksToBounds = true
    }

    fileprivate func applyErrorStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            textFieldView.configure(configuration: self.giniHealthConfiguration.errorStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    fileprivate func applySelectionStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            textFieldView.configure(configuration: self.giniHealthConfiguration.selectionStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    @objc fileprivate func doneWithAmountInputButtonTapped() {
        amountTextFieldView.textField.endEditing(true)
        amountTextFieldView.textField.resignFirstResponder()
        
        if amountTextFieldView.textField.hasText && !amountTextFieldView.textField.isReallyEmpty {
            updateAmoutToPayWithCurrencyFormat()
        }
    }

     func addDoneButtonForNumPad(_ textFieldView: TextFieldWithLabelView) {
         let toolbarDone = UIToolbar(frame:CGRect(x: 0, y: 0, width: view.frame.width, height: Constants.heightToolbar))
         toolbarDone.sizeToFit()
         let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
         let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                               target: self, 
                                               action: #selector(PaymentReviewViewController.doneWithAmountInputButtonTapped))
        
         toolbarDone.items = [flexBarButton, barBtnDone]
         textFieldView.textField.inputAccessoryView = toolbarDone
    }
    
    fileprivate func inputFieldPlaceholderText(_ textFieldView: TextFieldWithLabelView) -> String {
        if let fieldIdentifier = TextFieldType(rawValue: textFieldView.tag) {
            switch fieldIdentifier {
            case .recipientFieldTag:
                return NSLocalizedStringPreferredFormat("ginihealth.reviewscreen.recipient.placeholder",
                                                        comment: "placeholder text for recipient input field")
            case .ibanFieldTag:
                return NSLocalizedStringPreferredFormat("ginihealth.reviewscreen.iban.placeholder",
                                                        comment: "placeholder text for iban input field")
            case .amountFieldTag:
                return NSLocalizedStringPreferredFormat("ginihealth.reviewscreen.amount.placeholder",
                                                        comment: "placeholder text for amount input field")
            case .usageFieldTag:
                return NSLocalizedStringPreferredFormat("ginihealth.reviewscreen.usage.placeholder",
                                                        comment: "placeholder text for usage input field")
            }
        }
        return ""
    }
    
    // MARK: - Input fields validation
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        disablePayButtonIfNeeded()
    }
    
    fileprivate func validateTextField(_ textFieldViewTag: Int) {
        let textFieldView = textFieldViewWithTag(tag: textFieldViewTag)
        if let fieldIdentifier = TextFieldType(rawValue: textFieldViewTag) {
            switch fieldIdentifier {
            case .amountFieldTag:
                if amountTextFieldView.textField.hasText && !amountTextFieldView.textField.isReallyEmpty  {
                    let decimalPart = amountToPay.value
                    if decimalPart > 0 {
                        applyDefaultStyle(textFieldView)
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        amountTextFieldView.text = ""
                        applyErrorStyle(textFieldView)
                        showErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    applyErrorStyle(textFieldView)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .ibanFieldTag, .recipientFieldTag, .usageFieldTag:
                if textFieldView.textField.hasText && !textFieldView.textField.isReallyEmpty {
                    applyDefaultStyle(textFieldView)
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    applyErrorStyle(textFieldView)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            }
        }
    }
    
    fileprivate func textFieldViewWithTag(tag: Int) -> TextFieldWithLabelView {
        paymentInputFields.first(where: { $0.tag == tag }) ?? TextFieldWithLabelView()
    }
    
    fileprivate func validateIBANTextField(){
        if let ibanText = ibanTextFieldView.textField.text, ibanTextFieldView.textField.hasText {
            if IBANValidator().isValid(iban: ibanText) {
                applyDefaultStyle(ibanTextFieldView)
                hideErrorLabel(textFieldTag: .ibanFieldTag)
            } else {
                applyErrorStyle(ibanTextFieldView)
                showValidationErrorLabel(textFieldTag: .ibanFieldTag)
            }
        } else {
            applyErrorStyle(ibanTextFieldView)
            showErrorLabel(textFieldTag: .ibanFieldTag)
        }
    }
    
    fileprivate func showIBANValidationErrorIfNeeded(){
        if IBANValidator().isValid(iban: lastValidatedIBAN) {
            applyDefaultStyle(ibanTextFieldView)
            hideErrorLabel(textFieldTag: .ibanFieldTag)
        } else {
            applyErrorStyle(ibanTextFieldView)
            showValidationErrorLabel(textFieldTag: .ibanFieldTag)
        }
    }

    fileprivate func validateAllInputFields() {
        for textField in paymentInputFields {
            validateTextField(textField.tag)
        }
    }
    
    fileprivate func hideErrorLabels() {
        for errorLabel in paymentInputFieldsErrorLabels {
            errorLabel.isHidden = true
        }
    }
    
    fileprivate func fillInInputFields() {
        guard let model else { return }
        recipientTextFieldView.text = model.extractions.first(where: {$0.name == "payment_recipient"})?.value
        ibanTextFieldView.text = model.extractions.first(where: {$0.name == "iban"})?.value
        usageTextFieldView.text = model.extractions.first(where: {$0.name == "payment_purpose"})?.value
        if let amountString = model.extractions.first(where: {$0.name == "amount_to_pay"})?.value, let amountToPay = Price(extractionString: amountString) {
            self.amountToPay = amountToPay
            let amountToPayText = amountToPay.string
            amountTextFieldView.text = amountToPayText
        }
        validateAllInputFields()
        disablePayButtonIfNeeded()
    }
    
    fileprivate func disablePayButtonIfNeeded() {
        payInvoiceButton.superview?.alpha = paymentInputFields.allSatisfy({ !$0.textField.isReallyEmpty }) && amountToPay.value > 0 ? 1 : 0.4
    }


    fileprivate func showErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = ""
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.recipient.non.empty.check",
                                                            comment: " recipient failed non empty check")
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.iban.non.empty.check",
                                                            comment: "iban failed non empty check")
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.amount.non.empty.check",
                                                            comment: "amount failed non empty check")
        case .usageFieldTag:
            errorLabel = usageErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.purpose.non.empty.check",
                                                            comment: "purpose failed non empty check")
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = UIColor.GiniHealthColors.feedback1
            errorLabel.text = errorMessage
        }
    }
    
    fileprivate func showValidationErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.default.textfield.validation.check",
                                                            comment: "the field failed non empty check")
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginihealth.errors.failed.iban.validation.check",
                                                            comment: "iban failed validation check")
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = UIColor.GiniHealthColors.feedback1
            errorLabel.text = errorMessage
        }
    }

    fileprivate func hideErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
        }
        disablePayButtonIfNeeded()
    }
    
    // MARK: - Pay Button Action
    func payButtonClicked() {
        var event = TrackingEvent.init(type: PaymentReviewScreenEventType.onToTheBankButtonClicked)
        if let selectedPaymentProviderName = selectedPaymentProvider?.name {
            event.info = ["paymentProvider": selectedPaymentProviderName]
        }
        trackingDelegate?.onPaymentReviewScreenEvent(event: event)
        view.endEditing(true)
        validateAllInputFields()
        validateIBANTextField()
        if let iban = ibanTextFieldView.text {
            lastValidatedIBAN = iban
        }

        // check if no errors labels are shown
        if (paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }) {
            if let selectedProvider = selectedPaymentProvider, !amountTextFieldView.textField.isReallyEmpty {
                let amountText = amountToPay.extractionString
                let paymentInfo = PaymentInfo(recipient: recipientTextFieldView.text ?? "", 
                                              iban: ibanTextFieldView.text ?? "",
                                              bic: "", amount: amountText,
                                              purpose: usageTextFieldView.text ?? "",
                                              paymentUniversalLink: selectedProvider.universalLinkIOS,
                                              paymentProviderId: selectedProvider.id)
                model?.createPaymentRequest(paymentInfo: paymentInfo)
                let paymentRecipientExtraction = Extraction(box: nil, 
                                                            candidates: "",
                                                            entity: "text",
                                                            value: recipientTextFieldView.text ?? "",
                                                            name: "payment_recipient")
                let ibanExtraction = Extraction(box: nil, 
                                                candidates: "",
                                                entity: "iban",
                                                value: paymentInfo.iban,
                                                name: "iban")
                let referenceExtraction = Extraction(box: nil, 
                                                     candidates: "",
                                                     entity: "text", value:
                                                        paymentInfo.purpose,
                                                     name: "payment_purpose")
                let amoutToPayExtraction = Extraction(box: nil, 
                                                      candidates: "",
                                                      entity: "amount", value:
                                                        paymentInfo.amount,
                                                      name: "amount_to_pay")
                let updatedExtractions = [paymentRecipientExtraction, ibanExtraction, referenceExtraction, amoutToPayExtraction]
                model?.sendFeedback(updatedExtractions: updatedExtractions)
            }
        }
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
        if #available(iOS 11.0, *) {
            mainView.bounds.origin.y = keyboardSize.height - view.safeAreaInsets.bottom
        } else {
            mainView.bounds.origin.y = keyboardSize.height
        }
        
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

// MARK: - UITextFieldDelegate

extension PaymentReviewViewController: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     Updates amoutToPay, formated string with a currency and removes "0.00" value
     */
    fileprivate func updateAmoutToPayWithCurrencyFormat() {
        if amountTextFieldView.textField.hasText, let amountFieldText = amountTextFieldView.text {
            if let priceValue = decimal(from: amountFieldText ) {
                amountToPay.value = priceValue
                if priceValue > 0 {
                    let amountToPayText = amountToPay.string
                    amountTextFieldView.text = amountToPayText
                } else {
                    amountTextFieldView.text = ""
                }
            }
        }
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        applySelectionStyle(textFieldViewWithTag(tag: textField.tag))
        
        // remove currency symbol and whitespaces for edit mode
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            hideErrorLabel(textFieldTag: fieldIdentifier)
            
            if fieldIdentifier == .amountFieldTag {
                let amountToPayText = amountToPay.stringWithoutSymbol
                amountTextFieldView.text = amountToPayText
            }
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        // add currency format when edit is finished
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag {
            updateAmoutToPayWithCurrencyFormat()
        }
        validateTextField(textField.tag)
        if TextFieldType(rawValue: textField.tag) == .ibanFieldTag {
            if textField.text == lastValidatedIBAN {
                showIBANValidationErrorIfNeeded()
            }
        }
        disablePayButtonIfNeeded()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag,
           let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            // Limit length to 7 digits
            let onlyDigits = String(updatedText
                                        .trimmingCharacters(in: .whitespaces)
                                        .filter { c in c != "," && c != "."}
                                        .prefix(7))
            
            if let decimal = Decimal(string: onlyDigits) {
                let decimalWithFraction = decimal / 100
                
                if let newAmount = Price.stringWithoutSymbol(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces) {
                    // Save the selected text range to restore the cursor position after replacing the text
                    let selectedRange = textField.selectedTextRange
                    
                    textField.text = newAmount
                    amountToPay.value = decimalWithFraction
                    
                    // Move the cursor position after the inserted character
                    if let selectedRange = selectedRange {
                        let countDelta = newAmount.count - text.count
                        let offset = countDelta == 0 ? 1 : countDelta
                        textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                    }
                }
            }
            disablePayButtonIfNeeded()
            return false
           }
        return true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension PaymentReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        model?.numberOfCells ?? 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCellIdentifier", for: indexPath) as! PageCollectionViewCell
        cell.pageImageView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        cell.pageImageView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: Constants.bottomPaddingPageImageView, right: 0.0)
        let cellModel = model?.getCellViewModel(at: indexPath)
        cell.pageImageView.display(image: cellModel?.preview ?? UIImage())
        return cell
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }

    // MARK: - For Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
}

extension PaymentReviewViewController {
    func showError(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedStringPreferredFormat("ginihealth.alert.ok.title",
                                                                             comment: "ok title for action"), style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension PaymentReviewViewController {
    private enum Constants {
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
        @available(iOS 13.0, *)
        static let loadingIndicatorStyle = UIActivityIndicatorView.Style.large
    }
}
