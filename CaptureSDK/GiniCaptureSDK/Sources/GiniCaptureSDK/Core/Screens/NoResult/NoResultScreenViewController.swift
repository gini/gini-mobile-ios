//
//  NoResultScreenViewController.swift
//  GiniCapture
//
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class NoResultScreenViewController: UIViewController {
    enum NoResultType {
        case image
        case pdf
        case qrCode
        case xml
        case custom(String)

        var description: String {
            switch self {
            case .pdf, .image, .xml:
                return Strings.noResultsHeader
            case .qrCode:
                return Strings.noResultsQRHeader
            case .custom(let text):
                return text
            }
        }
    }

    lazy var tableView: UITableView = {
        var tableView: UITableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var buttonsView: ButtonsView = {
        let view = ButtonsView(secondaryButtonTitle: Strings.enterButtonTitle,
                               primaryButtonTitle: Strings.retakeButtonTitle)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.secondaryButton.isHidden = viewModel.isEnterManuallyHidden()
        view.primaryButton.isHidden = viewModel.isRetakePressedHidden()

        return view
    }()

    lazy var header = IconHeader()
    private(set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let type: NoResultType
    private let viewModel: BottomButtonsViewModel
    private var buttonsBottomConstraint: NSLayoutConstraint?
    private var navigationBarBottomAdapter: ErrorNavigationBarBottomAdapter?

    private var numberOfButtons: Int {
        [viewModel.isEnterManuallyHidden(), viewModel.isRetakePressedHidden()].filter({ !$0 }).count
    }

    public init(giniConfiguration: GiniConfiguration,
                type: NoResultType,
                viewModel: BottomButtonsViewModel) {
        self.giniConfiguration = giniConfiguration
        self.type = type
        switch type {
        case .image:
            let tipsDS = HelpTipsDataSource()
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .pdf, .xml, .custom(_):
            self.dataSource = HelpFormatsDataSource()
        case .qrCode:
            self.dataSource = HelpFormatsDataSource(isQRCodeContent: true)
        }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

        GiniAnalyticsManager.trackScreenShown(screenName: .noResults)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if numberOfButtons > 0 {
            let bottomInset = buttonsView.bounds.size.height + CGFloat(numberOfButtons) * GiniMargins.margin

            tableView.contentInset = UIEdgeInsets(top: 0,
                                                  left: 0,
                                                  bottom: bottomInset,
                                                  right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0,
                                                  left: 0,
                                                  bottom: GiniMargins.margin,
                                                  right: 0)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: buttonsView.bounds.size.height + GiniMargins.margin,
                                              right: 0)
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        configureCustomBottomNavigationBar()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = Strings.screenTitle
        header.iconAccessibilityLabel = Strings.screenTitle
        header.text = type.description
        header.image = UIImageNamedPreferred(named: Constants.alertTriangleImageName)

        view.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                         dark: .GiniCapture.dark2).uiColor()
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
    }

    private func configureCustomBottomNavigationBar() {
        let buttonTitle = Strings.backToCameraTitle
        if giniConfiguration.bottomNavigationBarEnabled {
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.leftBarButtonItem = nil

            if let adapter = giniConfiguration.errorNavigationBarBottomAdapter {
                navigationBarBottomAdapter = adapter
            } else {
                navigationBarBottomAdapter = DefaultErrorNavigationBarBottomAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.didPressBack()
            }

            if let navigationBar = navigationBarBottomAdapter?.injectedView() {
                navigationBar.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(navigationBar)
                layoutBottomNavigationBar(navigationBar)
            }
        } else {
            let backButton = GiniBarButton(ofType: .back(title: buttonTitle))
            backButton.addAction(self, #selector(didPressBack))
            navigationItem.leftBarButtonItem = backButton.barButton
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        buttonsBottomConstraint?.isActive = false

        NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor,
                                                constant: -GiniMargins.margin),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: Constants.navigationBarHeight)
        ])

        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }

    private func configureTableView() {
        registerCells()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = Constants.tableRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionHeaderHeight = Constants.sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
    }

    private func registerCells() {
        let helpSectionHeaderNib = UINib(nibName: "HelpFormatSectionHeader", bundle: giniCaptureBundle())

        switch type {
        case .pdf, .qrCode, .xml:
            let nib = UINib(nibName: "HelpFormatCell", bundle: giniCaptureBundle())
            tableView.register(nib, forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
            let nib = UINib(nibName: "HelpTipCell", bundle: giniCaptureBundle())
            tableView.register(nib, forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }

        tableView.register(helpSectionHeaderNib,
                           forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.tableView.reloadData()
            self?.view.layoutSubviews()
        }
    }

    private func configureButtons() {
        buttonsView.secondaryButton.addTarget(self,
                                          action: #selector(didPressEnterManually),
                                          for: .touchUpInside)
        buttonsView.primaryButton.addTarget(self,
                                           action: #selector(didPressRetake),
                                           for: .touchUpInside)
    }

    @objc func didPressEnterManually() {
        GiniAnalyticsManager.track(event: .enterManuallyTapped, screenName: .noResults)
        viewModel.didPressEnterManually()
    }

    @objc func didPressRetake() {
        GiniAnalyticsManager.track(event: .retakeImagesTapped, screenName: .noResults)
        viewModel.didPressRetake()
    }

    @objc func didPressBack() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .noResults)
        viewModel.didPressBack()
    }

    private func configureHeaderContraints() {
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                header.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: Constants.iPadWidthMultiplier),
                header.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor,
                                           multiplier: Constants.contentHeightMultiplier)
        ])
    }

    private func configureConstraints() {
        configureHeaderContraints()
        configureButtonsViewConstraints()
        configureTableViewConstraints()
        view.layoutSubviews()
    }

    private func configureButtonsViewConstraints() {
        if giniConfiguration.bottomNavigationBarEnabled,
           let navBar = navigationBarBottomAdapter?.injectedView() {
            buttonsBottomConstraint = buttonsView.bottomAnchor.constraint(equalTo: navBar.topAnchor)
        } else {
            buttonsBottomConstraint = buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                          constant: -GiniMargins.margin)
        }

        buttonsBottomConstraint?.isActive = true

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
        }
    }

    private func configureTableViewConstraints() {
        tableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: Constants.iPadWidthMultiplier)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -GiniMargins.margin)
            ])
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor,
                                           constant: Constants.contentTopMargin),
            tableView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor,
                                              constant: Constants.contentBottomMargin)
        ])
    }

    private enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let twoButtonsHeight: CGFloat = 112
        static let tableRowHeight: CGFloat = 44
        static let sectionHeight: CGFloat = 70
        static let sidePadding: CGFloat = 24
        static let contentTopMargin: CGFloat = 13
        static let contentBottomMargin: CGFloat = 16
        static let contentHeight: CGFloat = 62
        static let contentHeightMultiplier: CGFloat = 0.3
        static let iPadWidthMultiplier: CGFloat = 0.7
        static let navigationBarHeight: CGFloat = 114
        static let alertTriangleImageName: String = "alertTriangle"
    }

    private struct Strings {
        static let noResultsHeader = NSLocalizedStringPreferredFormat("ginicapture.noresult.header",
                                                                      comment: "no results header")

        static let noResultsQRHeader = NSLocalizedStringPreferredFormat("ginicapture.noresult.header.qrcode",
                                                                        comment: "no results header for qr codes")

        static let enterButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.noresult.enterManually",
                                                                       comment: "Enter manually button title")

        static let retakeButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.noresult.retakeImages",
                                                                        comment: "Retake images button title")

        static let screenTitle = NSLocalizedStringPreferredFormat("ginicapture.noresult.title",
                                                                  comment: "No result screen title")

        static let backToCameraTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.error.backToCamera",
                                                                        comment: "Back")
    }
}
