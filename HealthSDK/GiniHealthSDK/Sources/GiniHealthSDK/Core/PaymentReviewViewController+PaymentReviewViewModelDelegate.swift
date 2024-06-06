//
//  PaymentReviewViewController+PaymentReviewViewModelDelegate.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = inputContainer.frame.height
        presentBottomSheet(viewController: bottomSheet)
    }

    func createPaymentRequestAndOpenBankApp() {
        self.presentedViewController?.dismiss(animated: true)
        checkForErrors()
    }

    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = inputContainer.frame.height
        presentBottomSheet(viewController: bottomSheet)
        model?.incrementOnboardingCountFor(paymentProvider: selectedPaymentProvider)
    }

    func obtainPDFFromPaymentRequest() {
        model?.createPaymentRequest(paymentInfo: obtainPaymentInfo(), completion: { [weak self] paymentRequestID in
            self?.loadPDFData(paymentRequestID: paymentRequestID)
        })
    }
    
    private func loadPDFData(paymentRequestID: String) {
        self.model?.loadPDF(paymentRequestID: paymentRequestID, completion: { [weak self] pdfData in
            self?.writePDFDataToFile(data: pdfData, fileName: paymentRequestID)
        })
    }
    
    private func writePDFDataToFile(data: Data, fileName: String) {
        do {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let docDirectoryPath = paths.first else { return }
            let pdfFileName = fileName + Constants.pdfExtension
            let pdfPath = docDirectoryPath.appendingPathComponent(pdfFileName)
            try data.write(to: pdfPath)
            self.sharePDF(pdfURL: pdfPath)
        } catch {
            print("Error while write pdf file to location: \(error.localizedDescription)")
        }
    }

    private func sharePDF(pdfURL: URL) {
        // Create UIActivityViewController with the PDF file
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)

        // Exclude some activities if needed
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .airDrop,
            .mail,
            .message,
            .postToFacebook,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTwitter,
            .postToTencentWeibo,
            .copyToPasteboard,
            .markupAsPDF,
            .openInIBooks,
            .print,
            .saveToCameraRoll
        ]

        // Present the UIActivityViewController
        DispatchQueue.main.async {
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            if (self.presentedViewController != nil) {
                self.presentedViewController?.dismiss(animated: true, completion: {
                    self.present(activityViewController, animated: true, completion: nil)
                })
            } else {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
