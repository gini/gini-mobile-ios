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
        let view = ButtonsView(firstTitle: NSLocalizedStringPreferredFormat("ginicapture.error.enterManually",
                                                                            comment: "Enter manually button title"),
                               secondTitle: NSLocalizedStringPreferredFormat("ginicapture.error.backToCamera",
                                                                             comment: "Back to camera button title"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.enterButton.isHidden = viewModel.isEnterManuallyHidden()
        view.retakeButton.isHidden = viewModel.isRetakePressedHidden()
        return view
    }()

    lazy var errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        label.textAlignment = .center
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var errorHeaderContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
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
        configureerrorDescriptionLabel()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(scrollView)
        view.addSubview(errorHeaderContentView)
        errorHeaderContentView.addSubview(errorHeader)
        scrollView.addSubview(errorDescriptionLabel)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        configureButtons()
        configureCustomTopNavigationBar()
        configureConstraints()
    }

    private func configureErrorHeader() {
        errorHeaderContentView.backgroundColor = GiniColor(light: .GiniCapture.error4,
                                                           dark: .GiniCapture.error1).uiColor()

        errorHeader.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.error.title",
                                                                                        comment: "Error screen title")
        errorHeader.backgroundColor = .clear
        errorHeader.headerLabel.text = errorType.title()
        errorHeader.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        errorHeader.headerLabel.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        errorHeader.iconImageView.image = UIImageNamedPreferred(named: errorType.iconName())
    }

    private func configureerrorDescriptionLabel() {
        errorDescriptionLabel.text = errorType.content()
        errorDescriptionLabel.font = giniConfiguration.textStyleFonts[.body]
        errorDescriptionLabel.textColor = GiniColor(light: .GiniCapture.dark6,
                                                    dark: .GiniCapture.dark7).uiColor()
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(viewModel,
                                          action: #selector(viewModel.didPressEnterManually),
                                          for: .touchUpInside)
        buttonsView.retakeButton.addTarget(viewModel,
                                           action: #selector(viewModel.didPressRetake),
                                           for: .touchUpInside)
    }

    private func configureCustomTopNavigationBar() {
        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(viewModel, #selector(viewModel.didPressCancell))

        if giniConfiguration.bottomNavigationBarEnabled {
            navigationItem.rightBarButtonItem = cancelButton.barButton

            navigationItem.setHidesBackButton(true, animated: true)
        } else {
            navigationItem.leftBarButtonItem = cancelButton.barButton
        }
    }

    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight
        } else {
            return Constants.twoButtonsHeight
        }
    }

    private func configureConstraints() {
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        errorDescriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        errorDescriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )

        buttonsHeightConstraint = buttonsConstraint
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: errorHeader.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),

            errorHeaderContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorHeaderContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeaderContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorHeaderContentView.bottomAnchor.constraint(equalTo: errorHeader.bottomAnchor),

            errorHeader.topAnchor.constraint(equalTo: errorHeaderContentView.topAnchor),
            errorHeader.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.errorHeaderMinHeight),
            errorHeader.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.errorHeaderMaxHeight),
            errorDescriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                                       constant: Constants.errorDescriptionLabelBottomMargin),
            buttonsConstraint,
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -GiniMargins.margin)
        ])
        configureHorizontalConstraints()
        view.layoutSubviews()
    }

    private func configureHorizontalConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorHeader.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
                errorHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                errorDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorDescriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                             multiplier: Constants.iPadWidthMultiplier),
                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Constants.textContentMargin),
                errorHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                errorDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: Constants.textContentMargin),
                errorDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -Constants.textContentMargin),
                errorDescriptionLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),
                buttonsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                                     constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                      constant: -GiniMargins.margin)
            ])
        }
    }
}

private extension ErrorScreenViewController {
    enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let twoButtonsHeight: CGFloat = 112
        static let textContentMargin: CGFloat = 24
        static let iPadButtonsWidth: CGFloat = 280
        static let errorHeaderMinHeight: CGFloat = 64
        static let errorHeaderMaxHeight: CGFloat = 180
        static let errorDescriptionLabelBottomMargin: CGFloat = 13
        static let iPadWidthMultiplier: CGFloat = 0.7
    }
}
