//
//  LineItemDetailsViewController.swift
// GiniBank
//
//  Created by Maciej Trybilo on 18.12.19.
//

import UIKit
import GiniBankAPILibrary

protocol LineItemDetailsViewControllerDelegate: AnyObject {
    
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController,
                         lineItem: DigitalInvoice.LineItem,
                         index: Int,
                         shouldPopViewController: Bool)
}

class LineItemDetailsViewController: UIViewController {

    var lineItem: DigitalInvoice.LineItem? {
        didSet {
            update()
        }
    }
    
    var returnReasons: [ReturnReason]?
    
    var lineItemIndex: Int?
    
    var returnAssistantConfiguration : ReturnAssistantConfiguration? {
        didSet {
            update()
        }
    }
    
    weak var delegate: LineItemDetailsViewControllerDelegate?
    
    private let stackView = UIStackView()

    private let checkboxContainerStackView = UIStackView()
    private let checkboxButton = CheckboxButton()
    private let checkboxButtonTextLabel = UILabel()

    private let itemNameTextField = GiniTextField()
    
    private let quantityAndItemPriceContainer = UIView()
    private let quantityTextField = GiniTextField()
    private let multiplicationLabel = UILabel()
    private let itemPriceTextField = GiniTextField()
    
    private let totalPriceStackView = UIStackView()
    private let totalPriceTitleLabel = UILabel()
    private let totalPriceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemSaveButtonTitle),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveButtonTapped))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButtonTextLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameTextField.translatesAutoresizingMaskIntoConstraints = false
        quantityAndItemPriceContainer.translatesAutoresizingMaskIntoConstraints = false
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        multiplicationLabel.translatesAutoresizingMaskIntoConstraints = false
        itemPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        totalPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        totalPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        checkboxContainerStackView.axis = .horizontal
        
        checkboxButton.tintColor = returnAssistantConfiguration?.digitalInvoiceLineItemToggleSwitchTintColor ?? returnAssistantConfiguration?.lineItemTintColor
        checkboxButton.checkedState = .checked
        checkboxButton.addTarget(self, action: #selector(checkboxButtonTapped), for: .touchUpInside)
        checkboxContainerStackView.addArrangedSubview(checkboxButton)
        
        checkboxButtonTextLabel.font = returnAssistantConfiguration?.lineItemDetailsDescriptionLabelFont
        checkboxButtonTextLabel.textColor = returnAssistantConfiguration?.lineItemDetailsDescriptionLabelColor
        checkboxContainerStackView.addArrangedSubview(checkboxButtonTextLabel)
        
        // This is outside of the main stackView in order to deal with the checkbox button being larger
        // than it appears (for accessibility reasons)
        view.addSubview(checkboxContainerStackView)
        
        let margin: CGFloat = 16
        
        if #available(iOS 11.0, *) {
            
            checkboxContainerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                                constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                            constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                                 constant: -margin).isActive = true
            
        } else {
            
            checkboxContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.topAnchor.constraint(equalTo: view.topAnchor,
                                                            constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor,
                                                                 constant: -margin).isActive = true
        }
        
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: checkboxContainerStackView.bottomAnchor,
                                       constant: margin - CheckboxButton.margin).isActive = true
        
        if #available(iOS 11.0, *) {
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: margin).isActive = true

            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -margin).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -margin).isActive = true
        } else {
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: margin).isActive = true
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -margin).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor,
                                              constant: -margin).isActive = true
        }
        
        itemNameTextField.titleFont = configuration.lineItemDetailsDescriptionLabelFont
        itemNameTextField.titleTextColor = configuration.lineItemDetailsDescriptionLabelColor
        itemNameTextField.title = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemNameTextFieldTitle)
        itemNameTextField.textFont = configuration.lineItemDetailsContentLabelFont
        itemNameTextField.textColor = configuration.lineItemDetailsContentLabelColor
        itemNameTextField.underscoreColor = configuration.lineItemDetailsContentHighlightedColor
        itemNameTextField.prefixText = nil
        itemNameTextField.shouldAllowLetters = true
        
        stackView.addArrangedSubview(itemNameTextField)
        
        quantityTextField.titleFont = configuration.lineItemDetailsDescriptionLabelFont
        quantityTextField.titleTextColor = configuration.lineItemDetailsDescriptionLabelColor
        quantityTextField.title = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemQuantityTextFieldTitle)
        quantityTextField.textFont = configuration.lineItemDetailsContentLabelFont
        quantityTextField.textColor = configuration.lineItemDetailsContentLabelColor
        quantityTextField.underscoreColor = configuration.lineItemDetailsContentHighlightedColor
        quantityTextField.prefixText = nil
        quantityTextField.keyboardType = .numberPad
        quantityTextField.delegate = self
        quantityAndItemPriceContainer.addSubview(quantityTextField)
        
        multiplicationLabel.font = configuration.lineItemDetailsContentLabelFont
        multiplicationLabel.textColor = configuration.lineItemDetailsContentLabelColor
        multiplicationLabel.text = "X"
        quantityAndItemPriceContainer.addSubview(multiplicationLabel)
        
        itemPriceTextField.titleFont = configuration.lineItemDetailsDescriptionLabelFont
        itemPriceTextField.titleTextColor = configuration.lineItemDetailsDescriptionLabelColor
        itemPriceTextField.title = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemPriceTextFieldTitle)
        itemPriceTextField.textFont = configuration.lineItemDetailsContentLabelFont
        itemPriceTextField.textColor = configuration.lineItemDetailsContentLabelColor
        itemPriceTextField.underscoreColor = configuration.lineItemDetailsContentHighlightedColor
        
        itemPriceTextField.keyboardType = .decimalPad
        itemPriceTextField.delegate = self
        quantityAndItemPriceContainer.addSubview(itemPriceTextField)
        
        quantityTextField.leadingAnchor.constraint(equalTo: quantityAndItemPriceContainer.leadingAnchor).isActive = true
        quantityTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        quantityTextField.trailingAnchor.constraint(equalTo: multiplicationLabel.leadingAnchor,
                                                    constant: -margin).isActive = true
        quantityTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        
        multiplicationLabel.centerXAnchor.constraint(equalTo: quantityAndItemPriceContainer.centerXAnchor)
            .isActive = true
        multiplicationLabel.firstBaselineAnchor.constraint(equalTo: quantityTextField.textFieldFirstBaselineAnchor)
            .isActive = true
        multiplicationLabel.trailingAnchor.constraint(equalTo: itemPriceTextField.leadingAnchor,
                                                      constant: -margin).isActive = true
        multiplicationLabel.setContentHuggingPriority(.required, for: .horizontal)
        multiplicationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        multiplicationLabel.accessibilityLabel = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemMultiplicationAccessibilityLabel)
        
        itemPriceTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        itemPriceTextField.trailingAnchor.constraint(equalTo: quantityAndItemPriceContainer.trailingAnchor)
            .isActive = true
        itemPriceTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(quantityAndItemPriceContainer)
        
        totalPriceStackView.axis = .horizontal
        totalPriceStackView.spacing = 16
        
        let dummyView = UIView()
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        
        totalPriceStackView.addArrangedSubview(dummyView)
        
        totalPriceTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalPriceTitleLabel.font = configuration.lineItemDetailsDescriptionLabelFont
        totalPriceTitleLabel.textColor = configuration.lineItemDetailsDescriptionLabelColor
        totalPriceTitleLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemTotalPriceTitle)
        totalPriceTitleLabel.font = UIFont.systemFont(ofSize: 12)
        
        totalPriceStackView.addArrangedSubview(totalPriceTitleLabel)
        
        totalPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        totalPriceStackView.addArrangedSubview(totalPriceLabel)
        
        stackView.addArrangedSubview(totalPriceStackView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(gestureRecognizer)
     
        accessibilityElements = [checkboxContainerStackView,
                                 itemNameTextField,
                                 quantityTextField,
                                 multiplicationLabel,
                                 itemPriceTextField,
                                 totalPriceTitleLabel,
                                 totalPriceLabel]
        
        update()
        view.backgroundColor = UIColor.from(giniColor: configuration.lineItemDetailsBackgroundColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let lineItem = lineItem, !lineItem.isUserInitiated else { return }
        
        if isMovingFromParent, transitionCoordinator?.isInteractive == false {
            /*
            Automatically save changes before user returns to main screen, so in case he
            forgets to save it, changes are not lost
             */
            proceedWithSaveAction(shouldPopViewController: false)
        }
      }
    
    @objc func saveButtonTapped() {
        proceedWithSaveAction(shouldPopViewController: true)
    }
    
    @objc func proceedWithSaveAction(shouldPopViewController: Bool) {
        guard let lineItem = lineItemFromFields(), let index = lineItemIndex else { return }
        
        delegate?.didSaveLineItem(lineItemDetailsViewController: self,
                                  lineItem: lineItem,
                                  index: index, shouldPopViewController: shouldPopViewController)

    }
    
    @objc func checkboxButtonTapped() {
        
        guard let lineItem = lineItem else { return }
        
        switch lineItem.selectedState {
        case .deselected:
            self.lineItem?.selectedState = .selected
        case .selected:
            guard let returnReasons = returnReasons else {
                self.lineItem?.selectedState = .deselected(reason: nil)
                return
            }
            
            DeselectLineItemActionSheet().present(from: self, source: checkboxButton, returnReasons: returnReasons) { selectedState in
                
                switch selectedState {
                case .selected:
                    break
                case .deselected(let reason):
                    self.lineItem?.selectedState = .deselected(reason: reason)
                }
            }
        }
    }
    
    @objc func backgroundTapped() {
        _ = itemNameTextField.resignFirstResponder()
        _ = quantityTextField.resignFirstResponder()
        _ = itemPriceTextField.resignFirstResponder()
    }
}

extension LineItemDetailsViewController {
    
    private func update() {
        
        guard isViewLoaded else { return }
        
        guard let lineItem = lineItem else { return }
        
        checkboxButtonTextLabel.text = String.localizedStringWithFormat(DigitalInvoiceStrings.lineItemCheckmarkLabel.localizedGiniBankFormat,
                                                                        lineItem.quantity)
        
        itemNameTextField.text = lineItem.name
        quantityTextField.text = String(lineItem.quantity)
        itemPriceTextField.prefixText = lineItem.price.currencySymbol
        itemPriceTextField.text = lineItem.price.stringWithoutSymbol
        
        checkboxButton.isHidden = lineItem.isUserInitiated
        checkboxButtonTextLabel.isHidden = lineItem.isUserInitiated
        
        switch lineItem.selectedState {
        case .selected:
            checkboxButton.checkedState = .checked
        case .deselected:
            checkboxButton.checkedState = .unchecked
        }
        
        if let totalPriceString = lineItem.totalPrice.string {
            let configuration  = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
            let attributedString =
                NSMutableAttributedString(string: totalPriceString,
                                          attributes: [NSAttributedString.Key.foregroundColor: configuration.lineItemDetailsContentLabelColor,
                                                       NSAttributedString.Key.font: configuration.lineItemDetailsTotalPriceMainUnitFont])
            
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: configuration.lineItemDetailsContentLabelColor,
                                            NSAttributedString.Key.baselineOffset: 5,
                                            NSAttributedString.Key.font: configuration.lineItemDetailsTotalPriceFractionalUnitFont],
                                           range: NSRange(location: totalPriceString.count - 3, length: 3))
            
            totalPriceLabel.attributedText = attributedString
        }
    }
}

extension LineItemDetailsViewController {
    
    private func lineItemFromFields() -> DigitalInvoice.LineItem? {
        let lineItemMaximumAllowedValue = Decimal(25000)
        
        guard var lineItem = lineItem else { return nil}
        guard let priceValue = decimal(from: itemPriceTextField.text ?? "0") else{ return nil }
        
        var itemPriceValue = priceValue
        
        if itemPriceValue > lineItemMaximumAllowedValue {
            itemPriceValue = lineItemMaximumAllowedValue
        }
        if let itemName = itemNameTextField.text {
            let emptyNameCaption: String = .ginibankLocalized(resource: DigitalInvoiceStrings.noTitleArticle)
            
            lineItem.name = itemName.isEmpty ? emptyNameCaption : itemName
        }
        lineItem.quantity = Int(quantityTextField.text ?? "") ?? 0
        lineItem.price = Price(value: itemPriceValue, currencyCode: lineItem.price.currencyCode)
        
        return lineItem
    }
    
    private func decimal(from priceString: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.number(from: priceString)?.decimalValue
    }

}

extension LineItemDetailsViewController: GiniTextFieldDelegate {
    
    func textDidChange(_ giniTextField: GiniTextField) {
        lineItem = lineItemFromFields()
    }
}
