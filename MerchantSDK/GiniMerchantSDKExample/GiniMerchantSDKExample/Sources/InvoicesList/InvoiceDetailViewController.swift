//
//  InvoiceDetailViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniMerchantSDK

final class InvoiceDetailViewController: UIViewController {

    private let invoice: DocumentWithExtractions
    private let paymentComponentsController: PaymentComponentsController
    private let giniMerchantConfiguration = GiniMerchantConfiguration.shared

    private var errors: [String] = []
    private let errorTitleText = NSLocalizedString("example.invoicesList.error", comment: "")

    init(invoice: DocumentWithExtractions, paymentComponentsController: PaymentComponentsController) {
        self.invoice = invoice
        self.paymentComponentsController = paymentComponentsController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var invoiceNumberLabel: UILabel = {
        labelTitle("Invoice number: \n\(invoice.documentID)")
    }()

    private lazy var dueDateLabel: UILabel = {
        labelTitle("Due date: \n\(invoice.paymentDueDate ?? "")")
    }()

    private lazy var amountLabel: UILabel = {
        labelTitle("Amount: \n\(invoice.amountToPay ?? "")")
    }()

    private lazy var payNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(payNowButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        paymentComponentsController.viewDelegate = self
        paymentComponentsController.bottomViewDelegate = self

        self.title = "Invoice details"

        view.backgroundColor = .white

        view.addSubview(invoiceNumberLabel)
        view.addSubview(dueDateLabel)
        view.addSubview(amountLabel)
        view.addSubview(payNowButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Invoice number label constraints
            invoiceNumberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            invoiceNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            invoiceNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Due date label constraints
            dueDateLabel.topAnchor.constraint(equalTo: invoiceNumberLabel.bottomAnchor, constant: 20),
            dueDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dueDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Amount label constraints
            amountLabel.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Pay now button constraints
            payNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            payNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payNowButton.widthAnchor.constraint(equalToConstant: 100),
            payNowButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func payNowButtonTapped() {
        let paymentViewBottomSheet = paymentComponentsController.paymentViewBottomSheet(documentID: invoice.documentID)
        paymentViewBottomSheet.modalPresentationStyle = .overFullScreen
        self.present(paymentViewBottomSheet, animated: false)
    }
}

extension InvoiceDetailViewController: PaymentComponentViewProtocol {
    func didTapOnMoreInformation(documentId: String?) {
        print("✅ Tapped on More Information")
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
        guard let documentId else { return }
        print("✅ Tapped on Bank Picker on :\(documentId)")
        let bankSelectionBottomSheet = paymentComponentsController.bankSelectionBottomSheet()
        bankSelectionBottomSheet.modalPresentationStyle = .overFullScreen
        self.dismissAndPresent(viewController: bankSelectionBottomSheet, animated: false)
    }

    func didTapOnPayInvoice(documentId: String?) {
        guard let documentId else { return }
        print("✅ Tapped on Pay Invoice on :\(documentId)")
        if giniMerchantConfiguration.showPaymentReviewScreen {
            paymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId, trackingDelegate: self) { [weak self] viewController, error in
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
                    let shareInvoiceBottomSheet = paymentComponentsController.shareInvoiceBottomSheet()
                    shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
                    self.dismissAndPresent(viewController: shareInvoiceBottomSheet, animated: false)
                } else {
                    paymentComponentsController.obtainPDFURLFromPaymentRequest(paymentInfo: obtainPaymentInfo(), viewController: self)
                }
            } else if paymentComponentsController.supportsGPC() {
                if paymentComponentsController.canOpenPaymentProviderApp() {
                    paymentComponentsController.createPaymentRequest(paymentInfo: obtainPaymentInfo()) { [weak self] paymentRequestID, error in
                        if let error {
                            self?.errors.append(error.localizedDescription)
                            self?.showErrorsIfAny()
                        } else if let paymentRequestID {
                            self?.paymentComponentsController.openPaymentProviderApp(requestId: paymentRequestID, universalLink: self?.paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "")
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

    private func obtainPaymentInfo() -> PaymentInfo {
        PaymentInfo(recipient: invoice.recipient ?? "", iban: invoice.iban ?? "", bic: "", amount: invoice.amountToPay ?? "", purpose: invoice.purpose ?? "", paymentUniversalLink: paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "", paymentProviderId: paymentComponentsController.selectedPaymentProvider?.id ?? "")
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
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
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

private extension InvoiceDetailViewController {
    func labelTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

extension InvoiceDetailViewController: GiniMerchantTrackingDelegate {
    func onPaymentReviewScreenEvent(event: GiniMerchantSDK.TrackingEvent<GiniMerchantSDK.PaymentReviewScreenEventType>) {
        //
    }
}

extension InvoiceDetailViewController: PaymentProvidersBottomViewProtocol {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider) {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.payNowButtonTapped()
            })
        }
    }

    func didTapOnClose() {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true)
        }
    }

    func didTapOnContinueOnShareBottomSheet() {
        paymentComponentsController.obtainPDFURLFromPaymentRequest(paymentInfo: obtainPaymentInfo(), viewController: self)
    }

    func didTapForwardOnInstallBottomSheet() {
        paymentComponentsController.createPaymentRequest(paymentInfo: obtainPaymentInfo()) { [weak self] paymentRequestID, error in
            if let error {
                self?.errors.append(error.localizedDescription)
                self?.showErrorsIfAny()
            } else if let paymentRequestID {
                self?.dismiss(animated: true, completion: {
                    self?.paymentComponentsController.openPaymentProviderApp(requestId: paymentRequestID, universalLink: self?.paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "")
                })
            }
        }
    }
}
