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
let kQuantityLimit = 99999
let kMaxQuantityCharacters = 5

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
    
    var shouldEnableSaveButton : Bool? {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = shouldEnableSaveButton ?? true
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
    private let totalPriceVatStackView = UIStackView()
    private let totalPriceTitleLabel = UILabel()
    private let totalPriceLabel = UILabel()
    private let includeVatTitleLabel : UILabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .ginibankLocalized(
                resource: DigitalInvoiceStrings.lineItemSaveButtonTitle
            ),
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = shouldEnableSaveButton ?? true
        setupView()
        update()
        let configuration  = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        view.backgroundColor = UIColor.from(giniColor: configuration.lineItemDetailsBackgroundColor
        )
    }
    
    private func setupView() {
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        stackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButtonTextLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameTextField.translatesAutoresizingMaskIntoConstraints = false
        quantityAndItemPriceContainer.translatesAutoresizingMaskIntoConstraints = false
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        multiplicationLabel.translatesAutoresizingMaskIntoConstraints = false
        itemPriceTextField.translatesAutoresizingMaskIntoConstraints = false

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

        checkboxContainerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                            constant: margin - CheckboxButton.margin).isActive = true
        checkboxContainerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: margin - CheckboxButton.margin).isActive = true
        checkboxContainerStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -margin).isActive = true

        view.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: checkboxContainerStackView.bottomAnchor,
                                       constant: margin - CheckboxButton.margin).isActive = true

        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                           constant: margin).isActive = true

        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                            constant: -margin).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                          constant: -margin).isActive = true

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
        quantityTextField.textFieldType = .quantityFieldTag
        quantityTextField.keyboardType = .numberPad
        quantityTextField.delegate = self
        
        quantityAndItemPriceContainer.addSubview(quantityTextField)
        
        itemPriceTextField.titleFont = configuration.lineItemDetailsDescriptionLabelFont
        itemPriceTextField.titleTextColor = configuration.lineItemDetailsDescriptionLabelColor
        itemPriceTextField.title = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemPriceTextFieldTitle)
        itemPriceTextField.textFont = configuration.lineItemDetailsContentLabelFont
        itemPriceTextField.textColor = configuration.lineItemDetailsContentLabelColor
        itemPriceTextField.underscoreColor = configuration.lineItemDetailsContentHighlightedColor
        
        itemPriceTextField.keyboardType = .decimalPad
        itemPriceTextField.delegate = self
        itemPriceTextField.textFieldType = .amountFieldTag
        quantityAndItemPriceContainer.addSubview(itemPriceTextField)
        
        quantityTextField.leadingAnchor.constraint(equalTo: quantityAndItemPriceContainer.leadingAnchor).isActive = true
        quantityTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        quantityTextField.trailingAnchor.constraint(equalTo: itemPriceTextField.leadingAnchor,
                                                    constant: -margin).isActive = true
        quantityTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        quantityTextField.widthAnchor.constraint(equalTo: itemPriceTextField.widthAnchor, multiplier: 1.0).isActive = true
        itemPriceTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        itemPriceTextField.trailingAnchor.constraint(equalTo: quantityAndItemPriceContainer.trailingAnchor)
            .isActive = true
        itemPriceTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(quantityAndItemPriceContainer)
        self.setupTotalPrice(configuration: configuration)
        totalPriceStackView.addArrangedSubview(totalPriceLabel)
        totalPriceVatStackView.addArrangedSubview(includeVatTitleLabel)
        totalPriceVatStackView.addArrangedSubview(totalPriceStackView)
        stackView.addArrangedSubview(totalPriceVatStackView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(gestureRecognizer)
     
        accessibilityElements = [checkboxContainerStackView,
                                 itemNameTextField,
                                 quantityTextField,
                                 multiplicationLabel,
                                 itemPriceTextField,
                                 totalPriceTitleLabel,
                                 totalPriceLabel]
        
    }

    private func setupTotalPrice(
        configuration: ReturnAssistantConfiguration
    ) {
        totalPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        totalPriceVatStackView.translatesAutoresizingMaskIntoConstraints = false
        totalPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        includeVatTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceStackView.distribution = .fill
        totalPriceStackView.axis = .horizontal
        totalPriceStackView.spacing = 16
        totalPriceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        totalPriceTitleLabel.font = configuration.lineItemDetailsDescriptionLabelFont
        totalPriceTitleLabel.textColor = configuration.lineItemDetailsContentLabelColor
        totalPriceTitleLabel.text = .ginibankLocalized(
            resource: DigitalInvoiceStrings.lineItemTotalPriceTitle
        )
        totalPriceTitleLabel.font = configuration.lineItemDetailsTotalPriceMainUnitFont
        totalPriceStackView.addArrangedSubview(totalPriceTitleLabel)
        totalPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.setupVatTitleView(configuration: configuration)
        totalPriceVatStackView.axis = .vertical
        totalPriceVatStackView.spacing = 0
        totalPriceVatStackView.addArrangedSubview(includeVatTitleLabel)
        totalPriceVatStackView.addArrangedSubview(totalPriceStackView)
    }

    private func setupVatTitleView(
        configuration: ReturnAssistantConfiguration
    ) {
        includeVatTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        includeVatTitleLabel.textAlignment = .right
        includeVatTitleLabel.textColor =
        configuration.lineItemDetailsDescriptionLabelColor
        includeVatTitleLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemIncludeVatTitle)
        includeVatTitleLabel.font = configuration.lineItemDetailsDescriptionLabelFont
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
    
    fileprivate func presentReturnReasonActionSheet(source: UIView, with returnReasons: [ReturnReason]) {
        DeselectLineItemActionSheet().present(from: self, source: source, returnReasons: returnReasons) { selectedState in
            switch selectedState {
            case .selected:
                break
            case .deselected(let reason):
                self.lineItem?.selectedState = .deselected(reason: reason)
            }
        }
    }
    
    private func updateItemState(isEnabled: Bool) {
        var color: UIColor
        if isEnabled {
            color = returnAssistantConfiguration?.lineItemDetailsContentLabelColor ?? UIColor.black
        } else {
            self.view.endEditing(true)
            color = returnAssistantConfiguration?.digitalInvoiceLineItemsDisabledColor ?? UIColor.lightGray
        }
        totalPriceLabel.textColor = color
        totalPriceTitleLabel.textColor = color
        
        itemNameTextField.setupState(
            isEnabled: isEnabled,
            color: color)
        itemPriceTextField.setupState(
            isEnabled: isEnabled,
            color: color)
        itemNameTextField.setupState(
            isEnabled: isEnabled,
            color: color)
        quantityTextField.setupState(
            isEnabled: isEnabled,
            color: color)
        if let lineItem = lineItem, let totalPriceString = lineItem.totalPrice.string {
            let configuration  = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
            let attributedString =
                NSMutableAttributedString(string: totalPriceString,
                                          attributes: [NSAttributedString.Key.foregroundColor: color,
                                                       NSAttributedString.Key.font: configuration.lineItemDetailsTotalPriceMainUnitFont])
            
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color,
                                            NSAttributedString.Key.baselineOffset: 5,
                                            NSAttributedString.Key.font: configuration.lineItemDetailsTotalPriceFractionalUnitFont],
                                           range: NSRange(location: totalPriceString.count - 3, length: 3))
            
            totalPriceLabel.attributedText = attributedString
        }
    }
    
    @objc func checkboxButtonTapped() {
        guard let lineItem = lineItem else { return }
        switch lineItem.selectedState {
        case .deselected:
            self.lineItem?.selectedState = .selected
            
        case .selected:
            if let returnReasons = returnReasons, let configuration = returnAssistantConfiguration, configuration.enableReturnReasons {
                presentReturnReasonActionSheet(source: checkboxButton, with: returnReasons)
            } else {
                self.lineItem?.selectedState = .deselected(reason: nil)
                return
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
            updateItemState(isEnabled: true)
        case .deselected:
            checkboxButton.checkedState = .unchecked
            updateItemState(isEnabled: false)
        }
    }
}

extension LineItemDetailsViewController {
    
    private func quantityForLineItem(quantityString: String) -> Int {
        let quantity = Int(quantityString) ?? 0
        if quantity > 0 {
            if quantity > kQuantityLimit {
                return kQuantityLimit
            } else {
                return quantity
            }
        } else {
            return 1
        }
    }
    
    private func lineItemFromFields() -> DigitalInvoice.LineItem? {
        let lineItemMaximumAllowedValue = Decimal(25000)
        
        guard var lineItem = lineItem else { return nil }
        guard let priceValue = decimal(from: itemPriceTextField.text ?? "0") else { return nil }
        shouldEnableSaveButton = priceValue > 0
        
        var itemPriceValue = priceValue
        
        if itemPriceValue > lineItemMaximumAllowedValue {
            itemPriceValue = lineItemMaximumAllowedValue
        }
        if let itemName = itemNameTextField.text {
            let emptyNameCaption: String = .ginibankLocalized(resource: DigitalInvoiceStrings.noTitleArticle)
            lineItem.name = itemName.isEmpty ? emptyNameCaption : itemName
        }
        
        let quantity = quantityForLineItem(quantityString: quantityTextField.text ?? "")
        if quantity == 1 || quantity == kQuantityLimit {
            // we need to update textfield because the quantity was changed due to the limitations
            quantityTextField.text = "\(quantity)"
        }
        lineItem.quantity = quantity
        lineItem.price = Price(value: itemPriceValue, currencyCode: lineItem.price.currencyCode)
        
        return lineItem
    }
    
    private func decimal(from priceString: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.currencySymbol = ""
        return formatter.number(from: priceString)?.decimalValue
    }

}

extension LineItemDetailsViewController: GiniTextFieldDelegate {
    func textFieldWillChangeCharacters(_ giniTextField: GiniTextField) {
        if let amountText = giniTextField.text, let decimal = decimal(from: amountText){
            shouldEnableSaveButton = !amountText.isEmpty && (decimal > 0)
        }
    }
    
    func textWillClear(_ giniTextField: GiniTextField) {
        shouldEnableSaveButton = false
    }
    
    func textDidChange(_ giniTextField: GiniTextField) {
        lineItem = lineItemFromFields()
        shouldEnableSaveButton = (lineItem?.price.value)! > 0
    }
}
