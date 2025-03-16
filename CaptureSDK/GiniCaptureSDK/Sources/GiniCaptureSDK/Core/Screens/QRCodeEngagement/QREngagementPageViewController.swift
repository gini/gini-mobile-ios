//
//  QREngagementPageViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

// TODO: remove public after tests & integration
public class QREngagementViewController: UIViewController {
    var viewModel: QREngagementViewModel
    private let configuration = GiniConfiguration.shared

    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        return pageController
    }()

    private lazy var pages: [UIViewController] = {
        return viewModel.steps.map { QREngagementStepViewController(step: $0) }
    }()

    private lazy var topView: QREngagementTopView = {
        let top = QREngagementTopView()
        top.translatesAutoresizingMaskIntoConstraints = false
        return top
    }()

    private lazy var horizontalButtonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, nextButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Constants.bottomContainerSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var bottomContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [horizontalButtonStack, skipButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Constants.bottomContainerSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var previousButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = "Zurück"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.addTarget(self, action: #selector(handlePrevious), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.primaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = "Weiter"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()

    private lazy var skipButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: configuration.secondaryButtonConfiguration)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let title = "Zahlung fortsetzen"
        button.setTitle(title, for: .normal)
        button.accessibilityValue = title
        button.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        return button
    }()

    public init(viewModel: QREngagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1,
                                         dark: UIColor.GiniCapture.dark3).uiColor()
        setupViews()
        setupPageViewController()
        updateUI(for: viewModel.currentIndex)

        viewModel.onPageChange = { [weak self] index in
            self?.updateUI(for: index)
        }
    }

    private func setupViews() {
        view.addSubview(topView)
        view.addSubview(bottomContainer)

        let pageContainer = UIView()
        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageContainer)

        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                         constant: Constants.topViewTopSpacing),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            previousButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            previousButton.widthAnchor.constraint(equalTo: nextButton.widthAnchor,
                                                  multiplier: Constants.previousButtonMultiplier),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            skipButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),

            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -Constants.bottomContainerBottom),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Constants.horizontalPadding),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -Constants.horizontalPadding),

            pageContainer.topAnchor.constraint(equalTo: topView.bottomAnchor),
            pageContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainer.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor,
                                                  constant: -Constants.pageContainerSpacing)
        ])

        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainer.addSubview(pageViewController.view)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }

    private func setupPageViewController() {
        pageViewController.setViewControllers([pages[viewModel.currentIndex]],
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
    }

    private func updateUI(for index: Int) {
        topView.update(currentStep: index + 1, totalSteps: viewModel.steps.count)
        // TODO: remove it after integration. Just to avoid crash
        previousButton.isHidden = index == 0
        previousButton.isEnabled = (index > 0)
        nextButton.isEnabled = (index < viewModel.steps.count - 1)
    }

    @objc private func handleNext() {
        let newIndex = min(viewModel.currentIndex + 1, pages.count - 1)
        guard newIndex != viewModel.currentIndex else { return }
        guard newIndex != viewModel.currentIndex else { return }
        pageViewController.setViewControllers([pages[newIndex]], direction: .forward, animated: true, completion: nil)
        viewModel.setPage(index: newIndex)
    }

    @objc private func handlePrevious() {
        let newIndex = max(viewModel.currentIndex - 1, 0)
        guard newIndex != viewModel.currentIndex else { return }
        pageViewController.setViewControllers([pages[newIndex]], direction: .reverse, animated: true, completion: nil)
        viewModel.setPage(index: newIndex)
    }

    @objc private func handleSkip() {
        // TODO: screen close
    }
}

private extension QREngagementViewController {
    enum Constants {
        static let topViewTopSpacing: CGFloat = 0
        static let bottomContainerBottom: CGFloat = 24
        static let bottomContainerSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let pageContainerSpacing: CGFloat = 8
        static let buttonHeight: CGFloat = 50
        static let previousButtonMultiplier: CGFloat = 126/205
    }
}
