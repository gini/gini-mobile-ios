//
//  DebugMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthSDK

class DebugMenuViewController: UIViewController {
    private let giniHealth: GiniHealth
    private let giniHealthConfiguration: GiniHealthConfiguration
    private let spacing = 20.0
    private let rowHeight = 50.0
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Debug Menu"
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
    
    init(giniHealth: GiniHealth, giniHealthConfiguration: GiniHealthConfiguration) {
        self.giniHealth = giniHealth
        self.giniHealthConfiguration = giniHealthConfiguration
        super.init(nibName: nil, bundle: nil)
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
        
        if let localiztion = giniHealthConfiguration.customLocalization, let index = GiniLocalization.allCases.firstIndex(of: localiztion) {
            localizationPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let spacer = UIView()
        let mainStackView = stackView(axis: .vertical, subviews: [titleLabel, localizationRow, spacer])
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -spacing),
            
            localizationRow.heightAnchor.constraint(equalToConstant: rowHeight)
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
}

extension DebugMenuViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GiniLocalization.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GiniLocalization.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        giniHealthConfiguration.customLocalization = GiniLocalization.allCases[row]
        giniHealth.setConfiguration(giniHealthConfiguration)
    }
}
