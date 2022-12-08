//
//  ErrorScreenViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ErrorScreenViewController: UIViewController {

    var bottomNavigationBar: UIView?
    var navigationBarBottomAdapter: ErrorBottomNavigationBarAdapter?
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
                comment: "Enter manually button title"),
            secondTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.backToCamera",
                comment: "Back to camera button title"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.enterButton.isHidden = viewModel.isEnterManuallyHidden()
        view.retakeButton.isHidden = viewModel.isRetakePressedHidden()
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
    private let documentType: GiniCaptureDocumentType
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
        documentType: GiniCaptureDocumentType,
        viewModel: BottomButtonsViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.viewModel = viewModel
        self.errorType = type
        self.documentType = documentType
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
        configureErrorHeader()
        configureErrorContent()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeader)
        view.addSubview(errorContent)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        configureButtons()
        configureBottomNavigationBar()
        configureCustomTopNavigationBar()
        configureConstraints()
    }

    private func configureErrorHeader() {
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

    private func configureErrorContent() {
        errorContent.text = errorType.content()
        errorContent.font = giniConfiguration.textStyleFonts[.body]
        errorContent.textColor = GiniColor(light: UIColor.GiniCapture.dark6, dark: UIColor.GiniCapture.dark7).uiColor()
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

    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            if let bottomBarAdapter = giniConfiguration.errorNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultErrorBottomNavigationBarAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in

                self?.viewModel.didPressCancell()
                switch self?.documentType {
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

    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight.rawValue
        } else {
            return Constants.twoButtonsHeight.rawValue
        }
    }

    private func configureBottomBarConstraints() {
        guard let bottomNavigationBar = bottomNavigationBar else {
            return
        }
        NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(
                equalTo: bottomNavigationBar.topAnchor,
                constant: -GiniMargins.margin
            ),
            bottomNavigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavigationBar.heightAnchor.constraint(equalToConstant: bottomNavigationBar.frame.height)
        ])
    }

    private func configureConstraints() {
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        errorContent.setContentHuggingPriority(.required, for: .vertical)
        errorContent.setContentCompressionResistancePriority(.required, for: .vertical)

        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        if giniConfiguration.bottomNavigationBarEnabled == false {
            NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin)
            ])
        } else {
            configureBottomBarConstraints()
        }
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
                buttonsView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin)
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
