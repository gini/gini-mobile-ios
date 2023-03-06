//
//  DigitalInvoiceViewController.swift
// GiniBank
//
//  Created by Maciej Trybilo on 20.11.19.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK
/**
 Delegate protocol for `DigitalInvoiceViewController`.
 */
public protocol DigitalInvoiceViewControllerDelegate: AnyObject {
    
    /**
     Called after the user taps the "Pay" button on the `DigitalInvoiceViewController`.
     
     - parameter viewController: The `DigitalInvoiceViewController` instance.
     - parameter invoice: The `DigitalInvoice` as amended by the user.
     */
    func didFinish(viewController: DigitalInvoiceViewController,
                   invoice: DigitalInvoice)
}

/**
 This class is a view controller that lets the user view their invoice
 together with the line items and total amount to pay. It will push the
 `LineItemDetailsViewController` onto the navigation stack when the user
 taps the "Edit" button on any of the line items.
 */
public class DigitalInvoiceViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DigitalInvoiceTableViewTitleCell.self, forCellReuseIdentifier: "DigitalInvoiceTableViewTitleCell")
        tableView.register(UINib(nibName: "DigitalLineItemTableViewCell", bundle: giniBankBundle()),
                           forCellReuseIdentifier: "DigitalLineItemTableViewCell")
        tableView.register(DigitalInvoiceAddOnListCell.self, forCellReuseIdentifier: "DigitalInvoiceAddOnListCell")
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
        button.setTitle(NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.paybutton.title",
                                                                 comment: "Proceed"), for: .normal)
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.isEnabled = viewModel.isPayButtonEnabled()
        return button
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.totalpricetitle",
                                                              comment: "Total")
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = configuration.textStyleFonts[.title1Bold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.text = viewModel.invoice?.total?.string
        return label
    }()

    public weak var delegate: DigitalInvoiceViewControllerDelegate?

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
        title = .ginibankLocalized(resource: DigitalInvoiceStrings.screenTitle)
        edgesForExtendedLayout = []
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2).uiColor()
        let helpButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.screenTitle",
                                                                       comment: "Help")
        let cancelButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.cancelButtonTitle",
                                                                         comment: "Cancel")

        if configuration.bottomNavigationBarEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: cancelButtonTitle,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(closeReturnAssistantOverview))

            navigationItem.hidesBackButton = true
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: helpButtonTitle,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(helpButtonTapped(source:)))

            navigationItem.leftBarButtonItem = UIBarButtonItem(title: cancelButtonTitle,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(closeReturnAssistantOverview))
        }



        view.addSubview(tableView)
        view.addSubview(buttonContainerView)

        buttonContainerView.addSubview(payButton)
        buttonContainerView.addSubview(totalLabel)
        buttonContainerView.addSubview(totalValueLabel)

        setupBottomNavigationBar()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),

            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainerView.heightAnchor.constraint(equalToConstant: Constants.buttonContainerHeight),

            payButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor, constant: -Constants.labelPadding),
            payButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            payButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.payButtonHeight),

            totalLabel.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: Constants.padding),
            totalLabel.trailingAnchor.constraint(lessThanOrEqualTo: totalValueLabel.leadingAnchor, constant: Constants.padding),

            totalValueLabel.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: Constants.padding),
            totalValueLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            totalValueLabel.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -Constants.labelPadding),
            totalValueLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.tabletWidthMultiplier),
                totalLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),

                totalLabel.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: Constants.labelPadding)
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
                self?.viewModel.didTapHelp()
            }

            if let navigationBar = navigationBarBottomAdapter?.injectedView() {
                bottomNavigationBar = navigationBar
                view.addSubview(navigationBar)

                navigationBar.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    navigationBar.heightAnchor.constraint(equalToConstant: 160),
                    navigationBar.topAnchor.constraint(equalTo: tableView.bottomAnchor)
                ])
            }

            buttonContainerView.isHidden = true
            updateValues()
        }
    }

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.shouldShowOnboarding()
    }
    
    @objc func payButtonTapped() {
        viewModel.didTapPay()
    }

    func updateValues() {
        tableView.reloadData()

        if configuration.bottomNavigationBarEnabled {
            navigationBarBottomAdapter?.updateTotalPrice(priceWithCurrencySymbol: viewModel.invoice?.total?.string)
            navigationBarBottomAdapter?.updateProceedButtonState(enabled: viewModel.isPayButtonEnabled())
        } else {
            totalValueLabel.text = viewModel.invoice?.total?.string

            if viewModel.isPayButtonEnabled() {
                payButton.isEnabled = true
                payButton.configure(with: configuration.primaryButtonConfiguration)
            } else {
                payButton.isEnabled = false
                payButton.configure(with: configuration.secondaryButtonConfiguration)
            }
        }
    }
    
    private func payButtonAccessibilityLabel() -> String {
        guard let invoice = viewModel.invoice else {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.disabledPayButtonTitle)
        }
        
        return String.localizedStringWithFormat(DigitalInvoiceStrings.payButtonTitleAccessibilityLabel.localizedGiniBankFormat,
                                                invoice.numSelected,
                                                invoice.numTotal)
    }

    @objc func helpButtonTapped(source: UIButton) {
        viewModel.didTapHelp()
    }
    
    @objc func closeReturnAssistantOverview() {
        viewModel.didTapCancel()
    }
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDelegate
    enum Section: Int, CaseIterable {
        case titleCell
        case lineItems
        case addOns
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .titleCell: return 1
        case .lineItems: return viewModel.invoice?.lineItems.count ?? 0
        case .addOns: return 1
        default: fatalError()
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .titleCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceTableViewTitleCell",
                                                     for: indexPath) as! DigitalInvoiceTableViewTitleCell
            return cell
        case .lineItems:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalLineItemTableViewCell",
                                                     for: indexPath) as! DigitalLineItemTableViewCell
            if let invoice = viewModel.invoice {
                cell.viewModel = DigitalLineItemTableViewCellViewModel(lineItem: invoice.lineItems[indexPath.row],
                                                                       index: indexPath.row,
                                                                       invoiceNumTotal: invoice.numTotal,
                                                                       invoiceLineItemsCount: invoice.lineItems.count)
            }
            cell.delegate = self
            return cell
            
        case .addOns:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceAddOnListCell",
                                                     for: indexPath) as! DigitalInvoiceAddOnListCell
            cell.addOns = viewModel.invoice?.addons
            return cell
        default: fatalError()
        }
    }
}

extension DigitalInvoiceViewController: DigitalLineItemTableViewCellDelegate {
    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        
        guard let invoice = viewModel.invoice else { return }
        switch invoice.lineItems[lineItemViewModel.index].selectedState {
        case .selected:
            if let returnReasons = self.viewModel.invoice?.returnReasons, configuration.enableReturnReasons {
                presentReturnReasonActionSheet(for: lineItemViewModel.index,
                                               source: cell.modeSwitch,
                                               with: returnReasons)
            } else {
                self.viewModel.invoice?.lineItems[lineItemViewModel.index].selectedState = .deselected(reason: nil)
                return
            }
        case .deselected:
            self.viewModel.invoice?.lineItems[lineItemViewModel.index].selectedState = .selected
        }
        updateValues()
    }
        
    func editTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        viewModel.didTapEdit(on: lineItemViewModel)
    }
}

extension DigitalInvoiceViewController {
    private func presentReturnReasonActionSheet(for index: Int, source: UIView, with returnReasons: [ReturnReason]) {
        DeselectLineItemActionSheet().present(from: self, source: source, returnReasons: returnReasons) { [weak self] selectedState in
            guard let self = self else { return }
            switch selectedState {
            case .selected:
                self.viewModel.invoice?.lineItems[index].selectedState = .selected
            case .deselected(let reason):
                self.viewModel.invoice?.lineItems[index].selectedState = .deselected(reason: reason)
            }

            DispatchQueue.main.async {
                self.updateValues()
            }
        }
    }
}

private extension DigitalInvoiceViewController {
    enum Constants {
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let tabletWidthMultiplier: CGFloat = 0.7
        static let buttonContainerHeight: CGFloat = 160
        static let payButtonHeight: CGFloat = 50
    }
}
