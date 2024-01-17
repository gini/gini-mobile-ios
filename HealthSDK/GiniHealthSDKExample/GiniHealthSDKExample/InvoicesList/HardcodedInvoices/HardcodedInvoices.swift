//
//  HardcodedInvoicesController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

protocol HardcodedInvoicesControllerProtocol: AnyObject {
    func obtainInvoicePhotosHardcoded(completion: @escaping (([Data]) -> Void))
    func storeInvoicesWithExtractions(invoices: [DocumentWithExtractions])
    func getInvoicesWithExtractions() -> [DocumentWithExtractions]
    func appendInvoiceWithExtractions(invoice: DocumentWithExtractions)
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
                    print("❌ Couldn't load data from \(invoiceTitle). Error: \(error.localizedDescription)")
                }
            } else {
                print("❌ Invoice with name \(invoiceTitle) doesn't exist.")
            }
        }
        print("✅ Successfully obtained \(invoicesData.count) invoices data")
        completion(invoicesData)
    }
    
    
    func storeInvoicesWithExtractions(invoices: [DocumentWithExtractions]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(invoices)
            UserDefaults.standard.set(data, forKey: Constants.invoicesStoredKey)
            print("✅ Successfully stored invoices in UserDefaults")
        } catch {
            print("❌ Unable to Encode Invoices: (\(error))")
        }
    }
    
    func getInvoicesWithExtractions() -> [DocumentWithExtractions]  {
        if let data = UserDefaults.standard.data(forKey: Constants.invoicesStoredKey) {
            do {
                let decoder = JSONDecoder()
                let invoices = try decoder.decode([DocumentWithExtractions].self, from: data)
                print("✅ Successfully obtained invoices from UserDefaults")
                return invoices
            } catch {
                print("❌ Unable to Decode Notes (\(error))")
            }
        }
        return []
    }
    
    func appendInvoiceWithExtractions(invoice: DocumentWithExtractions) {
        var invoicesStored = getInvoicesWithExtractions()
        invoicesStored.append(invoice)
        storeInvoicesWithExtractions(invoices: invoicesStored)
    }
}

extension HardcodedInvoicesController {
    private enum Constants {
        static let numberOfInovices = 5
        static let invoiceTitle = "health-invoice-"
        static let invoiceFileFormat = "jpg"
        static let invoicesStoredKey = "giniHealthSDKExample.invoicesWithExtractions"
    }
}
