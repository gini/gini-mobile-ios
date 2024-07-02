//
//  CurrencyPickerView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

protocol CurrencyPickerViewDelegate: AnyObject {
    func currencyPickerDidPick(_ currency: String, on view: CurrencyPickerView)
}

final class CurrencyPickerView: UIView {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrencyPickerCell.self, forCellReuseIdentifier: CurrencyPickerCell.reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let currencies: [AmountCurrency] = [.CHF, .EUR, .GBP, .USD]
    weak var delegate: CurrencyPickerViewDelegate?
    var currentCurrency: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = Constants.cornerRadius
        blurEffectView.layer.masksToBounds = true
        addSubview(blurEffectView)

        layer.cornerRadius = Constants.cornerRadius

        addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(currencies.count))
        ])
    }
}

extension CurrencyPickerView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPickerCell.reuseIdentifier,
                                                    for: indexPath) as? CurrencyPickerCell {
            cell.currency = currencies[indexPath.row].rawValue
            cell.isActive = currencies[indexPath.row].rawValue == currentCurrency?.uppercased()
            return cell
        }
        assertionFailure("CurrencyPickerCell could not be reused")
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCurrency = currencies[indexPath.row].rawValue
        tableView.reloadData()
        delegate?.currencyPickerDidPick(currencies[indexPath.row].rawValue,
                                        on: self)
    }
}

extension CurrencyPickerView {
    private enum Constants {
        static let rowHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 16
    }
}
