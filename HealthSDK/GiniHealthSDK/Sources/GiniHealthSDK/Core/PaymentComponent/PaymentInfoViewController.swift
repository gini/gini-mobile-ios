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
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.heightTitleView)
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.titleText
        label.font = viewModel.titleFont
        label.textColor = viewModel.titleTextColor
        return label
    }()
    
    private lazy var closeTitleIconImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.closeTitleIcon.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.closeIconSize, height: Constants.closeIconSize)
        imageView.tintColor = viewModel.closeIconAccentColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnCloseIcon)))
        return imageView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupView() {
        setupViewHierarchy()
        setupViewAttributes()
        setupViewConstraints()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeTitleIconImageView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(bankIconsCollectionView)
        contentView.addSubview(poweredByGiniView)
        contentView.addSubview(payBillsTitleLabel)
        contentView.addSubview(payBillsDescriptionLabel)
    }
    
    private func setupViewAttributes() {
        view.backgroundColor = viewModel.backgroundColor
    }
    
    private func setupViewConstraints() {
        setupTitleViewConstraints()
        setupContentViewConstraints()
        setupBankIconsCollectionViewConstraints()
        setupPoweredByGiniConstraints()
        setupPayBillsConstraints()
    }
    
    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: titleView.frame.height),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: Constants.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            closeTitleIconImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeTitleIconImageView.heightAnchor.constraint(equalToConstant: closeTitleIconImageView.frame.height),
            closeTitleIconImageView.widthAnchor.constraint(equalToConstant: closeTitleIconImageView.frame.width),
            closeTitleIconImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: Constants.leftRightPadding)
        ])
    }
    
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
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
            payBillsDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.leftRightPadding) // TODO
        ])
    }
    
    @objc
    private func tapOnCloseIcon() {
        viewModel.didTapOnClose()
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

extension PaymentInfoViewController {
    private enum Constants {
        static let paragraphSpacing = 10.0
        
        static let heightTitleView = 48.0
        static let titleTopPadding = 6.0
        
        static let closeIconSize = 24.0
        
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
    }
}
