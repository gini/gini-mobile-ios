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
 View model class for review screen
  */
public class BankProviderViewModel: NSObject {

    var onBankSelection: () -> Void = {}

    var providers: PaymentProviders = []

    private var cellViewModels = [BankTableViewCellViewModel]() {
        didSet {
            //self.reloadCollectionViewClosure()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    func getCellViewModel(at indexPath: IndexPath) -> BankTableViewCellViewModel {
        return cellViewModels[indexPath.section]
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

