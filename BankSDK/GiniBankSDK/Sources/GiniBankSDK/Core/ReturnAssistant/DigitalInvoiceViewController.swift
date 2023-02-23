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

    public weak var delegate: DigitalInvoiceViewControllerDelegate?
    
    // TODO: This is to cope with the screen coordinator being inadequate at this point to support the return assistant step and needing a refactor.
    // Remove ASAP
    public var analysisDelegate: AnalysisDelegate?
    
    /**
     Handler will be called when back button was pressed.
     */
    public var closeReturnAssistantBlock: () -> Void = {}
    
    /**
     The `ReturnAssistantConfiguration` instance used by this class to customise its appearance.
     By default the shared instance is used.
     */
    public var returnAssistantConfiguration = ReturnAssistantConfiguration.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DigitalInvoiceTableViewTitleCell.self, forCellReuseIdentifier: "DigitalInvoiceTableViewTitleCell")
        tableView.register(UINib(nibName: "DigitalLineItemTableViewCell", bundle: giniBankBundle()),
                           forCellReuseIdentifier: "DigitalLineItemTableViewCell")
        tableView.register(DigitalInvoiceAddonCell.self, forCellReuseIdentifier: "DigitalInvoiceAddonCell")
        tableView.register(DigitalInvoiceTotalPriceCell.self, forCellReuseIdentifier: "DigitalInvoiceTotalPriceCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var buttonContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private var didShowOnboardInCurrentSession = false
    private let viewModel: DigitalInvoiceViewModel

    public init(viewModel: DigitalInvoiceViewModel) {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: helpButtonTitle,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(helpButtonTapped(source:)))

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: cancelButtonTitle,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeReturnAssistantOverview))
        view.addSubview(tableView)
        view.addSubview(buttonContainerView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDigitalInvoiceOnboarding()
    }
    
    @objc func payButtonTapped() {
        guard let invoice = viewModel.invoice else { return }
        delegate?.didFinish(viewController: self, invoice: invoice)
    }
    
    private func payButtonTitle() -> String {
        guard let invoice = viewModel.invoice else {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.disabledPayButtonTitle)
        }
        if invoice.numSelected == 0 {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.payButtonOtherCharges)
        }
        return String.localizedStringWithFormat(DigitalInvoiceStrings.payButtonTitle.localizedGiniBankFormat,
                                                invoice.numSelected,
                                                invoice.numTotal)
    }
    
    private func payButtonAccessibilityLabel() -> String {
        guard let invoice = viewModel.invoice else {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.disabledPayButtonTitle)
        }
        
        return String.localizedStringWithFormat(DigitalInvoiceStrings.payButtonTitleAccessibilityLabel.localizedGiniBankFormat,
                                                invoice.numSelected,
                                                invoice.numTotal)
    }
    
    @objc func skipButtonTapped() {
        payButtonTapped()
    }

    @objc func helpButtonTapped(source: UIButton) {
        let digitalInvoiceHelViewModel = DigitalInvoiceHelpViewModel()
        let digitalInvoiceHelpViewController = DigitalInvoiceHelpViewController(viewModel: digitalInvoiceHelViewModel)

        navigationController?.pushViewController(digitalInvoiceHelpViewController, animated: true)
    }
    
    @objc func closeReturnAssistantOverview() {
        closeReturnAssistantBlock()
    }
    
    fileprivate var onboardingWillBeShown: Bool {
        let key = "ginibank.defaults.digitalInvoiceOnboardingShowed"
        return UserDefaults.standard.object(forKey: key) == nil ? true : false
    }
    
    fileprivate func showDigitalInvoiceOnboarding() {
        if onboardingWillBeShown && !didShowOnboardInCurrentSession {
            let storyboard = UIStoryboard(name: "DigitalInvoiceOnboarding", bundle: giniBankBundle())
            let digitalInvoiceOnboardingViewController = storyboard.instantiateViewController(withIdentifier: "digitalInvoiceOnboardingViewController") as! DigitalInvoiceOnboardingViewController

            present(digitalInvoiceOnboardingViewController, animated: true)
            didShowOnboardInCurrentSession = true
        }
    }
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    enum Section: Int, CaseIterable {
        case titleCell
        case lineItems
        case addons
        case totalPrice
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .titleCell: return 1
        case .lineItems: return viewModel.invoice?.lineItems.count ?? 0
        case .addons: return viewModel.invoice?.addons.count ?? 0
        case .totalPrice: return 1
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
            
        case .addons:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceAddonCell",
                                                     for: indexPath) as! DigitalInvoiceAddonCell
            cell.returnAssistantConfiguration = returnAssistantConfiguration
            if let invoice = viewModel.invoice {
                let addon = invoice.addons[indexPath.row]
                cell.addonPrice = addon.price
                cell.addonName = addon.name
            }
            
            return cell
            
        case .totalPrice:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceTotalPriceCell",
                                                     for: indexPath) as! DigitalInvoiceTotalPriceCell
            cell.returnAssistantConfiguration = returnAssistantConfiguration

            cell.totalPrice = viewModel.invoice?.total
            
            cell.delegate = self
            
            return cell
        default: fatalError()
        }
    }
}

extension DigitalInvoiceViewController: DigitalLineItemTableViewCellDelegate {
    func deleteTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        viewModel.invoice?.lineItems.remove(at: lineItemViewModel.index)
    }
    

    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        
        guard let invoice = viewModel.invoice else { return }
        
        switch invoice.lineItems[lineItemViewModel.index].selectedState {
        
        case .selected:
            
            if let returnReasons = self.viewModel.invoice?.returnReasons, returnAssistantConfiguration.enableReturnReasons {
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

        tableView.reloadData()
    }
        
    func editTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
                
        let viewController = LineItemDetailsViewController()
        viewController.lineItem = viewModel.invoice?.lineItems[lineItemViewModel.index]
        viewController.returnReasons = viewModel.invoice?.returnReasons
        viewController.lineItemIndex = lineItemViewModel.index
        viewController.returnAssistantConfiguration = returnAssistantConfiguration
        viewController.delegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
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
                self.tableView.reloadData()
            }
        }
    }
}

extension DigitalInvoiceViewController: LineItemDetailsViewControllerDelegate {
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController, lineItem: DigitalInvoice.LineItem, index: Int, shouldPopViewController: Bool) {
        
        if shouldPopViewController {
            navigationController?.popViewController(animated: true)
        }
        guard let invoice = viewModel.invoice else { return }
        
        if invoice.lineItems.indices.contains(index) {
            self.viewModel.invoice?.lineItems[index] = lineItem
        } else {
            self.viewModel.invoice?.lineItems.append(lineItem)
        }

        tableView.reloadData()
    }
}

extension DigitalInvoiceViewController: DigitalInvoiceTotalPriceCellDelegate {
    func didTapAddArticleButton() {
        guard let firstItem = viewModel.invoice?.lineItems.first else { return }
        let viewController = LineItemDetailsViewController()
        let price = Price(value: 0, currencyCode: firstItem.price.currencyCode)
        viewController.lineItem = DigitalInvoice.LineItem(name: "", quantity: 0, price: price, selectedState: .selected, isUserInitiated: true)
        viewController.returnAssistantConfiguration = returnAssistantConfiguration
        viewController.lineItemIndex = viewModel.invoice?.lineItems.count
        viewController.delegate = self
        viewController.shouldEnableSaveButton = false
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
