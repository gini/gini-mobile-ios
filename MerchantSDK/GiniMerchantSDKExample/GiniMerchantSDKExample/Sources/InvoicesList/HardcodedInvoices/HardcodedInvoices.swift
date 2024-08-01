//
//  HardcodedInvoicesController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

protocol HardcodedInvoicesControllerProtocol: AnyObject {
    func storeInvoices(invoices: [InvoiceItem])
    func getInvoices() -> [InvoiceItem]
    func appendInvoice(invoice: InvoiceItem)
    func updateInvoice(uuid: UUID, recipient: String?, amountToPay: String?)
}

class InvoiceItem: Codable {
    var uuid = UUID()
    var amountToPay: String?
    var recipient: String?
    var iban: String?
    var purpose: String?

    convenience init(amountToPay: String?, recipient: String?, iban: String?, purpose: String?) {
        self.init()
        self.amountToPay = amountToPay
        self.recipient = recipient
        self.iban = iban
        self.purpose = purpose
    }
}

final class HardcodedInvoicesController: HardcodedInvoicesControllerProtocol {

    init() {
        self.storeInvoices(invoices: invoices)
    }

    var invoices: [InvoiceItem] = {
        [InvoiceItem(amountToPay: "709.97:EUR", recipient: "OTTO GMBH & CO KG", iban: "DE75201207003100124444", purpose: "RF7411164022"),
         InvoiceItem(amountToPay: "54.97:EUR", recipient: "Tchibo GmbH", iban: "DE14200800000816170700", purpose: "10020302020"),
         InvoiceItem(amountToPay: "126.62:EUR", recipient: "Zalando SE", iban: "DE86210700200123010101", purpose: "938929192"),
         InvoiceItem(amountToPay: "114.88:EUR", recipient: "bonprix Handelsgesellschaft mbH", iban: "DE68201207003100755555", purpose: "020329984871123"),
         InvoiceItem(amountToPay: "80.13:EUR", recipient: "Klarna", iban: "DE13760700120500154000", purpose: "00425818528311423079")]
    }()
    
    
    func storeInvoices(invoices: [InvoiceItem]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(invoices)
            UserDefaults.standard.set(data, forKey: Constants.storedInvoicesKey)
            print("✅ Successfully stored invoices in UserDefaults")
        } catch {
            print("❌ Unable to Encode Invoices: (\(error))")
        }
    }
    
    func getInvoices() -> [InvoiceItem]  {
        if let data = UserDefaults.standard.data(forKey: Constants.storedInvoicesKey) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([InvoiceItem].self, from: data)
                print("✅ Successfully obtained invoices from UserDefaults")
                return decoded
            } catch {
                print("❌ Unable to Decode Notes (\(error))")
            }
        }
        return []
    }
    
    func appendInvoice(invoice: InvoiceItem) {
        var storedInvoices = getInvoices()
        storedInvoices.append(invoice)
        storeInvoices(invoices: storedInvoices)
    }
    
    func updateInvoice(uuid: UUID, recipient: String?, amountToPay: String?) {
        let invoices = getInvoices()
        if let index = invoices.firstIndex(where: { $0.uuid == uuid }) {
            invoices[index].recipient = recipient
            invoices[index].amountToPay = amountToPay
        }
        storeInvoices(invoices: invoices)
    }
}

extension HardcodedInvoicesController {
    private enum Constants {
        static let storedInvoicesKey = "giniHealthSDKExample.invoices"
    }
}
