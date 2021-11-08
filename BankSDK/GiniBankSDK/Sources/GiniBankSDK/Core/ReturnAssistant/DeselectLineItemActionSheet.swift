//
//  DeselectLineItemActionSheet.swift
// GiniBank
//
//  Created by Maciej Trybilo on 02.01.20.
//

import UIKit
import GiniBankAPILibrary

class DeselectLineItemActionSheet {
    
    func present(from viewController: UIViewController,
                 source: UIView?,
                 returnReasons: [ReturnReason],
                 completion: @escaping (DigitalInvoice.LineItem.SelectedState) -> Void) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: NSLocalizedString("ginibank.digitalinvoice.deselectreasonactionsheet.message",
                                                                       bundle: giniBankBundle(),
                                                                       comment: ""),
                                            preferredStyle: .actionSheet)
        
        for reason in returnReasons {
            
            actionSheet.addAction(UIAlertAction(title: reason.labelInLocalLanguageOrGerman,
                                                style: .default,
                                                handler:
                { _ in
                    completion(.deselected(reason: reason))
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("ginibank.digitalinvoice.deselectreasonactionsheet.action.cancel",
                                                                     bundle: giniBankBundle(),
                                                                     comment: ""),
                                            style: .cancel,
                                            handler: { _ in
                                                completion(.selected)
        }))
        
        actionSheet.popoverPresentationController?.sourceView = source
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}
