//
//  PaymentViewController.swift
//  Bank
//
//  Created by Nadya Karaban on 30.04.21.
//

import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK
import UIKit

class PaymentViewController: UIViewController {
    @IBOutlet var receipient: UITextField!
    @IBOutlet var iban: UITextField!
    @IBOutlet var amount: UITextField!
    @IBOutlet var purpose: UITextField!
    
    @IBOutlet var paymentInputFieldsErrorLabels: [UILabel]!
    @IBOutlet var purposeErrorLabel: UILabel!
    @IBOutlet var amountErrorLabel: UILabel!
    @IBOutlet var ibanErrorLabel: UILabel!
    @IBOutlet var recipientErrorLabel: UILabel!
    @IBOutlet var paymentInputFields: [UITextField]!
    
    
    @IBOutlet var payButton: UIButton!
    
    @IBOutlet var backToBusinessButton: UIButton!
    
    enum TextFieldType: Int {
        case recipientFieldTag = 1
        case ibanFieldTag
        case amountFieldTag
        case usageFieldTag
    }

    var viewModel: PaymentViewModel?
    
    public static func instantiate(with apiLib: GiniApiLib) -> PaymentViewController {
        let vc = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "paymentViewController") as? PaymentViewController)!
        vc.viewModel = PaymentViewModel(with: apiLib)
        return vc
    }
    
    fileprivate func subscribeOnAppNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func subscribeOnNotifications(){
        subscribeOnAppNotifications()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnNotifications()
    }

    @objc func appBecomeActive() {
        setupUI()
        setupViewModel()
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupUI()
        setupViewModel()
    }

    fileprivate func setupViewModel() {
        
        viewModel?.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async { [weak self] in
                let isLoading = self?.viewModel?.isLoading ?? false
                if isLoading {
                    self?.view.showLoading(style: .whiteLarge, color:GiniPayBankConfiguration.shared.analysisLoadingIndicatorColor, scale: 1.0)
                } else {
                    self?.view.stopLoading()
                }
            }
        }
        
        viewModel?.onPaymentInfoFetched = {[weak self] paymentInfo in
            DispatchQueue.main.async {
                self?.fillOutTheData(paymentInfo: paymentInfo)
            }
        }
        
        viewModel?.onResolvePaymentRequest = { [weak self] in
            DispatchQueue.main.async {
                self?.backToBusinessButton.isHidden = false
                self?.showAlert(message: "Payment was successfully resolved")
            }
        }
        viewModel?.onResolvePaymentRequestErrorHandling = { [weak self] in
            DispatchQueue.main.async {
                self?.backToBusinessButton.isHidden = false
                self?.showAlert(message: "Payment was not resolved")
            }
        }
        viewModel?.fetchPaymentRequest()
    }

    fileprivate func setupUI() {
        for field in paymentInputFields {
            let placeholderText = inputFieldPlaceholderText(field)
            field.attributedPlaceholder = NSAttributedString(string: placeholderText)
        }
        payButton.isEnabled = false
        backToBusinessButton.isHidden = true
    }
    
    
    @IBAction func resolvePayment(_ sender: Any) {
        
        validateAllInputFields()
        
        //check if no errors labels are shown
        if (paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }) {
            let paymentInfo = PaymentInfo(recipient: receipient.text ?? "", iban: iban.text ?? "", bic: "", amount: amount.text ?? "", purpose: purpose.text ?? "")
            viewModel?.resolvePaymentRequest(paymentInfo: paymentInfo)
        }
    }
    
    @IBAction func backToBusiness(_ sender: Any) {
        viewModel?.openPaymentRequesterApp()
    }
    
    fileprivate func fillOutTheData(paymentInfo: PaymentInfo) {
        receipient.text = paymentInfo.recipient
        iban.text = paymentInfo.iban
        amount.text = paymentInfo.amount
        purpose.text = paymentInfo.purpose
        payButton.isEnabled = true
        self.showAlert("", message: "Payment data was successfully fetched")
    }
}

// MARK: - UITextFieldDelegate

extension PaymentViewController: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        validateTextField(textField)
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        validateTextField(textField)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            hideErrorLabel(textFieldTag: fieldIdentifier)
        }
    }
}

// MARK: - Input fields validation

extension PaymentViewController {
    
    fileprivate func validateTextField(_ textField: UITextField) {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .ibanFieldTag:
                if let ibanText = textField.text, textField.hasText {
                    if IBANValidator().isValid(iban: ibanText) {
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        showValidationErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .amountFieldTag:
                
                let price = Amount.init(value: Decimal(string:textField.text ?? "") ?? 0, currencyCode: "EUR")
                amount.text = price.string
                if (Decimal(string: price.stringWithoutSymbol ?? "") ?? 0 > 0) && textField.hasText {
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .recipientFieldTag, .usageFieldTag:
                if textField.hasText && !textField.isReallyEmpty {
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
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

    fileprivate func showErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = ""
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybank.errors.failed.recipient.non.empty.check",
                                                            comment: " recipient failed non empty check")
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybank.errors.failed.iban.non.empty.check",
                                                            comment: "iban failed non empty check")
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybank.errors.failed.amount.non.empty.check",
                                                            comment: "amount failed non empty check")
        case .usageFieldTag:
            errorLabel = purposeErrorLabel
            errorMessage = NSLocalizedStringPreferredFormat("ginipaybank.errors.failed.purpose.non.empty.check",
                                                            comment: "purpose failed non empty check")
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = .red
            errorLabel.text = errorMessage
        }
    }
    
    fileprivate func showValidationErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = NSLocalizedStringPreferredFormat("ginipaybank.errors.failed.default.textfield.validation.check",
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
            errorLabel = purposeErrorLabel
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.textColor = .red
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
            errorLabel = purposeErrorLabel
        }
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
        }
    }
}

// MARK: - Input fields configuration

extension PaymentViewController{
    
    @objc fileprivate func doneWithAmountInputButtonTapped() {
        let amountStruct = Amount.init(value: Decimal(string: amount.text ?? "") ?? 0, currencyCode: "EUR")
        amount.text = amountStruct.string
        view.endEditing(true)
    }

     func addDoneButtonForNumPad(_ textField: UITextField) {
        let toolbarDone = UIToolbar(frame:CGRect(x:0, y:0, width:view.frame.width, height:40))
        
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(PaymentViewController.doneWithAmountInputButtonTapped))
        
        toolbarDone.items = [barBtnDone]
        textField.inputAccessoryView = toolbarDone
    }
    
    fileprivate func inputFieldPlaceholderText(_ textField: UITextField) -> String {
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            switch fieldIdentifier {
            case .recipientFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybank.reviewscreen.recipient.placeholder",
                                                        comment: "placeholder text for recipient input field")
            case .ibanFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybank.reviewscreen.iban.placeholder",
                                                        comment: "placeholder text for iban input field")
            case .amountFieldTag:
                addDoneButtonForNumPad(textField)
                return NSLocalizedStringPreferredFormat("ginipaybank.reviewscreen.amount.placeholder",
                                                        comment: "placeholder text for amount input field")
            case .usageFieldTag:
                return NSLocalizedStringPreferredFormat("ginipaybank.reviewscreen.usage.placeholder",
                                                        comment: "placeholder text for usage input field")
            }
        }
        return ""
    }
}

// MARK: - UIAlertController

extension PaymentViewController {
    func showAlert(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
