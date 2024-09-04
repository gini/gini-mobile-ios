//
//  HardcodedInvoicesController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary

protocol HardcodedInvoicesControllerProtocol: AnyObject {
    func obtainInvoicePhotosHardcoded(completion: @escaping (([Data]) -> Void))
    func storeInvoicesWithExtractions(invoices: [DocumentWithExtractions])
    func getInvoicesWithExtractions() -> [DocumentWithExtractions]
    func appendInvoiceWithExtractions(invoice: DocumentWithExtractions)
    func updateDocumentExtractions(documentId: String, extractions: ExtractionResult)
}

final class HardcodedInvoicesController: HardcodedInvoicesControllerProtocol {
    func obtainInvoicePhotosHardcoded(completion: @escaping (([Data]) -> Void)) {
        var invoicesData: [Data] = []
        for i in 1 ... Constants.numberOfInovices {
            let invoiceTitle = "\(Constants.invoiceTitle)\(i)"
            if let fileURL = Bundle.main.url(forResource: invoiceTitle, withExtension: Constants.invoiceFileFormat) {
                do {
                    let invoiceData = try Data(contentsOf: fileURL)
                    invoicesData.append(invoiceData)
                } catch {
                    Log("Couldn't load data from \(invoiceTitle). Error: \(error.localizedDescription)", event: .error)
                }
            } else {
                Log("Invoice with name \(invoiceTitle) doesn't exist.", event: .warning)
            }
        }
        Log("Successfully obtained \(invoicesData.count) invoices data", event: .success)
        completion(invoicesData)
    }
    
    
    func storeInvoicesWithExtractions(invoices: [DocumentWithExtractions]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(invoices)
            UserDefaults.standard.set(data, forKey: Constants.storedInvoicesKey)
            Log("Successfully stored invoices in UserDefaults", event: .success)
        } catch {
            Log("Unable to Encode Invoices: (\(error))", event: .error)
        }
    }
    
    func getInvoicesWithExtractions() -> [DocumentWithExtractions]  {
        if let data = UserDefaults.standard.data(forKey: Constants.storedInvoicesKey) {
            do {
                let decoder = JSONDecoder()
                let invoices = try decoder.decode([DocumentWithExtractions].self, from: data)
                Log("Successfully obtained invoices from UserDefaults", event: .success)
                return invoices
            } catch {
                Log("Unable to Decode Notes (\(error))", event: .error)
            }
        }
        return []
    }
    
    func appendInvoiceWithExtractions(invoice: DocumentWithExtractions) {
        var storedInvoices = getInvoicesWithExtractions()
        storedInvoices.append(invoice)
        storeInvoicesWithExtractions(invoices: storedInvoices)
    }
    
    func updateDocumentExtractions(documentId: String, extractions: ExtractionResult) {
        var invoices = getInvoicesWithExtractions()
        if let index = invoices.firstIndex(where: { $0.documentId == documentId }) {
            invoices[index].recipient = extractions.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
            invoices[index].amountToPay = extractions.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
        }
        storeInvoicesWithExtractions(invoices: invoices)
    }
}

extension HardcodedInvoicesController {
    private enum Constants {
        static let numberOfInovices = 5
        static let invoiceTitle = "health-invoice-"
        static let invoiceFileFormat = "jpg"
        static let storedInvoicesKey = "giniHealthSDKExample.invoicesWithExtractions"
    }
}
