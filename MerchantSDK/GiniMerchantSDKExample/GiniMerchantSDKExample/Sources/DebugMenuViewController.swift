//
//  DebugMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniMerchantSDK

enum SwitchType {
    case showReviewScreen
    case amountEditable
    case showBrandedView
    case showPaymentComponentInOneRow
    case hideInfoForReturningUser
}

protocol DebugMenuDelegate: AnyObject {
    func didChangeSwitchValue(type: SwitchType, isOn: Bool)
}

class DebugMenuViewController: UIViewController {
    private let spacing = 20.0
    private let rowHeight = 50.0

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gini Merchant"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()

    private lazy var reviewScreenOptionLabel: UILabel = rowTitle("Show Review Screen")
    private var reviewScreenSwitch: UISwitch!
    private lazy var reviewScreenRow: UIStackView = stackView(axis: .horizontal, subviews: [reviewScreenOptionLabel, reviewScreenSwitch])

    private lazy var amountEditableOptionLabel: UILabel = rowTitle("Amount field is editable")
    private var amountEditableSwitch: UISwitch!
    private lazy var amountEditableRow: UIStackView = stackView(axis: .horizontal, subviews: [amountEditableOptionLabel, amountEditableSwitch])

    private lazy var brandedOptionLabel: UILabel = rowTitle("Show Branded View")
    private var brandedSwitch: UISwitch!
    private lazy var brandedEditableRow: UIStackView = stackView(axis: .horizontal, subviews: [brandedOptionLabel, brandedSwitch])

    private lazy var showPaymentComponentOneRowLabel: UILabel = rowTitle("Show Payment Component 1 row")
    private var showPaymentComponentOneRowSwitch: UISwitch!
    private lazy var showPaymentComponentOneRow: UIStackView = stackView(axis: .horizontal, subviews: [showPaymentComponentOneRowLabel, showPaymentComponentOneRowSwitch])

    private lazy var hideInfoReturningUserLabel: UILabel = rowTitle("Hide info on returning user")
    private var hideInfoReturningUserSwitch: UISwitch!
    private lazy var hideInfoReturningUserRow: UIStackView = stackView(axis: .horizontal, subviews: [hideInfoReturningUserLabel, hideInfoReturningUserSwitch])

    weak var delegate: DebugMenuDelegate?

    init(showReviewScreen: Bool, isAmountFieldEditable: Bool, paymentComponentConfiguration: PaymentComponentConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.reviewScreenSwitch = self.switchView(isOn: showReviewScreen)
        self.amountEditableSwitch = self.switchView(isOn: isAmountFieldEditable)
        self.brandedSwitch = self.switchView(isOn: paymentComponentConfiguration.isPaymentComponentBranded)
        self.showPaymentComponentOneRowSwitch = self.switchView(isOn: paymentComponentConfiguration.showPaymentComponentInOneRow)
        self.hideInfoReturningUserSwitch = self.switchView(isOn: paymentComponentConfiguration.hideInfoForReturningUser)
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
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")

        let spacer = UIView()
        let mainStackView = stackView(axis: .vertical, subviews: [titleLabel, reviewScreenRow, amountEditableRow, brandedEditableRow, showPaymentComponentOneRow, hideInfoReturningUserRow, spacer])
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -spacing),

            reviewScreenRow.heightAnchor.constraint(equalToConstant: rowHeight),
            amountEditableRow.heightAnchor.constraint(equalToConstant: rowHeight),
            brandedEditableRow.heightAnchor.constraint(equalToConstant: rowHeight),
            showPaymentComponentOneRow.heightAnchor.constraint(equalToConstant: rowHeight),
            hideInfoReturningUserRow.heightAnchor.constraint(equalToConstant: rowHeight)
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

// MARK: Switch functions
private extension DebugMenuViewController {
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switch sender {
            case reviewScreenSwitch:
                delegate?.didChangeSwitchValue(type: .showReviewScreen, isOn: sender.isOn)
                amountEditableSwitch.isOn = sender.isOn
                delegate?.didChangeSwitchValue(type: .amountEditable, isOn: sender.isOn)
            case amountEditableSwitch:
                delegate?.didChangeSwitchValue(type: .amountEditable, isOn: sender.isOn)
            case brandedSwitch:
                delegate?.didChangeSwitchValue(type: .showBrandedView, isOn: sender.isOn)
            case showPaymentComponentOneRowSwitch:
                delegate?.didChangeSwitchValue(type: .showPaymentComponentInOneRow, isOn: sender.isOn)
            case hideInfoReturningUserSwitch:
                delegate?.didChangeSwitchValue(type: .hideInfoForReturningUser, isOn: sender.isOn)
            default:
                break
        }
    }
}
