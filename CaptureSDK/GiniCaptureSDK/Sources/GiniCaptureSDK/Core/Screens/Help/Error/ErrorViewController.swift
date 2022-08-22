//
//  ErrorViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//

import UIKit

final public class ErrorViewController: UIViewController {
    public enum ErrorType: String {
        case invalidDocument = "Could not retrieve any information from your documents."
        case other = "Some other error occured."
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var enterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var retakeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [enterButton, retakeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    lazy var errorHeader: ErrorHeader = {
        if let header = UINib(
            nibName: "ErrorHeader",
            bundle: giniCaptureBundle()
        ).instantiate(withOwner: nil, options: nil)[0]  as? ErrorHeader {
            header.headerLabel.text = errorType.rawValue
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("Error header not found")
    }()

    private (set) var dataSource: HelpFormatsDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private let errorType: ErrorType

    public init(giniConfiguration: GiniConfiguration, errorType: ErrorType) {
        self.giniConfiguration = giniConfiguration
        self.errorType = errorType
        self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.error.title",
            comment: "Error screen title")
        view.backgroundColor = UIColorPreferred(named: "helpBackground")
        view.addSubview(errorHeader)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
    }

    private func configureTableView() {
        tableView.register(
            UINib(
                nibName: "HelpFormatCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
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
        tableView.separatorStyle = .none
        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
        }
    }

    private func configureButtons() {
        enterButton.setTitle(NSLocalizedStringPreferredFormat(
                "ginicapture.error.enterManually",
                comment: "Enter manually"),
                             for: .normal)
        enterButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        enterButton.titleLabel?.adjustsFontForContentSizeCategory = true
        enterButton.setTitleColor(UIColorPreferred(named: "grayLabel"), for: .normal)
        enterButton.layer.cornerRadius = 14
        enterButton.backgroundColor = UIColorPreferred(named: "helpBackground")
        enterButton.layer.borderWidth = 1.0
        enterButton.layer.borderColor = UIColorPreferred(named: "grayLabel")?.cgColor ?? UIColor.white.cgColor
        enterButton.addTarget(self, action: #selector(enterPressed), for: .touchUpInside)
        retakeButton.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.error.retakeImages",
            comment: "Enter manually"),
                              for: .normal)
        retakeButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        retakeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retakeButton.setTitleColor(UIColorPreferred(named: "labelWhite"), for: .normal)
        retakeButton.layer.cornerRadius = 14
        retakeButton.backgroundColor = UIColorPreferred(named: "systemBlue")
        retakeButton.addTarget(self, action: #selector(retakePressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didPressCancel))
    }

    @objc func didPressCancel() {
        dismiss(animated: true)
    }

    private func configureConstraints() {
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.addConstraints([
            errorHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: GiniMargins.margin),
            errorHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: errorHeader.bottomAnchor, constant: 26),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GiniMargins.horizontalMargin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GiniMargins.horizontalMargin),
            tableView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -32),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GiniMargins.horizontalMargin),
            buttonsView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -GiniMargins.horizontalMargin),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 130)
        ])
        view.layoutSubviews()
    }

    // MARK: - Button Actions

    @objc func enterPressed() {
        self.dismiss(animated: true)
    }

    @objc func retakePressed() {
        self.dismiss(animated: true)
    }
}
