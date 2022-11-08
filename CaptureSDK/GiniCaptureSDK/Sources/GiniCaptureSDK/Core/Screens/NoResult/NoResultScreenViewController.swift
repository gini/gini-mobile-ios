//
//  NoResultScreenViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final public class NoResultScreenViewController: UIViewController {

    var bottomNavigationBar: UIView?
    var navigationBarBottomAdapter: NoResultBottomNavigationBarAdapter?

    public enum NoResultType {
        case image
        case pdf
        case custom(String)

        var description: String {
            switch self {
            case .pdf:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header",
                    comment: "no results header")
            case .image:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header",
                    comment: "no results header")
            case .custom(let text):
                return text
            }
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var enterButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.setTitle(NSLocalizedStringPreferredFormat(
                "ginicapture.noresult.enterManually",
                comment: "Enter manually"),
                             for: .normal)
        return button
    }()

    lazy var retakeButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.retakeImages",
            comment: "Enter manually"),
                              for: .normal)
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        if viewModel.isEnterManuallyHidden() == false {
            stackView.addArrangedSubview(enterButton)
        }
        if viewModel.isRetakePressedHidden() == false {
            stackView.addArrangedSubview(retakeButton)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var header: NoResultHeader = {
        if let header = NoResultHeader().loadNib() as? NoResultHeader {
            header.headerLabel.adjustsFontForContentSizeCategory = true
            header.headerLabel.adjustsFontSizeToFitWidth = true
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("No result header not found")
    }()
    private (set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private let type: NoResultType
    private let viewModel: NoResultScreenViewModel
    private var buttonsHeightConstraint: NSLayoutConstraint?
    private var numberOfButtons: Int {
        return [
            viewModel.isEnterManuallyHidden(),
            viewModel.isRetakePressedHidden()
        ].filter({
            !$0
        }).count
    }

    public init(
        giniConfiguration: GiniConfiguration,
        type: NoResultType,
        viewModel: NoResultScreenViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.type = type
        switch type {
        case .image:
            let tipsDS = HelpTipsDataSource(configuration: giniConfiguration)
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .pdf:
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        case .custom(_):
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if numberOfButtons > 0 {
            tableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: buttonsView.bounds.size.height + CGFloat(numberOfButtons) * GiniMargins.margin,
                right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: GiniMargins.margin,
                right: 0)
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: buttonsView.bounds.size.height + GiniMargins.margin,
            right: 0)
        configureButtonsColors()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        configureCustomTopNavigationBar()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.headerLabel.text = type.description
        header.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        header.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        header.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.error4,
            dark: UIColor.GiniCapture.error1
        ).uiColor()
        configureBottomNavigationBar()
    }

    private func configureCustomTopNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            navigationItem.leftBarButtonItem = nil
            navigationItem.setHidesBackButton(true, animated: true)
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: viewModel,
                action: #selector(viewModel.didPressCancell))
        }
    }

    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight.rawValue
        } else {
            return Constants.twoBUttonsHeight.rawValue
        }
    }

    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            if let bottomBarAdapter = giniConfiguration.noResultNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultNoResultBottomNavigationBarAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                guard let type = self?.type else {
                    return
                }
                switch type {
                case .pdf:
                    self?.dismiss(animated: true)
                default:
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }

            if let adapter = navigationBarBottomAdapter {
                let bottomBar =
                    adapter.injectedView()
                bottomNavigationBar = bottomBar
                bottomBar.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(bottomBar)
                view.bringSubviewToFront(bottomBar)
            }
        }
    }

    private func configureTableView() {
        registerCells()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = tableRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
        }
    }

    private func registerCells() {
        switch type {
        case .pdf:
            tableView.register(
                UINib(
                    nibName: "HelpFormatCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
            tableView.register(
                UINib(
                    nibName: "HelpTipCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
        view.layoutSubviews()
    }
    private func configureButtonsColors() {
        retakeButton.setTitleColor(giniConfiguration.primaryButtonTitleColor.uiColor(), for: .normal)
        retakeButton.backgroundColor = giniConfiguration.primaryButtonBackgroundColor.uiColor()
        retakeButton.layer.borderColor = giniConfiguration.primaryButtonBorderColor.uiColor().cgColor
        retakeButton.layer.cornerRadius = giniConfiguration.primaryButtonCornerRadius
        retakeButton.layer.borderWidth = giniConfiguration.primaryButtonBorderWidth
        retakeButton.layer.shadowRadius = giniConfiguration.primaryButtonShadowRadius
        retakeButton.layer.shadowColor = giniConfiguration.primaryButtonShadowColor.uiColor().cgColor

        enterButton.backgroundColor = giniConfiguration.outlineButtonBackground.uiColor()
        enterButton.layer.cornerRadius = giniConfiguration.outlineButtonCornerRadius
        enterButton.layer.borderWidth = giniConfiguration.outlineButtonBorderWidth
        enterButton.layer.borderColor = giniConfiguration.outlineButtonBorderColor.uiColor().cgColor
        enterButton.layer.shadowRadius = giniConfiguration.outlineButtonShadowRadius
        enterButton.layer.shadowColor = giniConfiguration.outlineButtonShadowColor.uiColor().cgColor
        enterButton.setTitleColor(giniConfiguration.outlineButtonTitleColor.uiColor(), for: .normal)
    }

    private func configureButtons() {
        configureButtonsColors()
        enterButton.addBlurEffect(cornerRadius: 14)
        enterButton.addTarget(viewModel, action: #selector(viewModel.didPressEnterManually), for: .touchUpInside)
        retakeButton.addTarget(viewModel, action: #selector(viewModel.didPressRetake), for: .touchUpInside)
    }

    private func configureBottomBarConstraints() {
        guard let bottomNavigationBar = bottomNavigationBar else {
            return
        }
        NSLayoutConstraint.activate([
            bottomNavigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavigationBar.heightAnchor.constraint(equalToConstant: bottomNavigationBar.frame.height),
            tableView.bottomAnchor.constraint(equalTo: bottomNavigationBar.topAnchor)
        ])
    }

    private func configureConstraints() {
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        tableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        if giniConfiguration.bottomNavigationBarEnabled == false {
            NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin)
            ])
        } else {
            configureBottomBarConstraints()
        }
        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        buttonsHeightConstraint = buttonsConstraint
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.size.height * 0.6),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 13),
            tableView.bottomAnchor.constraint(
                equalTo: buttonsView.bottomAnchor,
                constant: 16
            ),
            buttonsConstraint
        ])
        configureHorizontalConstraints()
        view.layoutSubviews()
    }

    private func configureHorizontalConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.widthAnchor.constraint(equalToConstant: 280)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin),
                buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
        }
    }

    private enum Constants: CGFloat {
        case singleButtonHeight = 50
        case twoBUttonsHeight = 112
    }
}
