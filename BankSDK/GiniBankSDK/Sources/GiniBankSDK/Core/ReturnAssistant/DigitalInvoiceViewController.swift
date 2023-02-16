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

    /**
     The `DigitalInvoice` to display and amend by the user.
     */
    public var invoice: DigitalInvoice? {
        didSet {
            if tableView.superview != nil {
                toggleUIChanges()
                tableView.reloadData()
            } else {
                toggleUIUpdates = true
            }
        }
    }
    
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
    
    private let tableView = UITableView()
    
    private var infoView: InfoView?
    private var tableHeaderViewHeightConstraint: NSLayoutConstraint?
    
    private var didShowOnboardInCurrentSession = false
    private var didShowInfoViewInCurrentSession = false
    private var toggleUIUpdates = false
    private let vm = DigitalInvoiceViewModel()

    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        tableView.register(TextFieldTableViewCell.self,
                           forCellReuseIdentifier: "TextFieldTableViewCell")
        
        tableView.register(UINib(nibName: "DigitalLineItemTableViewCell",
                                 bundle: giniBankBundle()),
                           forCellReuseIdentifier: "DigitalLineItemTableViewCell")
        
        tableView.register(DigitalInvoiceAddonCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceAddonCell")
        
        tableView.register(DigitalInvoiceTotalPriceCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceTotalPriceCell")
        
        tableView.register(DigitalInvoiceFooterCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceFooterCell")
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = returnAssistantConfiguration.digitalInvoiceBackgroundColor.uiColor()
    }
    
    fileprivate func configureNavigationBar() {
        title = .ginibankLocalized(resource: DigitalInvoiceStrings.screenTitle)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: prefferedImage(named: "infoIcon"), style: .plain, target: self, action: #selector(whatIsThisTapped(source:)))
        let leftBarButtonItemTitle = String.ginibankLocalized(resource: DigitalInvoiceStrings.backButtonTitle)
        navigationItem.leftBarButtonItem = GiniBarButtonItem.init(image: prefferedImage(named: "arrowBack"), title: leftBarButtonItemTitle, style: .plain, target: self, action: #selector(closeReturnAssistantOverview))
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDigitalInvoiceOnboarding()
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !onboardingWillBeShown {
            showFooterDemo()
        }
        if toggleUIUpdates {
            toggleUIChanges()
            toggleUIUpdates = false
        }
    }
    
    @objc func payButtonTapped() {
        guard let invoice = invoice else { return }
        delegate?.didFinish(viewController: self, invoice: invoice)
    }
    
    private func payButtonTitle() -> String {
        guard let invoice = invoice else {
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
        
        guard let invoice = invoice else {
            return .ginibankLocalized(resource: DigitalInvoiceStrings.disabledPayButtonTitle)
        }
        
        return String.localizedStringWithFormat(DigitalInvoiceStrings.payButtonTitleAccessibilityLabel.localizedGiniBankFormat,
                                                invoice.numSelected,
                                                invoice.numTotal)
    }
    
    private func toggleUIChanges() {
        guard let invoice = invoice else { return }
        if !didShowInfoViewInCurrentSession,
           invoice.inaccurateResults {
            shouldShowInfoView()
        }
        let shouldEnableSkipButton = invoice.numSelected > 0
        infoView?.enableSkipButton(shouldEnableSkipButton)
    }
    
    @objc func skipButtonTapped() {
        payButtonTapped()
    }

    @objc func whatIsThisTapped(source: UIButton) {
        let digitalInvoiceHelViewModel = DigitalInvoiceHelpViewModel()
        let digitalInvoiceHelpViewController = DigitalInvoiceHelpViewController(viewModel: digitalInvoiceHelViewModel)

        navigationController?.pushViewController(digitalInvoiceHelpViewController, animated: true)
    }
    
    @objc func closeReturnAssistantOverview(){
        closeReturnAssistantBlock()
    }
    
    fileprivate var onboardingWillBeShown: Bool {
        let key = "ginibank.defaults.digitalInvoiceOnboardingShowed"
        return UserDefaults.standard.object(forKey: key) == nil ? true : false
    }
    
    fileprivate var footerDemoWillBeShown: Bool {
        let key = "ginibank.defaults.digitalInvoiceFooterDemoShowed"
        return UserDefaults.standard.object(forKey: key) == nil ? true : false
    }
    
    fileprivate func showDigitalInvoiceOnboarding() {
        if onboardingWillBeShown && !didShowOnboardInCurrentSession {
            let storyboard = UIStoryboard(name: "DigitalInvoiceOnboarding", bundle: giniBankBundle())
            let digitalInvoiceOnboardingViewController = storyboard.instantiateViewController(withIdentifier: "digitalInvoiceOnboardingViewController") as! DigitalInvoiceOnboardingViewController

            digitalInvoiceOnboardingViewController.delegate = self
            digitalInvoiceOnboardingViewController.returnAssistantConfiguration = returnAssistantConfiguration

            present(digitalInvoiceOnboardingViewController, animated: true)
            didShowOnboardInCurrentSession = true
        }
    }
    
    fileprivate func showFooterDemo() {
        if footerDemoWillBeShown {
            UIView.animate(withDuration: 0.8) {
                self.tableView.setContentOffset(
                    CGPoint(x: .zero, y: self.tableView.contentSize.height - self.tableView.bounds.size.height),
                    animated: false)
                self.view.layoutIfNeeded()
            } completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIView.animate(withDuration: 0.8) {
                        self.tableView.setContentOffset(
                            .zero,
                            animated: false)
                        self.view.layoutIfNeeded()
                    }
                }
            }
            UserDefaults.standard.set(true, forKey: "ginibank.defaults.digitalInvoiceFooterDemoShowed")
        }
    }
    
    fileprivate func shouldShowInfoView() {
        infoView = InfoView()
        
        guard let headerView = infoView else {
            return
        }
        headerView.delegate = self
        headerView.returnAssistantConfiguration = returnAssistantConfiguration
        
        tableView.contentInset.top = 15
        headerView.translatesAutoresizingMaskIntoConstraints = false

        self.tableView.tableHeaderView = headerView
        headerView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        tableHeaderViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 80)
        tableHeaderViewHeightConstraint?.isActive = true

        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
        self.didExpandButton(expanded: false)
        didShowInfoViewInCurrentSession = true
    }
    
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    enum Section: Int, CaseIterable {
        case lineItems
        case addons
        case totalPrice
        case footer
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        switch Section(rawValue: section) {
        case .lineItems: return invoice?.lineItems.count ?? 0
        case .addons: return invoice?.addons.count ?? 0
        case .totalPrice: return 1
        case .footer: return 1
        default: fatalError()
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .lineItems:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalLineItemTableViewCell",
                                                     for: indexPath) as! DigitalLineItemTableViewCell
            if let invoice = invoice {
                cell.viewModel = DigitalLineItemViewModel(lineItem: invoice.lineItems[indexPath.row], returnAssistantConfiguration: returnAssistantConfiguration, index: indexPath.row, invoiceNumTotal: invoice.numTotal, invoiceLineItemsCount: invoice.lineItems.count)
            }
            
            cell.delegate = self
            
            return cell
            
        case .addons:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceAddonCell",
                                                     for: indexPath) as! DigitalInvoiceAddonCell
            cell.returnAssistantConfiguration = returnAssistantConfiguration
            if let invoice = invoice {
                let addon = invoice.addons[indexPath.row]
                cell.addonPrice = addon.price
                cell.addonName = addon.name
            }
            
            return cell
            
        case .totalPrice:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceTotalPriceCell",
                                                     for: indexPath) as! DigitalInvoiceTotalPriceCell
            cell.returnAssistantConfiguration = returnAssistantConfiguration
            
            cell.totalPrice = invoice?.total
            
            cell.delegate = self
            
            return cell
            
        case .footer:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceFooterCell",
                                                     for: indexPath) as! DigitalInvoiceFooterCell
            cell.returnAssistantConfiguration = returnAssistantConfiguration
            cell.payButton.accessibilityLabel = payButtonAccessibilityLabel()
            cell.payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
            if let invoice = invoice {
                let total = invoice.total?.value ?? 0
                let shouldEnablePayButton = vm.isPayButtonEnabled(total: total)
                cell.enableButtons(shouldEnablePayButton)
                let buttonTitle = vm.payButtonTitle(
                    isEnabled: shouldEnablePayButton,
                    numSelected: invoice.numSelected,
                    numTotal: invoice.numTotal
                )
                cell.payButton.setTitle(
                    buttonTitle,
                    for: .normal)
                cell.shouldSetUIForInaccurateResults(invoice.inaccurateResults)
                cell.skipButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.skipButtonTitle),
                                         for: .normal)
                cell.skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
            } else {
                let buttonTitle = vm.payButtonTitle(
                    isEnabled: false,
                    numSelected: 0,
                    numTotal: 0
                )
                cell.payButton.setTitle(buttonTitle, for: .normal)
            }
            return cell
            
        default: fatalError()
        }
    }
}

extension DigitalInvoiceViewController: DigitalLineItemTableViewCellDelegate {
    func deleteTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel) {
        invoice?.lineItems.remove(at: viewModel.index)
    }
    

    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel) {
        
        guard let invoice = invoice else { return }
        
        switch invoice.lineItems[viewModel.index].selectedState {
        
        case .selected:
            
            if let returnReasons = self.invoice?.returnReasons, returnAssistantConfiguration.enableReturnReasons {
                presentReturnReasonActionSheet(for: viewModel.index,
                                               source: cell.modeSwitch,
                                               with: returnReasons)
            } else {
                self.invoice?.lineItems[viewModel.index].selectedState = .deselected(reason: nil)
                return
            }
            
        case .deselected:
            self.invoice?.lineItems[viewModel.index].selectedState = .selected
        }
    }
        
    func editTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel) {
                
        let viewController = LineItemDetailsViewController()
        viewController.lineItem = invoice?.lineItems[viewModel.index]
        viewController.returnReasons = invoice?.returnReasons
        viewController.lineItemIndex = viewModel.index
        viewController.returnAssistantConfiguration = returnAssistantConfiguration
        viewController.delegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DigitalInvoiceViewController {
    
    private func presentReturnReasonActionSheet(for index: Int, source: UIView, with returnReasons: [ReturnReason]) {
        
        DeselectLineItemActionSheet().present(from: self, source: source, returnReasons: returnReasons) { selectedState in
            
            switch selectedState {
            case .selected:
                self.invoice?.lineItems[index].selectedState = .selected
            case .deselected(let reason):
                self.invoice?.lineItems[index].selectedState = .deselected(reason: reason)
            }
        }
    }
}

extension DigitalInvoiceViewController: LineItemDetailsViewControllerDelegate {
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController, lineItem: DigitalInvoice.LineItem, index: Int, shouldPopViewController: Bool) {
        
        if shouldPopViewController {
            navigationController?.popViewController(animated: true)
        }
        guard let invoice = invoice else { return }
        
        if invoice.lineItems.indices.contains(index) {
            self.invoice?.lineItems[index] = lineItem
        } else {
            self.invoice?.lineItems.append(lineItem)
        }

        
    }
}

extension DigitalInvoiceViewController: InfoViewDelegate {
    func didTapSkipButton() {
        payButtonTapped()
    }
    
    func didExpandButton(expanded: Bool) {
        guard let infoView = infoView else { return }
        let infoViewHeight: CGFloat = expanded ? 80: 430
        tableHeaderViewHeightConstraint?.constant = infoViewHeight

        self.tableView.layoutIfNeeded()
        infoView.animate()

        UIView.animate(withDuration: 0.4) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

extension DigitalInvoiceViewController: DigitalInvoiceOnboardingViewControllerDelegate {
    func didDismissViewController() {
        showFooterDemo()
    }
}

extension DigitalInvoiceViewController: DigitalInvoiceTotalPriceCellDelegate {
    func didTapAddArticleButton() {
        guard let firstItem = invoice?.lineItems.first else { return }
        let viewController = LineItemDetailsViewController()
        let price = Price(value: 0, currencyCode: firstItem.price.currencyCode)
        viewController.lineItem = DigitalInvoice.LineItem(name: "", quantity: 0, price: price, selectedState: .selected, isUserInitiated: true)
        viewController.returnAssistantConfiguration = returnAssistantConfiguration
        viewController.lineItemIndex = invoice?.lineItems.count
        viewController.delegate = self
        viewController.shouldEnableSaveButton = false
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
