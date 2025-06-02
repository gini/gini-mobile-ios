//
//  ErrorScreenViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 21/11/2022.
//

import UIKit

class ErrorScreenViewController: UIViewController {
    private var giniConfiguration: GiniConfiguration
    lazy var errorHeader = IconHeader(frame: .zero)

    private lazy var buttonsView: ButtonsView = {
        let view = ButtonsView(
            enterButtonTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.error.enterManually",
                comment: "Enter manually button title"),
            retakeButtonTitle: NSLocalizedStringPreferredFormat(
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
        label.isAccessibilityElement = true
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var navigationBarHeightConstraint: NSLayoutConstraint? = {
        guard let navbar = bottomNavigationBar else {
            return nil
        }
        let constraint = navbar.heightAnchor.constraint(equalToConstant: getBottomBarHeight())
        return constraint
    }()

    let viewModel: BottomButtonsViewModel
    private let errorType: ErrorType
    private var navigationBarBottomAdapter: ErrorNavigationBarBottomAdapter?
    private var buttonsHeightConstraint: NSLayoutConstraint?
    private var buttonsBottomConstraint: NSLayoutConstraint?
    private var bottomNavigationBar: UIView?

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
    public init(giniConfiguration: GiniConfiguration,
                type: ErrorType,
                viewModel: BottomButtonsViewModel) {
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

        sendAnalyticsScreenShown()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        navigationBarHeightConstraint?.constant = getBottomBarHeight()
    }

    private func sendAnalyticsScreenShown() {
        let errorAnalytics = errorType.errorAnalytics()
        var eventProperties = [GiniAnalyticsProperty(key: .errorType, value: errorAnalytics.type)]

        if let code = errorAnalytics.code {
            eventProperties.append(GiniAnalyticsProperty(key: .errorCode, value: code))
        }

        if let reason = errorAnalytics.reason {
            eventProperties.append(GiniAnalyticsProperty(key: .errorMessage, value: reason))
        }

        GiniAnalyticsManager.trackScreenShown(screenName: .error,
                                              properties: eventProperties)
    }

    func setupView() {
        title = NSLocalizedStringPreferredFormat("ginicapture.error.title",
                                                 comment: "Error screen title")
        configureErrorHeader()
        configureErrorContent()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeader)
        view.addSubview(scrollView)
        scrollView.addSubview(errorContent)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        configureButtons()
        configureConstraints()
        configureBottomNavigationBar()
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
        errorContent.textColor = GiniColor(light: UIColor.GiniCapture.dark6, dark: UIColor.GiniCapture.light6).uiColor()
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(self,
                                          action: #selector(didPressEnterManually),
                                          for: .touchUpInside)
        buttonsView.retakeButton.addTarget(self,
                                           action: #selector(didPressRetake),
                                           for: .touchUpInside)
    }

    private func configureBottomNavigationBar() {
        let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.error.backToCamera",
                                                           comment: "Back to camera")
        if giniConfiguration.bottomNavigationBarEnabled {
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.leftBarButtonItem = nil
            if let bottomBar = giniConfiguration.errorNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBar
            } else {
                navigationBarBottomAdapter = DefaultErrorNavigationBarBottomAdapter()
            }
            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.didPressBack()
            }

            if let navigationBar = navigationBarBottomAdapter?.injectedView() {
                bottomNavigationBar = navigationBar
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

        if let heightConstraint = navigationBarHeightConstraint {
            NSLayoutConstraint.activate([
                buttonsView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor,
                                                    constant: -GiniMargins.margin),
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                heightConstraint
            ])
        }

        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }

    @objc func didPressEnterManually() {
        GiniAnalyticsManager.track(event: .enterManuallyTapped, screenName: .error)
        viewModel.didPressEnterManually()
    }

    @objc func didPressRetake() {
        GiniAnalyticsManager.track(event: .backToCameraTapped, screenName: .error)
        viewModel.didPressRetake()
    }

    @objc func didPressBack() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .error)
        viewModel.didPressBack()
    }

    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight
        } else {
            return Constants.twoButtonsHeight
        }
    }

    private func configureConstraints() {
        configureHeaderConstraints()
        configureScrollViewConstraints()
        configureButtonsViewConstraints()
        configureErrorContentConstraints()
        view.layoutSubviews()
    }

    private func configureHeaderConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorHeader.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                               multiplier: Constants.iPadWidthMultiplier),
                errorHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                errorHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
        }
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            errorHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            errorHeader.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.errorHeaderMinHeight),
            errorHeader.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor,
                                                multiplier: Constants.errorHeaderHeightMultiplier)
        ])
    }

    private func configureScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: errorHeader.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor)
        ])
    }

    private func configureButtonsViewConstraints() {
        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        buttonsHeightConstraint = buttonsConstraint
        let bottomConstraint = buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                   constant: -GiniMargins.margin)
        buttonsBottomConstraint = bottomConstraint
        NSLayoutConstraint.activate([
            buttonsConstraint,
            bottomConstraint
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                                     constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                      constant: -GiniMargins.margin)
            ])
        }
    }

    private func configureErrorContentConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorContent.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: Constants.iPadWidthMultiplier)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorContent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                      constant: Constants.textContentMargin),
                errorContent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -Constants.textContentMargin)
            ])
        }

        errorContent.setContentHuggingPriority(.required, for: .vertical)
        errorContent.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            errorContent.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                              constant: Constants.errorContentBottomMargin),
            errorContent.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
        ])
    }
}

private extension ErrorScreenViewController {
    enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let twoButtonsHeight: CGFloat = 112
        static let textContentMargin: CGFloat = 24
        static let errorHeaderMinHeight: CGFloat = 64
        static let errorHeaderHeightMultiplier: CGFloat = 0.3
        static let errorContentBottomMargin: CGFloat = 13
        static let sidePadding: CGFloat = 24
        static let iPadWidthMultiplier: CGFloat = 0.7
        static let iPadButtonsWidth: CGFloat = 280
        static let navigationBarHeight: CGFloat = 110
        static let navigationBarHeightLandscape: CGFloat = 64
    }

    func getBottomBarHeight() -> CGFloat {
        if isiPhoneAndLandscape() {
            return Constants.navigationBarHeightLandscape
        }
        return Constants.navigationBarHeight
    }

    func isiPhoneAndLandscape() -> Bool {
        return UIDevice.current.isIphone && view.currentInterfaceOrientation.isLandscape
    }
}
