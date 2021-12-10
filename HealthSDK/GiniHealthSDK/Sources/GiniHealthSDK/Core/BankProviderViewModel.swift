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
    let mainColor: GiniColor
    
    init(paymentProvider: PaymentProvider){
        name = paymentProvider.name
        let imageData =  paymentProvider.iconData
        if let image = UIImage(data: imageData){
            icon = image
        } else{
            icon = UIImage()
        }
//        let mainColorString = String.hexFrom(string: paymentProvider.colors.background)
//        if let backgroundHexColor = UIColor(hex: mainColorString){
//            mainColor = GiniColor(lightModeColor: backgroundHexColor, darkModeColor: backgroundHexColor)
//        } else {
//            mainColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
//        }
        
        let textColorString = String.hexFrom(string: paymentProvider.colors.text)
        if let textHexColor = UIColor(hex: textColorString){
            mainColor = GiniColor(lightModeColor: textHexColor, darkModeColor: textHexColor)
        } else {
            mainColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
        }
       
    }
}

