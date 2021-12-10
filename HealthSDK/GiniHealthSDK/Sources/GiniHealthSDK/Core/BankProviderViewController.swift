//
//  BankProviderSelectionViewController.swift
//
//
//  Created by Nadya Karaban on 01.12.21.
//

import GiniHealthAPILibrary
import UIKit

class BankProviderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var backgroundView: UIView!

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scrollDownIndicatorView: UIView!

    @IBOutlet var providersTableView: UITableView!
    private var viewTranslation = CGPoint(x: 0, y: 0)
    
    var giniHealthConfiguration = GiniHealthConfiguration.shared

    var model = BankProviderViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    func configureUI() {
        backgroundView.backgroundColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionDimmedOverlayBackgroundColor)
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        containerView.backgroundColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionScreenBackgroundColor)
        scrollDownIndicatorView.backgroundColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionScrollDownIndicatorViewColor)
        
        titleLabel.font = giniHealthConfiguration.customFont.with(weight: .bold, size: 17, style: .caption1)
        titleLabel.textColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionTitleTextColor)
        titleLabel.text = NSLocalizedStringPreferredFormat("ginihealth.bankprovidersscreen.title",
                                                           comment: "title for bank providers view")
        providersTableView.backgroundView?.backgroundColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionScreenBackgroundColor)
        providersTableView.separatorColor = UIColor.from(giniColor: giniHealthConfiguration.bankSelectionCellSeparatorColor)
        
        providersTableView.reloadData()
        providersTableView.layoutIfNeeded()

        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))

    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .changed:
                viewTranslation = sender.translation(in: view)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            case .ended:
                if viewTranslation.y < 200 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.transform = .identity
                    })
                } else {
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
        self.backgroundView.backgroundColor = .clear
    }

    public static func instantiate(with providers: PaymentProviders) -> BankProviderViewController {
        let vc = (UIStoryboard(name: "BankSelection", bundle: giniHealthBundle())
            .instantiateViewController(withIdentifier: "bankSelectionViewController") as? BankProviderViewController)!
        vc.model.providers = providers

        return vc
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.providers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bankTableViewCellIdentifier",
                                                 for: indexPath) as! BankTableViewCell
        let provider = model.providers[indexPath.row]
        cell.viewModel = BankTableViewCellViewModel(paymentProvider: provider)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        providersTableView.heightAnchor.constraint(equalToConstant:
                                                    providersTableView.contentSize.height).isActive = true
    }
}

class BankTableViewCell: UITableViewCell {
    @IBOutlet var bankIcon: UIImageView!
    @IBOutlet var bankName: UILabel!
    @IBOutlet var selectionIndicator: UIImageView!


    var viewModel: BankTableViewCellViewModel? {
        didSet {
            bankName?.text = viewModel?.name
            bankName?.textColor = UIColor.from(giniColor: viewModel?.mainColor ?? GiniColor(lightModeColor: .black, darkModeColor: .black))
            bankName?.font = GiniHealthConfiguration.shared.customFont.regular
            bankIcon?.image = viewModel?.icon
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected) {
            selectionIndicator.image = UIImageNamedPreferred(named: "selectionIndicator")
        } else {
            selectionIndicator.image = nil
        }
    }
}
