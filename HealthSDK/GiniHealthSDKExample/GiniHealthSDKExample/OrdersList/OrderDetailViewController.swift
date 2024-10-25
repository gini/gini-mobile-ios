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
    case recipient = "giniHealthSDKExample.order.detail.Recipient"
    case iban = "giniHealthSDKExample.order.detail.IBAN"
    case amountToPay = "giniHealthSDKExample.order.detail.Amount"
    case purpose = "giniHealthSDKExample.order.detail.Purpose"
}

final class OrderDetailViewController: UIViewController {

    private var order: Order

    private let paymentComponentsController: PaymentComponentsController
    private let giniHealthConfiguration = GiniHealthConfiguration.shared

    private var errors: [String] = []
    private let errorTitleText = NSLocalizedString("giniHealthSDKExample.invoicesList.error", comment: "")

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

    init(_ order: Order, paymentComponentsController: PaymentComponentsController) {
        self.order = order
        self.paymentComponentsController = paymentComponentsController
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
        button.setTitle(NSLocalizedString("giniHealthSDKExample.order.detail.Pay", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        paymentComponentsController.viewDelegate = self
        paymentComponentsController.bottomViewDelegate = self

        title = NSLocalizedString("giniHealthSDKExample.order.navigation.orderdetails", comment: "")

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
            if giniHealthConfiguration.showPaymentReviewScreen {
                paymentComponentsController.loadPaymentReviewScreenFor(documentId: "", paymentInfo: obtainPaymentInfo(), trackingDelegate: self) { [weak self] viewController, error in
                    if let error {
                        self?.errors.append(error.localizedDescription)
                        self?.showErrorsIfAny()
                    } else if let viewController {
                        viewController.modalTransitionStyle = .coverVertical
                        viewController.modalPresentationStyle = .overCurrentContext
                        self?.dismissAndPresent(viewController: viewController, animated: true)
                    }
                }
            } else {
                self.presentPaymentViewBottomSheet(nil)
            }
        } else {
            showErrorAlertView(error: NSLocalizedString("giniHealthSDKExample.order.detail.Alert.FieldError", comment: ""))
        }
    }

    @objc private func didTapOnView() {
        view.endEditing(true)
    }

    fileprivate func presentPaymentViewBottomSheet(_ documentId: String?) {
        let paymentViewBottomSheet = paymentComponentsController.paymentViewBottomSheet(documentId: documentId ?? "")
        paymentViewBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: paymentViewBottomSheet, animated: false)
    }
}

extension OrderDetailViewController: GiniInternalPaymentSDK.PaymentComponentViewProtocol {
    func didTapOnMoreInformation(documentId: String?) {
        GiniUtilites.Log("Tapped on More Information", event: .success)
        let paymentInfoViewController = paymentComponentsController.paymentInfoViewController()
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                self.navigationController?.pushViewController(paymentInfoViewController, animated: true)
            }
        } else {
            self.navigationController?.pushViewController(paymentInfoViewController, animated: true)
        }
    }

    func didTapOnBankPicker(documentId: String?) {
        GiniUtilites.Log("Tapped on Bank Picker on :\(documentId ?? "")", event: .success)
        let bankSelectionBottomSheet = paymentComponentsController.bankSelectionBottomSheet(documentId: documentId)
        bankSelectionBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: bankSelectionBottomSheet, animated: false)
    }

    func didTapOnPayInvoice(documentId: String?) {
        GiniUtilites.Log("Tapped on Pay Order", event: .success)
        if giniHealthConfiguration.showPaymentReviewScreen {
            paymentComponentsController.loadPaymentReviewScreenFor(documentId: documentId, paymentInfo: obtainPaymentInfo(), trackingDelegate: self) { [weak self] viewController, error in
                if let error {
                    self?.errors.append(error.localizedDescription)
                    self?.showErrorsIfAny()
                } else if let viewController {
                    viewController.modalTransitionStyle = .coverVertical
                    viewController.modalPresentationStyle = .overCurrentContext
                    self?.dismissAndPresent(viewController: viewController, animated: true)
                }
            }
        } else {
            if paymentComponentsController.supportsOpenWith() {
                if paymentComponentsController.shouldShowOnboardingScreenFor() {
                    let shareInvoiceBottomSheet = paymentComponentsController.shareInvoiceBottomSheet(documentId: documentId)
                    shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
                    self.dismissAndPresent(viewController: shareInvoiceBottomSheet, animated: false)
                } else {
                    paymentComponentsController.obtainPDFURLFromPaymentRequest(paymentInfo: obtainPaymentInfo(), viewController: self)
                }
            } else if paymentComponentsController.supportsGPC() {
                if paymentComponentsController.canOpenPaymentProviderApp() {
                    paymentComponentsController.createPaymentRequest(paymentInfo: obtainPaymentInfo()) { [weak self] result in
                        switch result {
                        case .success(let paymentRequestID):
                            self?.paymentComponentsController.openPaymentProviderApp(requestId: paymentRequestID, universalLink: self?.paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "")
                        case .failure(let error):
                            self?.errors.append(error.localizedDescription)
                            self?.showErrorsIfAny()
                        }
                    }
                } else {
                    let installAppBottomSheet = paymentComponentsController.installAppBottomSheet()
                    installAppBottomSheet.modalPresentationStyle = .overFullScreen
                    self.dismissAndPresent(viewController: installAppBottomSheet, animated: false)
                }
            }
        }
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

    private func obtainPaymentInfo() -> PaymentInfo {
        saveTextFieldData()

        return PaymentInfo(recipient: order.recipient,
                           iban: order.iban,
                           bic: "",
                           amount: order.amountToPay,
                           purpose: order.purpose,
                           paymentUniversalLink: paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "",
                           paymentProviderId: paymentComponentsController.selectedPaymentProvider?.id ?? "")
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
            UIAlertAction(title: NSLocalizedString("giniHealthSDKExample.order.detail.Alert.Ok", comment: ""),
                          style: .default)
        )
        self.present(alertController, animated: true)
    }

    private func dismissAndPresent(viewController: UIViewController, animated: Bool) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                self.present(viewController, animated: animated)
            }
        } else {
            self.present(viewController, animated: animated)
        }
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

extension OrderDetailViewController: PaymentProvidersBottomViewProtocol {
    func didSelectPaymentProvider(paymentProvider: GiniHealthSDK.PaymentProvider, documentId: String?) {
        DispatchQueue.main.async {
            self.presentPaymentViewBottomSheet(documentId)
        }
    }
    
    func didTapOnMoreInformation() {
        didTapOnMoreInformation(documentId: nil)
    }

    func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.payButtonTapped()
            })
        }
    }

    func didTapOnClose() {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true)
        }
    }

    func didTapOnContinueOnShareBottomSheet(documentId: String?) {
        paymentComponentsController.obtainPDFURLFromPaymentRequest(paymentInfo: obtainPaymentInfo(), viewController: self)
    }

    func didTapForwardOnInstallBottomSheet() {
        paymentComponentsController.createPaymentRequest(paymentInfo: obtainPaymentInfo()) { [weak self] result in
            switch result {
            case .success(let paymentRequestID):
                self?.dismiss(animated: true, completion: {
                    self?.paymentComponentsController.openPaymentProviderApp(requestId: paymentRequestID, universalLink: self?.paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "")
                })
            case .failure(let error):
                self?.errors.append(error.localizedDescription)
            }
        }
    }

    func didTapOnPayButton() {
        payButtonTapped()
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
