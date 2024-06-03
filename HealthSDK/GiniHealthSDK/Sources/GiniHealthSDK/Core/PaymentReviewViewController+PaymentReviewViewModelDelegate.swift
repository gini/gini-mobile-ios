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

    func sharePDFActivityUI() {
        // TODO: Load PDF from backend then...
        model?.loadPDF()

        self.presentedViewController?.dismiss(animated: true, completion: {
            self.sharePDF()
        })
    }

    func sharePDF() {
        // Load your PDF file
        guard let pdfURL = Bundle.main.url(forResource: "test_pdf", withExtension: "pdf") else {
            print("PDF file not found.")
            return
        }

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
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(activityViewController, animated: true, completion: nil)
    }
}
