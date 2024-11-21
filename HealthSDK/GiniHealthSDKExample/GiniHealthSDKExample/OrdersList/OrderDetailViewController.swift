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

final class OrderDetailViewController: UIViewController {

    private var order: Order

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

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("gini.health.example.order.detail.pay", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("gini.health.example.order.navigation.order.details", comment: "")

        view.backgroundColor = .secondarySystemBackground
        view.addSubview(detailView)
        view.addSubview(payButton)

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
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.paddingTopBottom),
            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            payButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight)
        ] + detaiViewConstraints)
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

        var text = textFields[NSLocalizedString(Fields.amountToPay.rawValue, comment: "")]?.text ?? ""
        text = text.replacingOccurrences(of: ",", with: ".")
        if let decimalAmount = Decimal(string: text) {
            var price = Price(extractionString: order.amountToPay) ?? Price(value: decimalAmount, currencyCode: "€")
            price.value = decimalAmount

            order.amountToPay = price.extractionString
        } else {
            order.amountToPay = Price(value: .zero, currencyCode: "€").extractionString
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
}

extension OrderDetailViewController: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            GiniUtilites.Log("To the banking app button was tapped,\(String(describing: event.info))", event: .success)
        case .onCloseButtonClicked:
            GiniUtilites.Log("Close screen was triggered", event: .success)
        case .onCloseKeyboardButtonClicked:
            GiniUtilites.Log("Close keyboard was triggered", event: .success)
        }
    }
}

extension OrderDetailViewController {
    enum Constants {
        static let paddingTopBottom = 8.0
        static let paddingLeadingTrailing = 16.0
        static let payButtonHeight = 50.0
        static let payButtonCornerRadius = 14.0
    }
}
