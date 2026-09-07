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
        tableView.register(DigitalInvoiceSkontoTableViewCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceSkontoTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.padding, right: 0)
        return tableView
    }()

    private lazy var proceedView: DigitalInvoiceProceedView = {
        let containerView = DigitalInvoiceProceedView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private lazy var landscapeProceedViewContainer: UIView = UIView()

    private let viewModel: DigitalInvoiceViewModel
    private let configuration = GiniBankConfiguration.shared

    private lazy var proceedViewConstraints: [NSLayoutConstraint] = [
        proceedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        proceedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        proceedView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonContainerHeight),
        proceedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.bottomAnchor.constraint(equalTo: proceedView.topAnchor)
    ]

    private lazy var proceedViewTableConstraints: [NSLayoutConstraint] = [
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

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

        let helpButton = GiniBarButton(ofType: .help)
        helpButton.addAction(self, #selector(helpButtonTapped))
        navigationItem.rightBarButtonItem = helpButton.barButton

        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(self, #selector(closeReturnAssistantOverview))
        navigationItem.leftBarButtonItem = cancelButton.barButton

        view.addSubview(tableView)
        view.addSubview(proceedView)

        proceedView.proceedAction = { [weak self] in
            self?.viewModel.didTapPay()
        }
    }

    private func setupConstraints() {
        let tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor,
                                                                    constant: Constants.padding)
        var constraints: [NSLayoutConstraint] = []

        constraints.append(tableViewTopConstraint)
        constraints.append(contentsOf: proceedViewConstraints)

        NSLayoutConstraint.activate(constraints)

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: Constants.tabletWidthMultiplier)])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.horizontalPadding),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.horizontalPadding)
            ])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        viewModel.shouldShowOnboarding()
        updateValues()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presentedViewController == nil {
            // Send a 'screenShown' event when returning back from `Help` screen.
            // This is not called initially due to the onboarding screen being displayed as a modal view on top.
            sendAnalyticsScreenShown()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configureProceedViewForiPhone()
    }

    private func configureProceedViewForiPhone() {
        guard UIDevice.current.isIphone else { return }

        let isLandscape = UIDevice.current.isLandscape

        if isLandscape {
            configureProceedViewForLandscape()
        } else {
            configureProceedViewForPortrait()
        }
    }

    private func configureProceedViewForLandscape() {
        NSLayoutConstraint.deactivate(proceedViewConstraints)
        proceedView.removeFromSuperview()

        setupProceedViewInLandscape()

        NSLayoutConstraint.activate(proceedViewTableConstraints)

        proceedView.isHidden = false
    }

    private func configureProceedViewForPortrait() {
        NSLayoutConstraint.deactivate(proceedViewTableConstraints)
        proceedView.removeFromSuperview()
        tableView.tableFooterView = nil

        proceedViewTableConstraints.last?.isActive = false

        view.addSubview(proceedView)
        NSLayoutConstraint.activate(proceedViewConstraints)

        proceedView.isHidden = false
    }

    func updateValues() {
        // Reconfigure visible cells in place instead of dequeueing new ones so
        // the iOS 26 Liquid Glass UISwitch isn't animated on unrelated rows
        // when the table reloads after a tap.
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows, !visibleIndexPaths.isEmpty {
            tableView.reconfigureRows(at: visibleIndexPaths)
        }
        proceedView.configure(viewModel: viewModel)
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

        if viewModel.hasSkonto {
            eventProperties.append(GiniAnalyticsProperty(key: .skontoActive,
                                                         value: viewModel.skontoViewModel?.isSkontoApplied ?? false))
        }
        GiniAnalyticsManager.trackScreenShown(screenName: .returnAssistant, properties: eventProperties)

    }

    // MARK: - Proceed View Setup for Landscape
    private func setupProceedViewInLandscape() {
        landscapeProceedViewContainer.addSubview(proceedView)
        constraintProceedViewInLandscapeContainer()
        applyLandscapeContainerHeightAndAssign()
    }

    private func constraintProceedViewInLandscapeContainer() {
        // Setup internal constraints
        let safeArea = landscapeProceedViewContainer.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            proceedView.topAnchor.constraint(equalTo: safeArea.topAnchor,
                                             constant: Constants.padding),
            proceedView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            proceedView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            proceedView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }

    private func applyLandscapeContainerHeightAndAssign() {
        let targetWidth = view.bounds.width
        let targetSize = CGSize(width: targetWidth,
                                height: UIView.layoutFittingCompressedSize.height)

        // Calculate fitting height via Auto Layout
        let fittingSize = proceedView.systemLayoutSizeFitting(targetSize,
                                                              withHorizontalFittingPriority: .required,
                                                              verticalFittingPriority: .fittingSizeLevel)

        landscapeProceedViewContainer.frame.size.height = fittingSize.height
        tableView.tableFooterView = landscapeProceedViewContainer
    }
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDelegate
    enum Section: Int, CaseIterable {
        case titleCell
        case lineItems
        case addOns
        case skonto
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
        case .skonto: return viewModel.hasSkonto ? 1 : 0
        default: fatalError()
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .titleCell:
            let cellIdentifier = DigitalInvoiceTableViewTitleCell.reuseIdentifier
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                        for: indexPath) as? DigitalInvoiceTableViewTitleCell {
                return cell
            }
            return UITableViewCell()
        case .lineItems:

            if let cell = tableView.dequeueReusableCell(withIdentifier: DigitalLineItemTableViewCell.reuseIdentifier,
                                                        for: indexPath) as? DigitalLineItemTableViewCell {
                if let invoice = viewModel.invoice {
                    let maxCharactersCount = Constants.nameMaxCharactersCount
                    cell.viewModel = DigitalLineItemTableViewCellViewModel(lineItem: invoice.lineItems[indexPath.row],
                                                                           indexPath: indexPath,
                                                                           invoiceNumTotal: invoice.numTotal,
                                                                           invoiceLineItemsCount:
                                                                           invoice.lineItems.count,
                                                                           nameMaxCharactersCount: maxCharactersCount)
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
                if viewModel.skontoViewModel == nil {
                    cell.configureAsBottomTableCell()
                }
                return cell
            }
            assertionFailure("DigitalInvoiceAddOnListCell could not been reused")
            return UITableViewCell()
        case .skonto:
            guard let skontoViewModel = viewModel.skontoViewModel else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceSkontoTableViewCell",
                                                     for: indexPath)
            if let cell = cell as? DigitalInvoiceSkontoTableViewCell {
                cell.delegate = self
                cell.configure(with: skontoViewModel)
                return cell
            }
            assertionFailure("SkontoTableViewCell could not been reused")
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

extension DigitalInvoiceViewController: DigitalInvoiceSkontoTableViewCellDelegate {
    func reloadCell(cell: DigitalInvoiceSkontoTableViewCell) {
        updateValues()
    }

    func editTapped(cell: DigitalInvoiceSkontoTableViewCell) {
        guard let skontoViewModel = viewModel.skontoViewModel else { return }
        let vc = DigitalInvoiceSkontoViewController(viewModel: skontoViewModel)
        GiniAnalyticsManager.track(event: .editTapped, screenName: .returnAssistant)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension DigitalInvoiceViewController {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 24
        static let tabletWidthMultiplier: CGFloat = 0.7
        static let buttonContainerHeight: CGFloat = 160
        static let payButtonHeight: CGFloat = 50
        static let dividerViewHeight: CGFloat = 1
        static let nameMaxCharactersCount: Int = 150
    }
}
