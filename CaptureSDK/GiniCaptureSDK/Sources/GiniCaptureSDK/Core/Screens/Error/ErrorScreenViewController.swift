//
//  ErrorScreenViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ErrorScreenViewController: UIViewController {

    private var giniConfiguration: GiniConfiguration
    lazy var errorHeader: IconHeader = {
        if let header = IconHeader().loadNib() as? IconHeader {
            header.headerLabel.adjustsFontForContentSizeCategory = true
            header.headerLabel.adjustsFontSizeToFitWidth = true
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("Error header not found")
    }()

    lazy var buttonsView: ButtonsView = {
        let view = ButtonsView(
            firstTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.enterManually",
                comment: "Enter manually"),
            secondTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.backToCamera",
                comment: "Back to camera"))
        view.translatesAutoresizingMaskIntoConstraints = false
        if viewModel.isEnterManuallyHidden() == false {
            view.enterButton.isHidden = false
        } else {
            view.enterButton.isHidden = true
        }
        if viewModel.isRetakePressedHidden() == false {
            view.retakeButton.isHidden = false
        } else {
            view.retakeButton.isHidden = true
        }
        return view
    }()

    lazy var errorContent: UILabel = {
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

    /**
     Designated initializer for the `ErrorScreenViewController` which shows generic error screen
     
     - parameter giniConfiguration: `GiniConfiguration` instance.
     - parameter type: `ErrorType` type of generic error.
     - parameter viewModel: `BottomButtonsViewModel` provide actions for buttons .
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
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
        setupErrorHeader()
        errorContent.text = errorType.content()
        errorContent.font = giniConfiguration.textStyleFonts[.body]
        errorContent.textColor = GiniColor(light: UIColor.GiniCapture.dark6, dark: UIColor.GiniCapture.dark7).uiColor()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeader)
        view.addSubview(errorContent)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        configureButtons()
        configureCustomTopNavigationBar()
        configureConstraints()
    }

    private func setupErrorHeader() {
        errorHeader.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.error.title",
            comment: "Error screen title")
        errorHeader.headerLabel.text = errorType.title()
        errorHeader.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        errorHeader.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        errorHeader.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.error4,
            dark: UIColor.GiniCapture.error1
        ).uiColor()
        errorHeader.iconImageView.image = UIImageNamedPreferred(named: errorType.iconName())
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(
            viewModel,
            action: #selector(viewModel.didPressEnterManually),
            for: .touchUpInside)
        buttonsView.retakeButton.addTarget(
            viewModel,
            action: #selector(viewModel.didPressRetake),
            for: .touchUpInside)
    }

    private func configureCustomTopNavigationBar() {
        // TODO: add handloing bottom navigation bar
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
            errorHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorHeader.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.errorHeaderMinHeight.rawValue),
            errorContent.topAnchor.constraint(
                equalTo: errorHeader.bottomAnchor,
                constant: Constants.errorContentBottomMargin.rawValue),
            buttonsConstraint
        ])
        configureHorizontalConstraints()
        view.layoutSubviews()
    }

    private func configureHorizontalConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorContent.widthAnchor.constraint(
                    equalTo: view.widthAnchor,
                    multiplier: Constants.iPadWidthMultiplier.rawValue),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.widthAnchor.constraint(
                    equalToConstant: Constants.iPadButtonsWidth.rawValue)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorContent.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.textContentMargin.rawValue),
                errorContent.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -Constants.textContentMargin.rawValue),
                buttonsView.leadingAnchor.constraint(equalTo: errorContent.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: errorContent.trailingAnchor)
            ])
        }
    }

    private enum Constants: CGFloat {
        case singleButtonHeight = 50
        case twoButtonsHeight = 112
        case textContentMargin = 24
        case iPadButtonsWidth = 280
        case errorHeaderMinHeight = 64
        case errorContentBottomMargin = 13
        case iPadWidthMultiplier = 0.7
    }
}
