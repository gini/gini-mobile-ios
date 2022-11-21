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

    var buttonsView = ButtonsView(frame: CGRect.zero)
    lazy var errorContent = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let viewModel: NoResultScreenViewModel
    private var buttonsHeightConstraint: NSLayoutConstraint?
    private var numberOfButtons: Int {
        return [
            true,//viewModel.isEnterManuallyHidden(),
            true//viewModel.isRetakePressedHidden()
        ].filter({
            !$0
        }).count
    }

    public init(
        giniConfiguration: GiniConfiguration,
        type: ErrorType,
        viewModel: NoResultScreenViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.viewModel = viewModel
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
            "ginicapture.noresult.title",
            comment: "No result screen title")
        errorHeader.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        errorHeader.headerLabel.text = "Error Type"
        errorHeader.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        errorHeader.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeader)
        view.addSubview(errorContent)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        errorHeader.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.error4,
            dark: UIColor.GiniCapture.error1
        ).uiColor()
        configureConstraints()
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
        errorContent.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
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
            errorContent.bottomAnchor.constraint(
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
                errorContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorContent.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.widthAnchor.constraint(equalToConstant: 280)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorContent.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                errorContent.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin),
                buttonsView.leadingAnchor.constraint(equalTo: errorContent.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: errorContent.trailingAnchor)
            ])
        }
    }

    private enum Constants: CGFloat {
        case singleButtonHeight = 50
        case twoButtonsHeight = 112
    }
}
