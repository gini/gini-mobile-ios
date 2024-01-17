//
//  HardcodedInvoicesController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

protocol HardcodedInvoicesControllerProtocol: AnyObject {
    func obtainInvoicesHardcoded(completion: @escaping (([Data]) -> Void))
}

final class HardcodedInvoicesController: HardcodedInvoicesControllerProtocol {
    func obtainInvoicesHardcoded(completion: @escaping (([Data]) -> Void)) {
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
}

extension HardcodedInvoicesController {
    private enum Constants {
        static let numberOfInovices = 5
        static let invoiceTitle = "health-invoice-"
        static let invoiceFileFormat = "jpg"
    }
}
