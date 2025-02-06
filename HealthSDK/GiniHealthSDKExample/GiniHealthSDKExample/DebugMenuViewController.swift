//
//  DebugMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthSDK
import GiniInternalPaymentSDK
import GiniUtilites

enum SwitchType {
    case showReviewScreen
    case showBrandedView
    case useBottomPaymentComponent
    case showPaymentCloseButton
}

protocol DebugMenuDelegate: AnyObject {
    func didChangeSwitchValue(type: SwitchType, isOn: Bool)
    func didPickNewLocalization(localization: GiniLocalization)
    func didPickNewIngredientBrandType(brandType: IngredientBrandTypeEnum)
}

class DebugMenuViewController: UIViewController {
    private let spacing = 20.0
    private let rowHeight = 50.0

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gini Health"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()

    private lazy var localizationTitleLabel: UILabel = rowTitle("Localization")

    private lazy var localizationPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var localizationRow: UIStackView = stackView(axis: .horizontal, subviews: [localizationTitleLabel, localizationPicker])

    private lazy var reviewScreenOptionLabel: UILabel = rowTitle("Show Review Screen")
    private var reviewScreenSwitch: UISwitch!
    private lazy var reviewScreenRow: UIStackView = stackView(axis: .horizontal, subviews: [reviewScreenOptionLabel, reviewScreenSwitch])

    private lazy var brandedTitleLabel: UILabel = rowTitle("Ingredient Brand")

    private lazy var brandedPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var brandedRow: UIStackView = stackView(axis: .horizontal, subviews: [brandedTitleLabel, brandedPicker])

    private lazy var bottomPaymentComponentOptionLabel: UILabel = rowTitle("Use bottom payment component")
    private var bottomPaymentComponentSwitch: UISwitch!
    private lazy var bottomPaymentComponentEditableRow: UIStackView = stackView(axis: .horizontal, subviews: [bottomPaymentComponentOptionLabel, bottomPaymentComponentSwitch])

    private lazy var closeButtonOptionLabel: UILabel = rowTitle("Show Payment Review Close Button")
    private var closeButtonSwitch: UISwitch!
    private lazy var closeButtonRow: UIStackView = stackView(axis: .horizontal, subviews: [closeButtonOptionLabel, closeButtonSwitch])

    weak var delegate: DebugMenuDelegate?

    init(showReviewScreen: Bool,
         useBottomPaymentComponent: Bool,
         paymentComponentConfiguration: PaymentComponentConfiguration,
         showPaymentCloseButton: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.reviewScreenSwitch = self.switchView(isOn: showReviewScreen)
        self.bottomPaymentComponentSwitch = self.switchView(isOn: useBottomPaymentComponent)
        self.closeButtonSwitch = self.switchView(isOn: showPaymentCloseButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let localization = GiniHealthConfiguration.shared.customLocalization, let index = GiniLocalization.allCases.firstIndex(of: localization) {
            localizationPicker.selectRow(index, inComponent: 0, animated: true)
        }
        
        if let ingredientType = GiniHealthConfiguration.shared.clientConfiguration?.ingredientBrandType?.toHealthIngredientBrandType(), let index = GiniUtilites.IngredientBrandTypeEnum.allCases.firstIndex(of: ingredientType) {
            brandedPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")

        let spacer = UIView()
        let mainStackView = stackView(axis: .vertical, subviews: [titleLabel, localizationRow, reviewScreenRow, brandedRow, bottomPaymentComponentEditableRow, closeButtonRow, spacer])
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -spacing),

            brandedPicker.widthAnchor.constraint(equalToConstant: view.frame.width/2),
            localizationRow.heightAnchor.constraint(equalToConstant: rowHeight),
            reviewScreenRow.heightAnchor.constraint(equalToConstant: rowHeight),
            brandedRow.heightAnchor.constraint(equalToConstant: rowHeight),
            bottomPaymentComponentEditableRow.heightAnchor.constraint(equalToConstant: rowHeight),
            closeButtonRow.heightAnchor.constraint(equalToConstant: rowHeight)
        ])
    }
}

private extension DebugMenuViewController {
    func rowTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        return label
    }

    func stackView(axis: NSLayoutConstraint.Axis, subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }

    func switchView(isOn: Bool) -> UISwitch {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        mySwitch.isOn = isOn
        return mySwitch
    }
}

extension DebugMenuViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case localizationPicker:
            return GiniLocalization.allCases.count
        case brandedPicker:
            return IngredientBrandTypeEnum.allCases.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case localizationPicker:
            return GiniLocalization.allCases[row].rawValue
        case brandedPicker:
            return IngredientBrandTypeEnum.allCases[row].rawValue
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case localizationPicker:
            delegate?.didPickNewLocalization(localization: GiniLocalization.allCases[row])
        case brandedPicker:
            delegate?.didPickNewIngredientBrandType(brandType: IngredientBrandTypeEnum.allCases[row])
        default:
            break
        }
    }
}

// MARK: Switch functions
private extension DebugMenuViewController {
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switch sender {
            case reviewScreenSwitch:
                delegate?.didChangeSwitchValue(type: .showReviewScreen, isOn: sender.isOn)
            case bottomPaymentComponentSwitch:
                delegate?.didChangeSwitchValue(type: .useBottomPaymentComponent, isOn: sender.isOn)
            case closeButtonSwitch:
                delegate?.didChangeSwitchValue(type: .showPaymentCloseButton, isOn: sender.isOn)
            default:
                break
        }
    }
}
