//
//  File.swift
//  
//
//  Created by Nadya Karaban on 02.12.21.
//

import Foundation

import GiniHealthAPILibrary
import UIKit
/**
 View model class for bank selection screen
  */
public class BankProviderViewModel: NSObject {

    var onBankSelection: (_ provider: PaymentProvider) -> Void = { _ in }
    var reloadTableViewClosure: () -> Void = {}

    var providers: PaymentProviders = [] {
        didSet {
            var vms = [BankTableViewCellViewModel]()
            for provider in providers {
                let vm = BankTableViewCellViewModel(paymentProvider: provider)
                vms.append(vm)
            }
            cellViewModels.append(contentsOf: vms)
        }
    }
    
    var selectedPaymentProvider: PaymentProvider? {
        didSet {
            if let provider = selectedPaymentProvider {
                self.onBankSelection(provider)
            }
        }
    }

    private var cellViewModels = [BankTableViewCellViewModel]() {
        didSet {
            self.reloadTableViewClosure()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    func getCellViewModel(at indexPath: IndexPath) -> BankTableViewCellViewModel {
        return cellViewModels[indexPath.row]
    }

}

struct BankTableViewCellViewModel {
    let name: String?
    let icon: UIImage
    
    init(paymentProvider: PaymentProvider){
        name = paymentProvider.name
        let imageData =  paymentProvider.iconData
        if let image = UIImage(data: imageData){
            icon = image
        } else {
            icon = UIImage()
        }
    }
}

