//
//  ErrorScreenViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ErrorScreenViewController: UIViewController {

    enum ErrorType {
        case connection
        case uploadIssue
        case serverError
        case authentication
        case unexpected
    }
    private var giniConfiguration: GiniConfiguration
    lazy var errorHeader: NoResultHeader = {
        if let header = NoResultHeader().loadNib() as? NoResultHeader {
            header.headerLabel.adjustsFontForContentSizeCategory = true
            header.headerLabel.adjustsFontSizeToFitWidth = true
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("No result header not found")
    }()

    lazy var buttonsView = {
        let view = ButtonsView(
            firstTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.enterManually",
                comment: "Enter manually"),
            secondTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.backToCamera",
                comment: "Enter manually"))
        return view
    }()

    lazy var errorContent = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let viewModel: BottomButtonsViewModel
    private let errorType: ErrorType
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
        type: ErrorType,
        viewModel: BottomButtonsViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.viewModel = viewModel
        self.errorType = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.error.title",
            comment: "Error screen title")
        errorHeader.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.error.title",
            comment: "Error screen title")
        errorHeader.headerLabel.text = getErrorTitle(type: errorType)
        errorHeader.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        errorHeader.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        errorContent.text = getErrorContent(type: errorType)
        
        errorContent.textAlignment = .left
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeader)
        view.addSubview(errorContent)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        errorHeader.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.error4,
            dark: UIColor.GiniCapture.error1
        ).uiColor()
        configureButtons()
        configureCustomTopNavigationBar()
        configureConstraints()
        errorContent
            .sizeToFit()
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(viewModel, action: #selector(viewModel.didPressEnterManually), for: .touchUpInside)
        buttonsView.retakeButton.addTarget(viewModel, action: #selector(viewModel.didPressRetake), for: .touchUpInside)
    }
    
    private func configureCustomTopNavigationBar() {
        navigationItem.leftBarButtonItem =  UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: viewModel,
            action: #selector(viewModel.didPressCancell))
    }
    
    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight.rawValue
        } else {
            return Constants.twoButtonsHeight.rawValue
        }
    }

    private func configureConstraints() {
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        errorContent.setContentHuggingPriority(.required, for: .vertical)
        errorContent.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
        buttonsView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -GiniMargins.margin)
        ])

        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        buttonsHeightConstraint = buttonsConstraint
        NSLayoutConstraint.activate([
            errorHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            errorHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorHeader.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            errorContent.topAnchor.constraint(equalTo: errorHeader.bottomAnchor, constant: 13),
            buttonsConstraint
        ])
        configureHorizontalConstraints()
        view.layoutSubviews()
    }

    private func configureHorizontalConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorContent.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.widthAnchor.constraint(equalToConstant: 280)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorContent.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 24),
                errorContent.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -24),
                buttonsView.leadingAnchor.constraint(equalTo: errorContent.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: errorContent.trailingAnchor)
            ])
        }
    }

    private func getErrorContent(type: ErrorType) -> String {
        switch type {
        case .connection:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.connection.content",
                comment: "Connection error")
        case .authentication:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.authentication.content",
                comment: "Authentication error")
        case .serverError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.serverError.content",
                comment: "Server error")
        case .unexpected:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.unexpected.content",
                comment: "Unexpected error")
        case .uploadIssue:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.uploadIssue.content",
                comment: "Upload error")
        }
    }

    private func getErrorTitle(type: ErrorType) -> String {
        switch type {
        case .connection:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.connection.title",
                comment: "Connection error")
        case .authentication:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.authentication.title",
                comment: "Authentication error")
        case .serverError:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.serverError.title",
                comment: "Server error")
        case .unexpected:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.unexpected.title",
                comment: "Unexpected error")
        case .uploadIssue:
            return NSLocalizedStringPreferredFormat(
                "ginicapture.error.uploadIssue.title",
                comment: "Upload error")
        }
    }

    private enum Constants: CGFloat {
        case singleButtonHeight = 50
        case twoButtonsHeight = 112
    }
}
