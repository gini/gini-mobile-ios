//
//  OrderDetailViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import UIKit
import GiniInternalPaymentSDK
import GiniUtilites
import GiniHealthSDK

enum Fields: String, CaseIterable {
    case recipient = "gini.health.example.order.detail.recipient"
    case iban = "gini.health.example.order.detail.iban"
    case amountToPay = "gini.health.example.order.detail.amount"
    case purpose = "gini.health.example.order.detail.purpose"
}

protocol OrderDetailViewControllerDelegate: AnyObject {
    func didUpdateOrder(_ order: Order)
}

final class OrderDetailViewController: UIViewController {

    private var order: Order
    weak var delegate: OrderDetailViewControllerDelegate?

    private let health: GiniHealth
    private let giniHealthConfiguration = GiniHealthConfiguration.shared

    private var errors: [String] = []
    private let errorTitleText = NSLocalizedString("gini.health.example.invoicesList.error", comment: "")

    private var rowItems: [(String, String)] {
        [(Fields.recipient.rawValue, order.recipient),
         (Fields.iban.rawValue, order.iban),
         (Fields.amountToPay.rawValue, order.amountToPay),
         (Fields.purpose.rawValue, order.purpose)].map {
            (NSLocalizedString($0, comment: ""), $1)
        }
    }

    private var detaiViewConstraints: [NSLayoutConstraint] { [
        detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingTopBottom),
        detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingLeadingTrailing),
        detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingLeadingTrailing)]
    }

    init(_ order: Order, health: GiniHealth) {
        self.order = order
        self.health = health
        super.init(nibName: nil, bundle: nil)

        detailView.order = order

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnView)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var detailView: OrderDetailView = {
        OrderDetailView(rowItems)
    }()

    private var paymentExpirationDate: Date? {
        get { order.expirationDate }
        set {
            order.expirationDate = newValue
            updateExpirationLabel()
            updateOrderDetails(newOrder: order)
        }
    }

    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.expirationLabelFontSize, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.buttonStackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var createPaymentRequestButton: UIButton = createButton(title: "Create Payment Request", action: #selector(createPaymentRequestTapped))

    private lazy var payButton: UIButton = createButton(title: "Pay", action: #selector(payButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("gini.health.example.order.navigation.order.details", comment: "")

        view.backgroundColor = .secondarySystemBackground
        view.addSubview(detailView)
        view.addSubview(expirationLabel)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(createPaymentRequestButton)
        view.addSubview(payButton)

        updateExpirationLabel()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 14.0, *) {
            navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTextFieldData()
    }

    public func setAmount(_ amount: String) {
        order.amountToPay = amount

        detailView.removeFromSuperview()
        detailView = OrderDetailView(rowItems)
        detailView.order = order
        view.addSubview(detailView)

        NSLayoutConstraint.activate(detaiViewConstraints)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: Constants.expirationLabelTopPadding),
            expirationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonStackView.topAnchor.constraint(equalTo: expirationLabel.bottomAnchor, constant: Constants.buttonStackTopPadding),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonStackLeadingTrailingPadding),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonStackLeadingTrailingPadding),
            buttonStackView.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight),

            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.paddingTopBottom),
            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            payButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight)
        ] + detaiViewConstraints)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func payButtonTapped() {
        GiniUtilites.Log("Tapped on Pay", event: .success)
        view.endEditing(true)

        let paymentInfo = obtainPaymentInfo()
        if paymentInfo.isComplete && order.price.value != .zero {
            guard let navigationController else { return }
            health.startPaymentFlow(documentId: nil, paymentInfo: obtainPaymentInfo(), navigationController: navigationController, trackingDelegate: self)
        } else {
            showErrorAlertView(error: NSLocalizedString("gini.health.example.order.detail.alert.field.error", comment: ""))
        }
    }

    @objc private func didTapOnView() {
        view.endEditing(true)
    }

    private func saveTextFieldData() {
        let textFields = OrderDetailView.textFields
        order.iban = textFields[NSLocalizedString(Fields.iban.rawValue, comment: "")]?.text ?? ""
        order.recipient = textFields[NSLocalizedString(Fields.recipient.rawValue, comment: "")]?.text ?? ""
        order.purpose = textFields[NSLocalizedString(Fields.purpose.rawValue, comment: "")]?.text ?? ""

        let text = textFields[NSLocalizedString(Fields.amountToPay.rawValue, comment: "")]?.text ?? ""
        if let priceValue = text.decimal() {
            let price = Price(value: priceValue, currencyCode: "€")
            if priceValue > 0 {
                order.amountToPay = price.extractionString
            } else {
                order.amountToPay = Price(value: .zero, currencyCode: "€").extractionString
            }
        }
    }

    private func obtainPaymentInfo() -> GiniHealthSDK.PaymentInfo {
        saveTextFieldData()

        return PaymentInfo(recipient: order.recipient,
                           iban: order.iban,
                           bic: "",
                           amount: order.amountToPay,
                           purpose: order.purpose,
                           paymentUniversalLink: health.paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "",
                           paymentProviderId: health.paymentComponentsController.selectedPaymentProvider?.id ?? "")
    }

    private func showErrorsIfAny() {
        if !errors.isEmpty {
            let uniqueErrorMessages = Array(Set(errors))
            DispatchQueue.main.async {
                self.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
            }
            errors = []
        }
    }

    private func showErrorAlertView(error: String) {
        let alertController = UIAlertController(title: errorTitleText,
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("gini.health.example.order.detail.alert.ok", comment: ""),
                          style: .default)
        )
        self.present(alertController, animated: true)
    }

    private func updateExpirationLabel() {
        guard let expirationDate = paymentExpirationDate else {
            expirationLabel.isHidden = true
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        expirationLabel.text = "Expires: " + dateFormatter.string(from: expirationDate)
        expirationLabel.textColor = expirationDate > Date() ? .systemGreen : .systemRed
        expirationLabel.isHidden = false
    }

    func updateOrderDetails(newOrder: Order) {
        delegate?.didUpdateOrder(newOrder)
    }

    @objc private func createPaymentRequestTapped() {
        let paymentInfo = GiniInternalPaymentSDK.PaymentInfo(paymentComponentsInfo: obtainPaymentInfo())
        health.createPaymentRequest(paymentInfo: paymentInfo) { [weak self] result in
            switch result {
            case .success(let success):
                self?.health.getPaymentRequest(by: success, completion: { [weak self] paymentRequestResult in
                    switch paymentRequestResult {
                    case .success(let paymentRequest):
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                        guard let expirationDateString = paymentRequest.expirationDate, let expirationDate = dateFormatter.date(from: expirationDateString) else { return }
                        self?.paymentExpirationDate = expirationDate
                        self?.order.id = success
                    case .failure(let error):
                        self?.errors.append(error.localizedDescription)
                        self?.showErrorsIfAny()
                    }
                })
            case .failure(let error):
                self?.errors.append(error.localizedDescription)
                self?.showErrorsIfAny()
            }
        }
    }
}

extension OrderDetailViewController: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            GiniUtilites.Log("To the banking app button was tapped,\(String(describing: event.info))", event: .success)
        case .onCloseKeyboardButtonClicked:
            GiniUtilites.Log("Close keyboard was triggered", event: .success)
        case .onCloseButtonClicked:
            GiniUtilites.Log("Close button was tapped", event: .success)
        }
    }
}

extension OrderDetailViewController {
    enum Constants {
        static let paddingTopBottom = 8.0
        static let paddingLeadingTrailing = 16.0
        static let payButtonHeight = 50.0
        static let payButtonCornerRadius = 14.0
        static let expirationLabelTopPadding = 10.0
        static let buttonStackTopPadding = 10.0
        static let buttonStackLeadingTrailingPadding = 16.0
        static let payButtonTopPadding = 20.0
        static let buttonStackSpacing = 10.0
        static let expirationLabelFontSize = 14.0
    }
}
