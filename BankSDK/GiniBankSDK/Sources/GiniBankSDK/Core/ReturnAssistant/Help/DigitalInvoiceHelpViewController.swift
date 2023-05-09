//
//  DigitalInvoiceHelpViewController.swift
//  
//
//  Created by David Vizaknai on 15.02.2023.
//

import GiniCaptureSDK
import UIKit

final class DigitalInvoiceHelpViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        return stackView
    }()

    private lazy var scrollViewBottomConstraint =
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Constants.padding)
    private var navigationBarBottomAdapter: DigitalInvoiceHelpNavigationBarBottomAdapter?

    private let viewModel: DigitalInvoiceHelpViewModel

    init(viewModel: DigitalInvoiceHelpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupConstraints()
        configureBottomNavigationBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.screenTitle",
                                                         comment: "help screen title")
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2).uiColor()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.backToInvoice",
                                                                       comment: "Digital Invoice")
        let backButton = GiniBarButton(ofType: .back(title: backButtonTitle))
        backButton.addAction(self, #selector(dismissViewController))
        navigationItem.leftBarButtonItem = backButton.barButton

        viewModel.helpSections.forEach { [weak self] sectionContent in
            let view = DigitalInvoiceHelpSectionView(content: sectionContent)
            self?.stackView.addArrangedSubview(view)
        }

        stackView.addArrangedSubview(UIView())
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            scrollViewBottomConstraint,

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Constants.padding),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.padding),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
            ])
        }
    }

    private func configureBottomNavigationBar() {
        let configuration = GiniBankConfiguration.shared
        if configuration.bottomNavigationBarEnabled {
            if let bottomBar = configuration.digitalInvoiceHelpNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBar
            } else {
                navigationBarBottomAdapter = DefaultDigitalInvoiceHelpNavigationBarBottomAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.dismissViewController()
            }

            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.leftBarButtonItem = nil

            if let navigationBar =
                navigationBarBottomAdapter?.injectedView() {
                navigationBar.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(navigationBar)

                layoutBottomNavigationBar(navigationBar)
            }
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        scrollViewBottomConstraint.isActive = false
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 114)
        ])
        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }

    @objc
    private func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}

private extension DigitalInvoiceHelpViewController {
    enum Constants {
        static let padding: CGFloat = 24
        static let spacing: CGFloat = 36
    }
}
