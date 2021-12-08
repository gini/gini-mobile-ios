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

    var isLoading: Bool = false {
        didSet {
           // self.updateLoadingStatus()
        }
    }
    
    var isImagesLoading: Bool = false {
        didSet {
           // self.updateImagesLoadingStatus()
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> BankTableViewCellViewModel {
        return cellViewModels[indexPath.section]
    }


}

struct BankTableViewCellViewModel {
    let name: String?
    let icon: UIImage
    let mainColor: GiniColor
    
    init(paymentProvider: PaymentProvider){
        name = paymentProvider.name
        icon = UIImage.init(named: "bank", in: Bundle.module, compatibleWith: nil) ?? UIImage()
        mainColor = GiniColor(lightModeColor: .black, darkModeColor: .darkGray)
    }
}
