//
//  InvoiceDetailViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniMerchantSDK

fileprivate enum Fields: String, CaseIterable {
    case recipient = "Recipient"
    case iban = "IBAN"
    case amountToPay = "Amount"
    case purpose = "Purpose"

    static func all(from document: DocumentWithExtractions) ->  [(String, String)] {
        var array = [(String, String)]()

        if let recipient = document.recipient {
            array.append((Self.recipient.rawValue, recipient))
        }
        if let iban = document.iban {
            array.append((Self.iban.rawValue, iban))
        }
        if let amountToPay = document.amountToPay {
            array.append((Self.amountToPay.rawValue, amountToPay))
        }
        if let purpose = document.purpose {
            array.append((Self.purpose.rawValue, purpose))
        }

        return array
    }
}

final class InvoiceDetailViewController: UIViewController {

    private var invoice: DocumentWithExtractions
    private let paymentComponentsController: PaymentComponentsController
    private let giniMerchantConfiguration = GiniMerchantConfiguration.shared

    private var errors: [String] = []
    private let errorTitleText = NSLocalizedString("example.invoicesList.error", comment: "")
    
    private var items: [(String, String)] {
        var items = [(FieldTitle.documentID.rawValue, invoice.documentID)]
        if let recipient = invoice.recipient { items.append((FieldTitle.recipient.rawValue, recipient)) }
        if let iban = invoice.iban { items.append((FieldTitle.iban.rawValue, iban)) }
        if let amountToPay = invoice.amountToPay { items.append((FieldTitle.amountToPay.rawValue, amountToPay)) }
        if let purpose = invoice.purpose { items.append((FieldTitle.purpose.rawValue, purpose)) }
        if let dueDate = invoice.paymentDueDate { items.append((FieldTitle.paymentDueDate.rawValue, dueDate)) }

        return items
    }

    init(invoice: DocumentWithExtractions, paymentComponentsController: PaymentComponentsController) {
        self.invoice = invoice
        self.paymentComponentsController = paymentComponentsController
        super.init(nibName: nil, bundle: nil)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnView)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var detailView: InvoiceDetailView = {
        InvoiceDetailView(Fields.all(from: invoice))
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

        view.backgroundColor = .white.withAlphaComponent(0.9)

        view.addSubview(detailView)
        view.addSubview(payNowButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingTop),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingLeadingTrailing),

            // Pay now button constraints
            payNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            payNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payNowButton.widthAnchor.constraint(equalToConstant: 100),
            payNowButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func payNowButtonTapped() {
        invoice.recipient = "invoice.recipient"
        let paymentInfo = obtainPaymentInfo()
        paymentComponentsController.createPaymentRequest(paymentInfo: paymentInfo) { paymentRequestID, error in
            print(" >>> createPaymentRequest")
        }

//        let paymentViewBottomSheet = paymentComponentsController.paymentViewBottomSheet(documentID: invoice.documentID)
//        paymentViewBottomSheet.modalPresentationStyle = .overFullScreen
//        self.present(paymentViewBottomSheet, animated: false)
    }

    @objc private func didTapOnView() {
        view.endEditing(true)
    }

    @objc private func didTapOnView() {
        view.endEditing(true)
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
        let textFields = InvoiceDetailView.textFields
        invoice.recipient = textFields[Fields.recipient.rawValue]?.text
        invoice.amountToPay = textFields[Fields.amountToPay.rawValue]?.text
        invoice.purpose = textFields[Fields.purpose.rawValue]?.text

        return PaymentInfo(recipient: invoice.recipient ?? "", iban: invoice.iban ?? "", bic: "", amount: invoice.amountToPay ?? "", purpose: invoice.purpose ?? "", paymentUniversalLink: paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "", paymentProviderId: paymentComponentsController.selectedPaymentProvider?.id ?? "")
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

extension InvoiceDetailViewController {
    enum Constants {
        static let paddingTop = 8.0
        static let paddingLeadingTrailing = 16.0
    }
}
