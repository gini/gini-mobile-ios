//
//  DigitalInvoiceViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK

/**
 This class is a view controller that lets the user view their invoice
 together with the line items and total amount to pay. It will present the
 `EditLineItemViewModel` onto the navigation stack when the user
 taps the "Edit" button on any of the line items.
 */
final class DigitalInvoiceViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DigitalInvoiceTableViewTitleCell.self,
                           forCellReuseIdentifier: DigitalInvoiceTableViewTitleCell.reuseIdentifier)
        tableView.register(UINib(nibName: "DigitalLineItemTableViewCell", bundle: giniBankBundle()),
                           forCellReuseIdentifier: DigitalLineItemTableViewCell.reuseIdentifier)
        tableView.register(DigitalInvoiceAddOnListCell.self,
                           forCellReuseIdentifier: DigitalInvoiceAddOnListCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.padding, right: 0)
        return tableView
    }()

    private lazy var buttonContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private lazy var payButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let buttonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.paybutton.title",
                                                                   comment: "Proceed")
        button.setTitle(buttonTitle, for: .normal)

        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.isEnabled = viewModel.isPayButtonEnabled()
        return button
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        let labelTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.totalpricetitle",
                                                                  comment: "Total")
        label.text = labelTitle
        label.accessibilityValue = labelTitle
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.text = viewModel.invoice?.total?.string
        label.accessibilityValue = viewModel.invoice?.total?.string
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        return dividerView
    }()

    private let viewModel: DigitalInvoiceViewModel
    private let configuration = GiniBankConfiguration.shared

    private var navigationBarBottomAdapter: DigitalInvoiceNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    init(viewModel: DigitalInvoiceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.screentitle",
                                                         comment: "Digital invoice")
        edgesForExtendedLayout = []
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2).uiColor()
        if configuration.bottomNavigationBarEnabled {
            let cancelButton = GiniBarButton(ofType: .cancel)
            cancelButton.addAction(self, #selector(closeReturnAssistantOverview))
            navigationItem.rightBarButtonItem = cancelButton.barButton
            navigationItem.hidesBackButton = true
        } else {
            let helpButton = GiniBarButton(ofType: .help)
            helpButton.addAction(self, #selector(helpButtonTapped))
            navigationItem.rightBarButtonItem = helpButton.barButton

            let cancelButton = GiniBarButton(ofType: .cancel)
            cancelButton.addAction(self, #selector(closeReturnAssistantOverview))
            navigationItem.leftBarButtonItem = cancelButton.barButton
        }

        view.addSubview(tableView)
        view.addSubview(buttonContainerView)

        buttonContainerView.addSubview(dividerView)
        buttonContainerView.addSubview(totalLabel)
        buttonContainerView.addSubview(totalValueLabel)
        buttonContainerView.addSubview(payButton)

        setupBottomNavigationBar()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),

            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonContainerHeight),

            dividerView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerViewHeight),

            totalLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor,
                                            constant: Constants.padding),
            totalLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),

            totalValueLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor,
                                                 constant: Constants.padding / 2),
            totalValueLabel.leadingAnchor.constraint(equalTo: totalLabel.leadingAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),

            payButton.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: Constants.labelPadding),
            payButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor,
                                              constant: -Constants.labelPadding),
            payButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            payButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.payButtonHeight)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: Constants.tabletWidthMultiplier)])
        } else {
            NSLayoutConstraint.activate([
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding)
            ])
        }
    }

    private func setupBottomNavigationBar() {
        if configuration.bottomNavigationBarEnabled {
            if let bottomBarAdapter = configuration.digitalInvoiceNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultDigitalInvoiceNavigationBarBottomAdapter()
            }

            navigationBarBottomAdapter?.setProceedButtonClickedActionCallback { [weak self] in
                self?.payButtonTapped()
            }

            navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
                self?.helpButtonTapped()
            }

            if let navigationBar = navigationBarBottomAdapter?.injectedView() {
                bottomNavigationBar = navigationBar
                view.addSubview(navigationBar)

                navigationBar.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    navigationBar.topAnchor.constraint(equalTo: tableView.bottomAnchor)
                ])
            }

            buttonContainerView.isHidden = true
            updateValues()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        viewModel.shouldShowOnboarding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presentedViewController == nil {
            // Send a 'screenShown' event when returning back from `Help` screen.
            // This is not called initially due to the onboarding screen being displayed as a modal view on top.
            sendAnalyticsScreenShown()
        }
    }

    @objc func payButtonTapped() {
        GiniAnalyticsManager.track(event: .proceedTapped, screenName: .returnAssistant)
        viewModel.didTapPay()
    }

    func updateValues() {
        tableView.reloadData()

        if configuration.bottomNavigationBarEnabled {
            navigationBarBottomAdapter?.updateTotalPrice(priceWithCurrencySymbol: viewModel.invoice?.total?.string)
            navigationBarBottomAdapter?.updateProceedButtonState(enabled: viewModel.isPayButtonEnabled())
        } else {
            totalValueLabel.text = viewModel.invoice?.total?.string
            totalValueLabel.accessibilityValue = viewModel.invoice?.total?.string

            if viewModel.isPayButtonEnabled() {
                payButton.isEnabled = true
                payButton.configure(with: configuration.primaryButtonConfiguration)
            } else {
                payButton.isEnabled = false
                payButton.configure(with: configuration.secondaryButtonConfiguration)
            }
        }
    }

    @objc func helpButtonTapped() {
        GiniAnalyticsManager.track(event: .helpTapped, screenName: .returnAssistant)
        viewModel.didTapHelp()
    }

    @objc func closeReturnAssistantOverview() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .returnAssistant)
        viewModel.didTapCancel()
    }

    func sendAnalyticsScreenShown() {
        var eventProperties: [GiniAnalyticsProperty] = []
        if let documentId = configuration.documentService?.document?.id {
            eventProperties.append(GiniAnalyticsProperty(key: .documentId, value: documentId))
        }
        GiniAnalyticsManager.trackScreenShown(screenName: .returnAssistant, properties: eventProperties)
    }
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDelegate
    enum Section: Int, CaseIterable {
        case titleCell
        case lineItems
        case addOns
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .titleCell: return 1
        case .lineItems: return viewModel.invoice?.lineItems.count ?? 0
        case .addOns: return 1
        default: fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .titleCell:
            if let cell = tableView.dequeueReusableCell(
                                        withIdentifier: DigitalInvoiceTableViewTitleCell.reuseIdentifier,
                                        for: indexPath) as? DigitalInvoiceTableViewTitleCell {
                return cell
            }
            assertionFailure("DigitalInvoiceTableViewTitleCell could not been reused")
            return UITableViewCell()
        case .lineItems:

            if let cell = tableView.dequeueReusableCell(withIdentifier: DigitalLineItemTableViewCell.reuseIdentifier,
                                                        for: indexPath) as? DigitalLineItemTableViewCell {
                if let invoice = viewModel.invoice {
                    cell.viewModel = DigitalLineItemTableViewCellViewModel(lineItem: invoice.lineItems[indexPath.row],
                                                                           index: indexPath.row,
                                                                           invoiceNumTotal: invoice.numTotal,
                                                                           invoiceLineItemsCount:
                                                                                invoice.lineItems.count)
                }
                cell.delegate = self
                return cell
            }
            assertionFailure("DigitalLineItemTableViewCell could not been reused")
            return UITableViewCell()
        case .addOns:
            if let cell = tableView.dequeueReusableCell(withIdentifier: DigitalInvoiceAddOnListCell.reuseIdentifier,
                                                        for: indexPath) as? DigitalInvoiceAddOnListCell {
                cell.addOns = viewModel.invoice?.addons
                return cell
            }
            assertionFailure("DigitalInvoiceAddOnListCell could not been reused")
            return UITableViewCell()
        default: fatalError()
        }
    }
}

extension DigitalInvoiceViewController: DigitalLineItemTableViewCellDelegate {
    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell,
                                lineItemViewModel: DigitalLineItemTableViewCellViewModel) {

        guard let invoice = viewModel.invoice else { return }
        let selectedLineItem = invoice.lineItems[lineItemViewModel.index]
        var isLineItemSelected = true
        switch selectedLineItem.selectedState {
        case .selected:
            if let returnReasons = self.viewModel.invoice?.returnReasons, configuration.enableReturnReasons {
                presentReturnReasonActionSheet(for: lineItemViewModel.index,
                                               source: cell.modeSwitch,
                                               with: returnReasons,
                                               isLineItemSelected: &isLineItemSelected)
            } else {
                self.viewModel.invoice?.lineItems[lineItemViewModel.index].selectedState = .deselected(reason: nil)
                isLineItemSelected = false
            }
        case .deselected:
            self.viewModel.invoice?.lineItems[lineItemViewModel.index].selectedState = .selected
            isLineItemSelected = true

        }

        GiniAnalyticsManager.track(event: .itemSwitchTapped,
                                   screenName: .returnAssistant,
                                   properties: [GiniAnalyticsProperty(key: .switchActive, value: isLineItemSelected)])
        updateValues()
    }

    func editTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        GiniAnalyticsManager.track(event: .editTapped, screenName: .returnAssistant)
        viewModel.didTapEdit(on: lineItemViewModel)
    }
}

extension DigitalInvoiceViewController {
    private func presentReturnReasonActionSheet(for index: Int,
                                                source: UIView,
                                                with returnReasons: [ReturnReason],
                                                isLineItemSelected: inout Bool) {
        var isSelected = isLineItemSelected
        DeselectLineItemActionSheet().present(from: self,
                                              source: source,
                                              returnReasons: returnReasons) { [weak self] selectedState in
            guard let self = self else { return }
            switch selectedState {
            case .selected:
                self.viewModel.invoice?.lineItems[index].selectedState = .selected
                isSelected = true
            case .deselected(let reason):
                self.viewModel.invoice?.lineItems[index].selectedState = .deselected(reason: reason)
                isSelected = false
            }
            DispatchQueue.main.async {
                self.updateValues()
            }
        }
        isLineItemSelected = isSelected
    }
}

extension DigitalInvoiceViewController: DigitalInvoiceOnboardingViewControllerDelegate {
    func dismissViewController() {
        // after dismissing the oboarding screen, screen_shown event can be sent
        sendAnalyticsScreenShown()
    }
}

private extension DigitalInvoiceViewController {
    enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let tabletWidthMultiplier: CGFloat = 0.7
        static let buttonContainerHeight: CGFloat = 160
        static let payButtonHeight: CGFloat = 50
        static let dividerViewHeight: CGFloat = 1
    }
}
