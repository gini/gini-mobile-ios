//
//  PaymentReviewViewController.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 30.03.21.
//

import Foundation
import GiniPayApiLib

public final class PaymentReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var recipientField: UITextField!
    @IBOutlet var ibanField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var usageField: UITextField!
    @IBOutlet var payButton: GiniCustomButton!
    @IBOutlet var paymentInputFieldsErrorLabels: [UILabel]!
    @IBOutlet var usageErrorLabel: UILabel!
    @IBOutlet var amountErrorLabel: UILabel!
    @IBOutlet var ibanErrorLabel: UILabel!
    @IBOutlet var recipientErrorLabel: UILabel!
    @IBOutlet var paymentInputFields: [UITextField]!
    @IBOutlet var bankProviderButtonView: UIView!
    @IBOutlet weak var bankProviderLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var inputContainer: UIView!
    @IBOutlet var containerCollectionView: UIView!
    @IBOutlet var paymentInfoStackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    
    var model: PaymentReviewModel?
    var paymentProviders: [PaymentProvider] = []
    private var amountToPay = Price(extractionString: "")
    enum TextFieldType: Int {
        case recipientFieldTag = 1
        case ibanFieldTag
        case amountFieldTag
        case usageFieldTag
    }
    
    public static func instantiate(with giniPayBusiness: GiniPayBusiness, document: Document, extractions: [Extraction]) -> PaymentReviewViewController {
        let vc = (UIStoryboard(name: "PaymentReview", bundle: giniPayBusinessBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        vc.model = PaymentReviewModel(with: giniPayBusiness, document: document, extractions: extractions )
        
        return vc
    }
    
    public static func instantiate(with giniPayBusiness: GiniPayBusiness, data: DataForReview) -> PaymentReviewViewController {
        let vc = (UIStoryboard(name: "PaymentReview", bundle: giniPayBusinessBundle())
            .instantiateViewController(withIdentifier: "paymentReviewViewController") as? PaymentReviewViewController)!
        vc.model = PaymentReviewModel(with: giniPayBusiness, document: data.document, extractions: data.extractions)
        
        return vc
    }

    var giniPayBusinessConfiguration = GiniPayBusinessConfiguration.shared
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnNotifications()
        dismissKeyboardOnTap()
        congifureUI()
        setupViewModel()
    }
    
    fileprivate func setupViewModel() {
        
        model?.onNoAppsErrorHandling = {[weak self] error in
            DispatchQueue.main.async {
                self?.showError(message: NSLocalizedStringPreferredFormat("ginipaybusiness.errors.no.banking.app.installed",
                                                                         comment: "no bank apps installed") )
            }
        }
        
        model?.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.fillInInputFields()
            }
        }
        
        model?.onPaymentProvidersFetched = {[weak self] providers in
            self?.paymentProviders.append(contentsOf: providers)
        }
        
        model?.checkIfAnyPaymentProviderAvailiable()

        
        model?.updateImagesLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.model?.isImagesLoading ?? false
                if isLoading {
                    self?.collectionView.showLoading(style: self?.giniPayBusinessConfiguration.loadingIndicatorStyle, color: self?.giniPayBusinessConfiguration.loadingIndicatorColor, scale: self?.giniPayBusinessConfiguration.loadingIndicatorScale)
                } else {
                    self?.collectionView.stopLoading()
                }
            }
        }
       
        model?.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.model?.isLoading ?? false
                if isLoading {
                    self?.view.showLoading(style: self?.giniPayBusinessConfiguration.loadingIndicatorStyle, color: self?.giniPayBusinessConfiguration.loadingIndicatorColor, scale: self?.giniPayBusinessConfiguration.loadingIndicatorScale)
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
                self?.showError(message: NSLocalizedStringPreferredFormat("ginipaybusiness.errors.default",
                                                                         comment: "default error message") )
            }
        }
        
        model?.onCreatePaymentRequestErrorHandling = {[weak self] () in
            DispatchQueue.main.async {
                self?.showError(message: NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.payment.request.creation",
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
        inputContainer.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    // MARK: - congifureUI

    fileprivate func congifureUI() {
        configureScreenBackgroundColor()
        configureCollectionView()
        configurePayButton()
        configurePaymentInputFields()
        configureBankProviderView()
        configurePageControl()
        configureCloseButton()
        hideErrorLabels()
        fillInInputFields()
        addDoneButtonForNumPad(amountField)
    }

    // MARK: - TODO ConfigureBankProviderView Dynamically configured
    
    fileprivate func configureBankProviderView() {
        bankProviderButtonView.backgroundColor = .white
        bankProviderButtonView.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
        bankProviderButtonView.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldBorderWidth
        bankProviderButtonView.layer.borderColor = UIColor.from(hex: 0xE6E7ED).cgColor
        bankProviderLabel.textColor = UIColor.from(giniColor:giniPayBusinessConfiguration.bankButtonTextColor)
        bankProviderLabel.font = giniPayBusinessConfiguration.customFont.regular
    }

    fileprivate func configurePayButton() {
        payButton.defaultBackgroundColor = UIColor.from(giniColor: giniPayBusinessConfiguration.payButtonBackgroundColor)
        payButton.disabledBackgroundColor = .lightGray
        payButton.layer.cornerRadius = giniPayBusinessConfiguration.payButtonCornerRadius
        payButton.titleLabel?.font = giniPayBusinessConfiguration.customFont.regular
        payButton.tintColor = UIColor.from(giniColor: giniPayBusinessConfiguration.payButtonTextColor)
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
        pageControl.layer.zPosition = 10
        pageControl.pageIndicatorTintColor = UIColor.from(giniColor:giniPayBusinessConfiguration.pageIndicatorTintColor)
        pageControl.currentPageIndicatorTintColor = UIColor.from(giniColor:giniPayBusinessConfiguration.currentPageIndicatorTintColor)
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = model?.document.pageCount ?? 1
        if pageControl.numberOfPages == 1 {
            pageControlHeightConstraint.constant = 0
        } else {
            pageControlHeightConstraint.constant = 20
        }
    }
    
    fileprivate func configureCloseButton() {
        closeButton.isHidden = !giniPayBusinessConfiguration.showPaymentReviewCloseButton
        closeButton.setImage(UIImageNamedPreferred(named: "paymentReviewCloseButton"), for: .normal)
    }
    
    fileprivate func configureScreenBackgroundColor() {
        let screenBackgroundColor = UIColor.from(giniColor:giniPayBusinessConfiguration.paymentScreenBackgroundColor)
        mainView.backgroundColor = screenBackgroundColor
        collectionView.backgroundColor = screenBackgroundColor
        pageControl.backgroundColor = screenBackgroundColor
        inputContainer.backgroundColor = UIColor.from(giniColor:giniPayBusinessConfiguration.inputFieldsContainerBackgroundColor)
    }
    
    // MARK: - Input fields configuration

    fileprivate func applyDefaultStyle(_ field: UITextField) {
        if #available(iOS 13.0, *) {
            field.borderStyle = .roundedRect
            field.overrideUserInterfaceStyle = .dark
        } else {
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftViewMode = .always
            field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.rightViewMode = .always
        }
        field.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
        field.layer.borderWidth = giniPayBusinessConfiguration.paymentInputFieldBorderWidth
        field.backgroundColor = UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldBackgroundColor)
        field.font = giniPayBusinessConfiguration.customFont.regular
        field.textColor = UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldTextColor)
        let placeholderText = inputFieldPlaceholderText(field)
        field.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.from(giniColor: giniPayBusinessConfiguration.paymentInputFieldPlaceholderTextColor), NSAttributedString.Key.font: giniPayBusinessConfiguration.customFont.regular])
        field.layer.masksToBounds = true
    }

    fileprivate func applyErrorStyle(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
            textField.backgroundColor = UIColor.from(giniColor: self.giniPayBusinessConfiguration.paymentInputFieldBackgroundColor)
            textField.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldErrorStyleBorderWidth
            textField.layer.borderColor = self.giniPayBusinessConfiguration.paymentInputFieldErrorStyleColor.cgColor
            textField.layer.masksToBounds = true
        }
    }

    fileprivate func applySelectionStyle(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            textField.layer.cornerRadius = self.giniPayBusinessConfiguration.paymentInputFieldCornerRadius
            textField.backgroundColor = self.giniPayBusinessConfiguration.paymentInputFieldSelectionBackgroundColor
            textField.layer.borderWidth = self.giniPayBusinessConfiguration.paymentInputFieldSelectionStyleBorderWidth
            textField.layer.borderColor = self.giniPayBusinessConfiguration.paymentInputFieldSelectionStyleColor.cgColor
            textField.layer.masksToBounds = true
        }
    }
    
    @objc fileprivate func doneWithAmountInputButtonTapped() {
        amountField.endEditing(true)
        amountField.resignFirstResponder()
        
        if amountField.hasText && !amountField.isReallyEmpty {
            updateAmoutToPayWithCurrencyFormat()
        }
    }

     func addDoneButtonForNumPad(_ textField: UITextField) {
        let toolbarDone = UIToolbar(frame:CGRect(x:0, y:0, width:view.frame.width, height:40))
        
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(PaymentReviewViewController.doneWithAmountInputButtonTapped))
        
        toolbarDone.items = [barBtnDone]
        textField.inputAccessoryView = toolbarDone
    }
    
    fileprivate func inputFieldPlaceholderText(_ textField: UITextField) -> String {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .recipientFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.recipient.placeholder",
                                                        comment: "placeholder text for recipient input field")
            case .ibanFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.iban.placeholder",
                                                        comment: "placeholder text for iban input field")
            case .amountFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.amount.placeholder",
                                                        comment: "placeholder text for amount input field")
            case .usageFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybusiness.reviewscreen.usage.placeholder",
                                                        comment: "placeholder text for usage input field")
            }
        }
        return ""
    }
    
    // MARK: - Input fields validation
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        disablePayButtonIfNeeded()
    }
    
    fileprivate func validateTextField(_ textField: UITextField) {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .ibanFieldTag:
                if let ibanText = textField.text, textField.hasText {
                    if IBANValidator().isValid(iban: ibanText) {
                        applyDefaultStyle(textField)
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        applyErrorStyle(textField)
                        showValidationErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    applyErrorStyle(textField)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .amountFieldTag:
                if amountField.hasText && !amountField.isReallyEmpty, let decimalPart = amountToPay?.value  {
                    if decimalPart > 0 {
                        applyDefaultStyle(textField)
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        amountField.text = ""
                        applyErrorStyle(textField)
                        showErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    applyErrorStyle(textField)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .recipientFieldTag, .usageFieldTag:
                if textField.hasText && !textField.isReallyEmpty {
                    applyDefaultStyle(textField)
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    applyErrorStyle(textField)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            }
        }
    }

    fileprivate func validateAllInputFields() {
        for textField in paymentInputFields {
            validateTextField(textField)
        }
    }
    
    fileprivate func hideErrorLabels() {
        for errorLabel in paymentInputFieldsErrorLabels {
                errorLabel.isHidden = true
        }
    }
    
    fileprivate func fillInInputFields() {
        recipientField.text = model?.extractions.first(where: {$0.name == "paymentRecipient"})?.value
        ibanField.text = model?.extractions.first(where: {$0.name == "iban"})?.value
        usageField.text = model?.extractions.first(where: {$0.name == "paymentPurpose"})?.value
        if let amountString = model?.extractions.first(where: {$0.name == "amountToPay"})?.value {
            amountToPay = Price(extractionString: amountString)
            let amountToPayText = amountToPay?.string
            amountField.text = amountToPayText
        }
        disablePayButtonIfNeeded()
    }
    
    fileprivate func disablePayButtonIfNeeded() {
        payButton.isEnabled = paymentInputFields.allSatisfy { !$0.isReallyEmpty }
    }


    fileprivate func showErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = ""
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.recipient.non.empty.check",
                                                            comment: " recipient failed non empty check")
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.iban.non.empty.check",
                                                            comment: "iban failed non empty check")
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.amount.non.empty.check",
                                                            comment: "amount failed non empty check")
        case .usageFieldTag:
            errorLabel = usageErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.purpose.non.empty.check",
                                                            comment: "purpose failed non empty check")
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = giniPayBusinessConfiguration.paymentInputFieldErrorStyleColor
            errorLabel.text = errorMessage
        }
    }
    
    fileprivate func showValidationErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.default.textfield.validation.check",
                                                            comment: "the field failed non empty check")
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybusiness.errors.failed.iban.validation.check",
                                                            comment: "iban failed validation check")
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = giniPayBusinessConfiguration.paymentInputFieldErrorStyleColor
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
    }
    
    // MARK: - IBAction
    
    @IBAction func payButtonClicked(_ sender: Any) {
        view.endEditing(true)
        validateAllInputFields()
        
        //check if no errors labels are shown
        if (paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }) {
            
            if let selectedPaymentProvider = paymentProviders.first, !amountField.isReallyEmpty, let amountText = amountToPay?.extractionString
             {
                let paymentInfo = PaymentInfo(recipient: recipientField.text ?? "", iban: ibanField.text ?? "", bic: "", amount: amountText, purpose: usageField.text ?? "", paymentProviderScheme: selectedPaymentProvider.appSchemeIOS, paymentProviderId: selectedPaymentProvider.id)
                model?.createPaymentRequest(paymentInfo: paymentInfo)
                let paymentRecipientExtraction = Extraction(box: nil, candidates: "", entity: "text", value: recipientField.text ?? "", name: "paymentRecipient")
                let ibanExtraction = Extraction(box: nil, candidates: "", entity: "iban", value: paymentInfo.iban, name: "iban")
                let referenceExtraction = Extraction(box: nil, candidates: "", entity: "reference", value: paymentInfo.purpose, name: "reference")
                let amoutToPayExtraction = Extraction(box: nil, candidates: "", entity: "amount", value: paymentInfo.amount, name: "amountToPay")
                let updatedExtractions = [paymentRecipientExtraction, ibanExtraction, referenceExtraction,amoutToPayExtraction ]
                model?.sendFeedback(updatedExtractions: updatedExtractions)
            }
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        if (keyboardWillShowCalled) {
            view.endEditing(true)
        } else {
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
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
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
        applyDefaultStyle(textField)
        return true
    }

    fileprivate func updateAmoutToPayWithCurrencyFormat() {
        if amountField.hasText, let amountFieldText = amountField.text {
            if let priceValue = decimal(from: amountFieldText ) {
                amountToPay?.value = priceValue
            }
            let amountToPayText = amountToPay?.string
            amountField.text = amountToPayText
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        // add currency format when edit is finished
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag {
            updateAmoutToPayWithCurrencyFormat()
        }
        applyDefaultStyle(textField)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        applySelectionStyle(textField)
        
        // remove currency symbol and whitespaces for edit mode
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            hideErrorLabel(textFieldTag: fieldIdentifier)
            
            if fieldIdentifier == .amountFieldTag, amountField.hasText && !amountField.isReallyEmpty {
                let amountToPayText = amountToPay?.stringWithoutSymbol
                amountField.text = amountToPayText
            }
        }
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
                    amountToPay?.value = decimalWithFraction
                    
                    // Move the cursor position after the inserted character
                    if let selectedRange = selectedRange {
                        let countDelta = newAmount.count - text.count
                        let offset = countDelta == 0 ? 1 : countDelta
                        textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                    }
                }
            }
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
        cell.pageImageView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0)
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
        let OKAction = UIAlertAction(title: NSLocalizedStringPreferredFormat("ginipaybusiness.alert.ok.title",
                                                                             comment: "ok title for action"), style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}

class GiniCustomButton: UIButton {
    var disabledBackgroundColor: UIColor? = .gray
    var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    override public var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? defaultBackgroundColor : disabledBackgroundColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.5 : 1
        }
    }
}
