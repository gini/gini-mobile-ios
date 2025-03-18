//
//  TransactionDocsDataProtocol.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/**
 A public protocol that defines methods and properties for managing transaction documents in a photo payment flow.
Conforming types are responsible for tracking, modifying, and handling the state related to attaching documents to a transaction.
 */
public protocol TransactionDocsDataProtocol: AnyObject {
    /**
    The view controller responsible for presenting document-related views.
     */
    var presentingViewController: UIViewController? { get set }

    /**
     The list of attached transaction documents.
    */
    var transactionDocs: [GiniTransactionDoc] { get set }

    /**
     Retrieves the current value of the "Always Attach Documents" setting.

     - Returns: A `Bool` representing whether documents should always be attached to the transaction.
     */
    func getAlwaysAttachDocsValue() -> Bool

    /**
     Sets the "Always Attach Documents" setting to a given value.

     - Parameters:
     - value: A `Bool` indicating whether documents should always be attached to the transaction.
     */
    func setAlwaysAttachDocs(_ value: Bool)

    // MARK: - Multiple transactions
    /**
     Sets the transactions and creates a `TransactionDocsViewModel` for each.
     This method allows to provide multiple transactions, each containing a list of documents.

     - Parameters:
     - transactions: A nested array of `GiniTransaction`
     */
    func setTransactions(_ transactions: [GiniTransaction])

    /**
     Sets the selected transaction identifier within the SDK.
     This determines which transaction's documents will be accessed and displayed.

     - Parameters:
     - identifier: A `String` representing the identifier of the transaction to select.
     */
    func setSelectedTransaction(_ identifier: String)
}
