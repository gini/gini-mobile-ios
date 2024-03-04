//
//  PaymentInfoViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class PaymentInfoViewController: UIViewController {
    
    var viewModel: PaymentInfoViewModel! {
        didSet {
            setupView()
        }
    }
    
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
        collectionView.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.bankIconsHeight)
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
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        return view
    }()
    
    private lazy var payBillsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = viewModel.payBillsTitleFont
        label.textColor = viewModel.payBillsTitleTextColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsTitleLineHeight
        label.attributedText = NSMutableAttributedString(string: viewModel.payBillsTitleText,
                                                         attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private lazy var payBillsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = viewModel.payBillsDescriptionFont
        label.textColor = viewModel.payBillsDescriptionTextColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.payBillsDescriptionLineHeight
        paragraphStyle.paragraphSpacing = Constants.paragraphSpacing
        label.attributedText = NSMutableAttributedString(string: viewModel.payBillsDescriptionText,
                                                         attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private lazy var questionsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = viewModel.questionsTitleFont
        label.textColor = viewModel.questionsTitleTextColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Constants.questionsTitleLineHeight
        label.attributedText = NSMutableAttributedString(string: viewModel.questionsTitleText,
                                                         attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private lazy var questionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentInfoAnswerTableViewCell.self,
                           forCellReuseIdentifier: PaymentInfoAnswerTableViewCell.identifier)
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
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.titleText
    }
    
    private func setupView() {
        setupViewHierarchy()
        setupViewAttributes()
        setupViewConstraints()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(bankIconsCollectionView)
        contentView.addSubview(poweredByGiniView)
        contentView.addSubview(payBillsTitleLabel)
        contentView.addSubview(payBillsDescriptionLabel)
        contentView.addSubview(questionsTitleLabel)
        contentView.addSubview(questionsTableView)
    }
    
    private func setupViewAttributes() {
        view.backgroundColor = viewModel.backgroundColor
    }
    
    private func setupViewConstraints() {
        setupContentViewConstraints()
        setupBankIconsCollectionViewConstraints()
        setupPoweredByGiniConstraints()
        setupPayBillsConstraints()
        setupQuestionsConstraints()
    }
    
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leftRightPadding),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.leftRightPadding),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Constants.leftRightPadding),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.leftRightPadding),
        ])
    }
    
    private func setupBankIconsCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            bankIconsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leftRightPadding),
            view.trailingAnchor.constraint(equalTo: bankIconsCollectionView.trailingAnchor, constant: Constants.leftRightPadding),
            bankIconsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.bankIconsTopSpacing),
            bankIconsCollectionView.heightAnchor.constraint(equalToConstant: bankIconsCollectionView.frame.height)
        ])
    }
    
    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            poweredByGiniView.topAnchor.constraint(equalTo: bankIconsCollectionView.bottomAnchor, constant: Constants.poweredByGiniTopPadding),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPayBillsConstraints() {
        NSLayoutConstraint.activate([
            payBillsTitleLabel.topAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: Constants.payBillsTitleTopPadding),
            payBillsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            payBillsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            payBillsTitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maxPayBillsTitleHeight),
            payBillsDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            payBillsDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.payBillsDescriptionRightPadding),
            payBillsDescriptionLabel.topAnchor.constraint(equalTo: payBillsTitleLabel.bottomAnchor, constant: Constants.payBillsDescriptionTopPadding),
            payBillsDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minPayBillsDescriptionHeight),
        ])
    }
    
    private func setupQuestionsConstraints() {
        NSLayoutConstraint.activate([
            questionsTitleLabel.topAnchor.constraint(equalTo: payBillsDescriptionLabel.bottomAnchor, constant: Constants.questionsTitleTopPadding),
            questionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            questionsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            questionsTableView.topAnchor.constraint(equalTo: questionsTitleLabel.bottomAnchor),
            questionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            questionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            questionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: Double(viewModel.questions.count) * Constants.questionTitleHeight),
            questionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.leftRightPadding)
        ])
    }
    
    private func extended(section: Int) {
        let isExtended = viewModel.questions[section].isExtended
        viewModel.questions[section].isExtended = !isExtended
        questionsTableView.reloadData()
        questionsTableView.layoutIfNeeded()
        questionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: questionsTableView.contentSize.height).isActive = true
    }
}

extension PaymentInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentInfoBankCollectionViewCell.identifier,
                                                            for: indexPath) as? PaymentInfoBankCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.cellViewModel = PaymentInfoBankCollectionViewCellModel(bankImageIconData: viewModel.paymentProviders[indexPath.row].iconData)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentProviders.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension PaymentInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.bankIconsHeight, height: Constants.bankIconsHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellCount = CGFloat(viewModel.paymentProviders.count)
        if cellCount > 0 {
            if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
                
                let totalCellWidth = cellWidth*cellCount + Constants.bankIconsSpacing * (cellCount - 1)
                let contentWidth = collectionView.frame.size.width - (2 * Constants.leftRightPadding)
                
                if (totalCellWidth < contentWidth) {
                    let padding = (contentWidth - totalCellWidth) / 2.0
                    return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
                } else {
                    return UIEdgeInsets.zero
                }
            }
        }
        return UIEdgeInsets.zero
    }
}

extension PaymentInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.questions[section].isExtended {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentInfoAnswerTableViewCell.identifier,
                                                       for: indexPath) as? PaymentInfoAnswerTableViewCell else {
            return UITableViewCell()
        }
        let answerTableViewCellModel = PaymentInfoAnswerTableViewModel(answerText: viewModel.questions[indexPath.section].description)
        cell.cellViewModel = answerTableViewCellModel
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.questions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = PaymentInfoQuestionHeaderViewCell(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.questionTitleHeight))
        viewHeader.headerViewModel = PaymentInfoQuestionHeaderViewModel(title: viewModel.questions[section].title, isExtended: viewModel.questions[section].isExtended)
        viewHeader.didTapSelectButton = { [weak self] in
            self?.extended(section: section)
        }
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.questionTitleHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.questionSectionSeparatorHeight))
        separatorView.backgroundColor = viewModel.separatorColor
        return separatorView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.questionSectionSeparatorHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension PaymentInfoViewController {
    private enum Constants {
        static let paragraphSpacing = 10.0
        
        static let leftRightPadding = 16.0
        
        static let bankIconsSpacing = 5.0
        static let bankIconsTopSpacing = 15.0
        static let bankIconsHeight = 36.0
        
        static let poweredByGiniTopPadding = 7.0
        
        static let payBillsTitleTopPadding = 16.0
        static let payBillsTitleLineHeight = 1.26
        static let maxPayBillsTitleHeight = 100.0
        static let payBillsDescriptionTopPadding = 8.0
        static let payBillsDescriptionRightPadding = 15.0
        static let payBillsDescriptionLineHeight = 1.32
        static let minPayBillsDescriptionHeight = 100.0
        
        static let questionsTitleTopPadding = 24.0
        static let questionsTitleLineHeight = 1.28
        
        static let questionTitleHeight = 72.0
        static let questionSectionSeparatorHeight = 1.0
        
    }
}
