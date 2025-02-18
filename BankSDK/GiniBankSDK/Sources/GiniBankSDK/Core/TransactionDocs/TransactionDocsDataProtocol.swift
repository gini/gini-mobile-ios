//
//  TransactionDocsDataProtocol.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/// A public protocol that defines methods and properties for managing the state of transaction documents in a photo payment flow.
/// Conforming types are responsible for tracking, modifying, and handling the state related to attaching documents to a transaction.
public protocol TransactionDocsDataProtocol: AnyObject {

    /// The view controller responsible for presenting document-related views.
    var presentingViewController: UIViewController? { get set }

    /// The list of attached transaction document ids.
    var transactionDocIDs: [String] { get }

    /// The list of attached transaction documents.
    var transactionDocs: [TransactionDoc] { get set }

    /// Allows external apps to set transactions inside the SDK.
    func setTransactions(_ transactions: [[TransactionDoc]])

    /// Sets the selected transaction index.
    func setSelectedTransactionIndex(_ index: Int)

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    func getAlwaysAttachDocsValue() -> Bool

    /// Sets the "Always Attach Documents" setting to a given value.
    /// - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
    func setAlwaysAttachDocs(_ value: Bool)
}
