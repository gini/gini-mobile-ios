//
//  DebugMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol DebugMenuDelegate: AnyObject {
    func didChangeReviewScreenSwitchValue(isOn: Bool)
    func didChangeAmountEditableSwitchValue(isOn: Bool)
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

    weak var delegate: DebugMenuDelegate?

    init(showReviewScreen: Bool, isAmountFieldEditable: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.reviewScreenSwitch = self.switchView(isOn: showReviewScreen)
        self.amountEditableSwitch = self.switchView(isOn: isAmountFieldEditable)
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
        let mainStackView = stackView(axis: .vertical, subviews: [titleLabel, reviewScreenRow, amountEditableRow, spacer])
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -spacing),

            reviewScreenRow.heightAnchor.constraint(equalToConstant: rowHeight),
            amountEditableRow.heightAnchor.constraint(equalToConstant: rowHeight)
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
        if sender == reviewScreenSwitch {
            delegate?.didChangeReviewScreenSwitchValue(isOn: sender.isOn)
            amountEditableSwitch.isOn = sender.isOn
            delegate?.didChangeAmountEditableSwitchValue(isOn: sender.isOn)
        } else if sender == amountEditableSwitch {
            delegate?.didChangeAmountEditableSwitchValue(isOn: sender.isOn)
        }
    }
}