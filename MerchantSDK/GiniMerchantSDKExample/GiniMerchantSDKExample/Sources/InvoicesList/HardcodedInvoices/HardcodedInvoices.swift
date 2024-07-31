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
    func updateDocumentExtractions(documentID: String, recipient: String?, amountToPay: String?)
}

final class HardcodedInvoicesController: HardcodedInvoicesControllerProtocol {
    func obtainInvoicePhotosHardcoded(completion: @escaping (([Data]) -> Void)) {

//struct InvoiceItem: Codable {
//    var amountToPay: String?
//    var recipient: String?
//    var iban: String?
//    var purpose: String?
//}
//
//    var invoices: [InvoiceItem] = {
//        [InvoiceItem(amountToPay: "709.97", recipient: "OTTO GMBH & CO KG", iban: "DE75201207003100124444", purpose: "RF7411164022"),
//         InvoiceItem(amountToPay: "54.97", recipient: "Tchibo GmbH", iban: "DE14200800000816170700", purpose: "10020302020"),
//         InvoiceItem(amountToPay: "126.62", recipient: "Zalando SE", iban: "DE86210700200123010101", purpose: "938929192"),
//         InvoiceItem(amountToPay: "114.88", recipient: "bonprix Handelsgesellschaft mbH", iban: "DE68201207003100755555", purpose: "020329984871123"),
//         InvoiceItem(amountToPay: "80.13", recipient: "Klarna", iban: "DE13760700120500154000", purpose: "00425818528311423079")]
//    }()


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
                print("⚠️ Invoice with name \(invoiceTitle) doesn't exist.")
            }
        }
        print("✅ Successfully obtained \(invoicesData.count) invoices data")
        completion(invoicesData)
    }
    
    
    func storeInvoicesWithExtractions(invoices: [DocumentWithExtractions]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(invoices)
            UserDefaults.standard.set(data, forKey: Constants.storedInvoicesKey)
            print("✅ Successfully stored invoices in UserDefaults")
        } catch {
            print("❌ Unable to Encode Invoices: (\(error))")
        }
    }
    
    func getInvoicesWithExtractions() -> [DocumentWithExtractions]  {
        if let data = UserDefaults.standard.data(forKey: Constants.storedInvoicesKey) {
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
        var storedInvoices = getInvoicesWithExtractions()
        storedInvoices.append(invoice)
        storeInvoicesWithExtractions(invoices: storedInvoices)
    }
    
    func updateDocumentExtractions(documentID: String, recipient: String?, amountToPay: String?) {
        var invoices = getInvoicesWithExtractions()
        if let index = invoices.firstIndex(where: { $0.documentID == documentID }) {
            invoices[index].recipient = recipient
            invoices[index].amountToPay = amountToPay
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
