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

    // TODO: remove this if you add public access to transactionDocs -> need to change something in TransactionSummaryTableViewController
    /// The list of attached transaction document ids.
    var transactionDocIDs: [String] { get }

    /// The list of attached transaction documents.
    var transactionDocs: [TransactionDoc] { get set }

    /// Retrieves the current view model for transaction documents.
    /// - Returns: An optional `TransactionDocsViewModel` instance if available.
    func getViewModel() -> TransactionDocsViewModel?

    /// A closure that handles the loading of document data.
    var loadData: (() -> Void)? { get set }

    /// Retrieves the current value of the "Always Attach Documents" setting.
    /// - Returns: A `Bool` representing whether documents should always be attached to the transaction.
    func getAlwaysAttachDocsValue() -> Bool

    /// Sets the "Always Attach Documents" setting to a given value.
    /// - Parameter value: A `Bool` indicating whether documents should always be attached to the transaction.
    func setAlwaysAttachDocs(_ value: Bool)
}
