//
//  BankProviderSelectionViewController.swift
//
//
//  Created by Nadya Karaban on 01.12.21.
//

import GiniHealthAPILibrary
import UIKit

class BankProviderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let defaults = UserDefaults.standard
    @IBOutlet var backgroundView: UIView!

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scrollDownIndicatorView: UIView!

    @IBOutlet var providersTableView: UITableView!
    private var viewTranslation = CGPoint(x: 0, y: 0)
    private let cellIdentifier = "bankTableViewCellIdentifier"
    private let defaultProviderIdKey = "ginihealth.defaultPaymentProviderId"
    
    private var giniHealthConfiguration = GiniHealthConfiguration.shared

    private var model = BankProviderViewModel()
    private var selectedProvider: PaymentProvider?
    var onSelectedProviderDidChanged: (_ provider: PaymentProvider) -> Void = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        configureUI()
    }
    
    func setupViewModel() {
        model.onBankSelection = { [weak self] provider in
            DispatchQueue.main.async {
                self?.saveDefaultPaymentProvider(provider: provider)
            }
        }
        model.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.providersTableView.reloadData()
            }
        }
        selectedProvider = self.fetchDefaultPaymentProvider()
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
        viewTranslation = sender.translation(in: view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .transitionFlipFromBottom, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            self.backgroundView.backgroundColor = .clear
        })
        dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! BankTableViewCell
        cell.viewModel = model.getCellViewModel(at: indexPath)
        return cell
    }
        
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let index = model.providers.firstIndex(where: { $0.id == selectedProvider?.id }), index == indexPath.row {
            (cell as! BankTableViewCell).setSelected(true, animated: true)
            let indexPathToSelect = NSIndexPath(row: indexPath.row, section: 0)
            tableView.selectRow(at: indexPathToSelect as IndexPath, animated: true, scrollPosition: .none)
        }
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
        let newProvider = model.providers[indexPath.row]
        model.onBankSelection(newProvider)
        self.onSelectedProviderDidChanged(newProvider)
        self.dismiss(animated: true)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        providersTableView.heightAnchor.constraint(equalToConstant:
                                                    providersTableView.contentSize.height).isActive = true
    }
    
    func saveDefaultPaymentProvider(provider: PaymentProvider){
        defaults.set(provider.id, forKey: defaultProviderIdKey)
    }
    
    func fetchDefaultPaymentProvider() -> PaymentProvider {
        let providerId = defaults.string(forKey: defaultProviderIdKey)
        return model.providers.first(where: { $0.id == providerId }) ?? model.providers[0]
    }
}
