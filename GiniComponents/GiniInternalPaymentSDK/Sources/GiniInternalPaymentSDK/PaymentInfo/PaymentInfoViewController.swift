//
//  PaymentInfoViewController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class PaymentInfoViewController: UIViewController {
    let viewModel: PaymentInfoViewModel

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var bankIconsCollectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumInteritemSpacing = Constants.bankIconsSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.bankIconsWidth)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.register(PaymentInfoBankCollectionViewCell.self,
                                forCellWithReuseIdentifier: PaymentInfoBankCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
    }()
    
    private lazy var payBillsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = viewModel.configuration.payBillsTitleFont
        label.textColor = viewModel.configuration.payBillsTitleColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsTitleLineHeight
        label.attributedText = NSMutableAttributedString(string: viewModel.strings.payBillsTitleText,
                                                         attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private lazy var payBillsDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.attributedText = viewModel.payBillsDescriptionAttributedText
        textView.linkTextAttributes = viewModel.payBillsDescriptionLinkAttributes
        return textView
    }()
    
    private lazy var questionsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = viewModel.configuration.questionsTitleFont
        label.textColor = viewModel.configuration.questionsTitleColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.questionsTitleLineHeight
        label.attributedText = NSMutableAttributedString(string: viewModel.strings.questionsTitleText,
                                                         attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private lazy var questionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: PaymentInfoAnswerTableViewCell.self)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.questionTitleHeight
        tableView.estimatedSectionHeaderHeight = Constants.questionTitleHeight
        tableView.estimatedSectionFooterHeight = 1.0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    private var heightsQuestionsTableView: [NSLayoutConstraint] = []
    
    public init(viewModel: PaymentInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.strings.titleText
        self.setupView()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //NotificationCenter.default.post(name: .paymentInfoDissapeared, object: nil)
    }

    private func setupView() {
        setupViewHierarchy()
        setupViewAttributes()
        setupViewConstraints()
        setupViewVisibility()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(bankIconsCollectionView)
        contentView.addSubview(poweredByGiniView)
        contentView.addSubview(payBillsTitleLabel)
        contentView.addSubview(payBillsDescriptionTextView)
        contentView.addSubview(questionsTitleLabel)
        contentView.addSubview(questionsTableView)
    }
    
    private func setupViewAttributes() {
        view.backgroundColor = viewModel.configuration.backgroundColor
    }
    
    private func setupViewConstraints() {
        setupContentViewConstraints()
        setupBankIconsCollectionViewConstraints()
        setupPoweredByGiniConstraints()
        setupPayBillsConstraints()
        setupQuestionsConstraints()
    }

    private func setupViewVisibility() {
        poweredByGiniView.isHidden = !viewModel.shouldShowBrandedView
    }

    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
        ])
    }
    
    private func setupBankIconsCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            bankIconsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bankIconsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bankIconsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.bankIconsTopSpacing),
            bankIconsCollectionView.heightAnchor.constraint(equalToConstant: bankIconsCollectionView.frame.height)
        ])
    }
    
    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            poweredByGiniView.topAnchor.constraint(equalTo: bankIconsCollectionView.bottomAnchor, constant: Constants.poweredByGiniTopPadding),
            poweredByGiniView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPayBillsConstraints() {
        NSLayoutConstraint.activate([
            payBillsTitleLabel.topAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: Constants.payBillsTitleTopPadding),
            payBillsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftRightPadding),
            payBillsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leftRightPadding),
            payBillsTitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maxPayBillsTitleHeight),
            payBillsDescriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftRightPadding),
            payBillsDescriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.payBillsDescriptionRightPadding),
            payBillsDescriptionTextView.topAnchor.constraint(equalTo: payBillsTitleLabel.bottomAnchor, constant: Constants.payBillsDescriptionTopPadding),
            payBillsDescriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minPayBillsDescriptionHeight),
        ])
    }
    
    private func setupQuestionsConstraints() {
        NSLayoutConstraint.activate([
            questionsTitleLabel.topAnchor.constraint(equalTo: payBillsDescriptionTextView.bottomAnchor, constant: Constants.questionsTitleTopPadding),
            questionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftRightPadding),
            questionsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leftRightPadding),
            questionsTableView.topAnchor.constraint(equalTo: questionsTitleLabel.bottomAnchor),
            questionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftRightPadding),
            questionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leftRightPadding),
            questionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: Double(viewModel.questions.count) * Constants.questionTitleHeight),
            questionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.leftRightPadding)
        ])
    }
    
    private func extended(section: Int) {
        let isExtended = viewModel.questions[section].isExtended
        viewModel.questions[section].isExtended = !isExtended
        questionsTableView.reloadData()
        questionsTableView.layoutIfNeeded()
        // Small hack needed to satisfy automatic dimension table view inside scrollView
        NSLayoutConstraint.deactivate(heightsQuestionsTableView)
        heightsQuestionsTableView = [questionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: questionsTableView.contentSize.height)]
        NSLayoutConstraint.activate(heightsQuestionsTableView)
    }
}

extension PaymentInfoViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentInfoBankCollectionViewCell.identifier,
                                                            for: indexPath) as? PaymentInfoBankCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.cellViewModel = viewModel.infoBankCellModel(at: indexPath.row)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentProviders.count
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension PaymentInfoViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.bankIconsWidth, height: Constants.bankIconsHeight)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellCount = Double(viewModel.paymentProviders.count)
        if cellCount > 0 {
                let cellWidth = Constants.bankIconsWidth
                
                let totalCellWidth = cellWidth * cellCount + Constants.bankIconsSpacing * (cellCount - 1)
                let contentWidth = collectionView.frame.size.width - (2 * Constants.leftRightPadding)
                
                if totalCellWidth < contentWidth {
                    let padding = (contentWidth - totalCellWidth) / 2.0
                    return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
                } else {
                    return UIEdgeInsets(top: 0, left: Constants.leftRightPadding, bottom: 0, right: Constants.leftRightPadding)
                }
        }
        return UIEdgeInsets.zero
    }
}

extension PaymentInfoViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.questions[section].isExtended {
            return 1
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaymentInfoAnswerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.cellViewModel = viewModel.infoAnswerCellModel(at: indexPath.section)
        return cell
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.questions.count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = PaymentInfoQuestionHeaderViewCell(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.questionTitleHeight))
        viewHeader.headerViewModel = viewModel.infoQuestionHeaderViewModel(at: section)
        viewHeader.didTapSelectButton = { [weak self] in
            self?.extended(section: section)
        }
        return viewHeader
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.questionTitleHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < viewModel.questions.count - 1 else { return UIView() }
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.questionSectionSeparatorHeight))
        separatorView.backgroundColor = viewModel.configuration.separatorColor
        return separatorView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.questionSectionSeparatorHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.estimatedAnswerHeight
    }
}

extension PaymentInfoViewController {
    private enum Constants {
        static let paragraphSpacing = 10.0
        
        static let leftRightPadding = 16.0
        
        static let bankIconsSpacing = 5.0
        static let bankIconsTopSpacing = 15.0
        static let bankIconsWidth = 36.0
        static let bankIconsHeight = 36.0
        
        static let poweredByGiniTopPadding = 16.0
        
        static let payBillsTitleTopPadding = 16.0
        static let payBillsTitleLineHeight = 1.26
        static let maxPayBillsTitleHeight = 100.0
        static let payBillsDescriptionTopPadding = 8.0
        static let payBillsDescriptionRightPadding = 31.0
        static let minPayBillsDescriptionHeight = 100.0
        
        static let questionsTitleTopPadding = 24.0
        static let questionsTitleLineHeight = 1.28
        
        static let questionTitleHeight = 72.0
        static let questionSectionSeparatorHeight = 1.0
        
        static let estimatedAnswerHeight = 250.0
    }
}
