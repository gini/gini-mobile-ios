//
//  GiniNetworkingScreenAPICoordinator.swift
//  GiniCapture
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 The GiniCaptureResultsDelegate protocol defines methods that allow you to handle the analysis result.
 */
@objc public protocol GiniCaptureResultsDelegate: AnyObject {

    /**
     Called when the analysis finished with results

     - parameter result: Contains the analysis result
     */
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult)

    /**
     Called when the analysis was cancelled.
     */
    func giniCaptureDidCancelAnalysis()

    /**
     Called when the 'Enter Manually' was pressed within No Result/ Error screen
     */
    func giniCaptureDidEnterManually()

    /**
     Optional. Called when the user chose to schedule the payment instead of
     paying now.

     Added in 4.5.0 as an `@objc optional` requirement so integrators
     upgrading from 4.4.x keep compiling without changes. Implement it to
     route the user to your own scheduled-transfer screen, carrying the
     extractions over from `result`. If unimplemented, the SDK simply does
     not deliver the callback.

     - Parameter result: The analysis result — same shape and construction as
       the one delivered to `giniCaptureAnalysisDidFinishWith(result:)`.
     */
    @objc optional func giniCaptureDidRequestSchedulePayment(result: AnalysisResult)
}

public class GiniNetworkingScreenAPICoordinator: GiniScreenAPICoordinator {
    public weak var resultsDelegate: GiniCaptureResultsDelegate?
    public let documentService: DocumentServiceProtocol

     public init(client: Client,
                 resultsDelegate: GiniCaptureResultsDelegate,
                 giniConfiguration: GiniConfiguration,
                 documentMetadata: Document.Metadata?,
                 api: APIDomain,
                 trackingDelegate: GiniCaptureTrackingDelegate?,
                 lib : GiniBankAPI) {
         
         self.documentService = DocumentService(lib: lib, metadata: documentMetadata)
         super.init(withDelegate: nil,
                    giniConfiguration: giniConfiguration)
         
         self.giniConfiguration.documentService = documentService
         self.visionDelegate = self
         self.resultsDelegate = resultsDelegate
         self.trackingDelegate = trackingDelegate
    }
     
     public init(resultsDelegate: GiniCaptureResultsDelegate,
                 giniConfiguration: GiniConfiguration,
                 documentMetadata: Document.Metadata?,
                 trackingDelegate: GiniCaptureTrackingDelegate?,
                 captureNetworkService: GiniCaptureNetworkService) {

         self.documentService = DocumentService(giniCaptureNetworkService: captureNetworkService, metadata: documentMetadata)
         
         super.init(withDelegate: nil,
                    giniConfiguration: giniConfiguration)

         self.giniConfiguration.documentService = documentService
         self.visionDelegate = self
         self.resultsDelegate = resultsDelegate
         self.trackingDelegate = trackingDelegate
     }
    
    convenience init(client: Client,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     userApi: UserDomain,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        
        let lib = GiniBankAPI
            .Builder(client: client, api: api, userApi: userApi)
            .build()

        self.init(client: client,
                  resultsDelegate: resultsDelegate,
                  giniConfiguration: giniConfiguration,
                  documentMetadata: documentMetadata,
                  api: api,
                  trackingDelegate: trackingDelegate,
                  lib: lib)
    }
    
    /**
     Looks up the scanned payload from `pages` and feeds it to `mapWeroExtractions`.
     */
    func mapWeroExtractionsIfApplicable(_ result: ExtractionResult) -> ExtractionResult {
        return Self.mapWeroExtractionsIfApplicable(result, pages: pages)
    }

    /**
     Static sibling of `mapWeroExtractionsIfApplicable(_:)` so callers that do
     not inherit from this coordinator (notably the BankSDK coordinator) can
     reuse the "pick the first QR document's scanned payload" step without
     duplicating the pages lookup.
     */
    public static func mapWeroExtractionsIfApplicable(_ result: ExtractionResult,
                                                      pages: [GiniCapturePage]) -> ExtractionResult {
        let scannedPayload = pages.lazy
            .compactMap({ $0.document as? GiniQRCodeDocument })
            .first?.scannedPayload
        return mapWeroExtractions(result, scannedPayload: scannedPayload)
    }

    /**
     Rewrites `result` to a single `weroPaymentQRCodeUrl` extraction when the
     Wero flag is on, the backend tagged the payload as Wero, and a scanned
     payload is available. Returns `result` unchanged otherwise.
     */
    public static func mapWeroExtractions(_ result: ExtractionResult,
                                          scannedPayload: String?) -> ExtractionResult {
        let weroEnabled = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false
        guard weroEnabled,
              result.extractions.contains(where: isWeroPaymentQRCodeTypeExtraction),
              let scannedPayload else {
            return result
        }
        let weroExtraction = Extraction(box: nil,
                                        candidates: nil,
                                        entity: QRCodesExtractor.weroPaymentQRCodeUrlKey,
                                        value: scannedPayload,
                                        name: QRCodesExtractor.weroPaymentQRCodeUrlKey)
        return ExtractionResult(extractions: [weroExtraction],
                                lineItems: nil,
                                skontoDiscounts: nil,
                                crossBorderPayment: nil,
                                candidates: [:])
    }

    /**
     Case-insensitive match for a `paymentQRCodeType = wero` extraction.
     */
    private static func isWeroPaymentQRCodeTypeExtraction(_ extraction: Extraction) -> Bool {
        let key = QRCodesExtractor.paymentQRCodeTypeKey
        let matchesKey = extraction.name?.caseInsensitiveCompare(key) == .orderedSame
            || extraction.entity.caseInsensitiveCompare(key) == .orderedSame
        return matchesKey
            && extraction.value.caseInsensitiveCompare(QRCodesExtractor.weroPaymentQRCodeTypeValue) == .orderedSame
    }

    public func deliver(result: ExtractionResult, and document: Document? = nil, to analysisDelegate: AnalysisDelegate) {
        let hasExtactions = result.extractions.count > 0
        let weroKey = QRCodesExtractor.weroPaymentQRCodeUrlKey
        let isWeroResult = result.extractions.contains { $0.name == weroKey || $0.entity == weroKey }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            /// Check the Wero camera fallback first: a Wero-candidate scan
            /// whose backend response isn't a confirmed Wero URL (empty OR
            /// unrelated extractions) must pop back to the camera rather
            /// than deliver garbage data to the host app.
            if Self.performWeroFallbackIfNeeded(pages: self.pages,
                                                extractionResult: result,
                                                delegate: analysisDelegate,
                                                documentService: self.documentService) {
                return
            }

            if hasExtactions {
                let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: result.extractions.compactMap {
                    guard let name = $0.name else { return nil }

                    return (name, $0)
                })

                /// URL-only shape matching EPS when the result is a confirmed Wero.
                let analysisResult: AnalysisResult
                if isWeroResult {
                    analysisResult = AnalysisResult(extractions: extractions,
                                                    lineItems: [],
                                                    images: [],
                                                    document: nil,
                                                    candidates: result.candidates)
                } else {
                    let images = self.pages.compactMap { $0.document.previewImage }
                    analysisResult = AnalysisResult(extractions: extractions,
                                                    lineItems: result.lineItems,
                                                    images: images,
                                                    document: document,
                                                    candidates: result.candidates)
                }

                self.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: analysisResult)
            } else {
                analysisDelegate.tryDisplayNoResultsScreen()
                self.documentService.resetToInitialState()
            }
        }
    }

    /**
     True when `pages` holds a Wero-candidate QR (`qrCodeFormat == nil`), the
     flag is on, and `extractionResult` carries no `weroPaymentQRCodeUrl`.
     Pure of coordinator state so both the CaptureSDK and BankSDK networking
     coordinators can share the gate without duplicating the logic.
     */
    public static func shouldRouteBackToCameraForWeroFallback(pages: [GiniCapturePage],
                                                              extractionResult: ExtractionResult) -> Bool {
        let weroEnabled = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false
        guard weroEnabled else { return false }
        let weroCandidateInPages = pages.contains(where: { page in
            guard let qrDocument = page.document as? GiniQRCodeDocument else { return false }
            return qrDocument.qrCodeFormat == nil
        })
        guard weroCandidateInPages else { return false }
        let weroKey = QRCodesExtractor.weroPaymentQRCodeUrlKey
        return !extractionResult.extractions.contains { extraction in
            extraction.name == weroKey || extraction.entity == weroKey
        }
    }

    /**
     Shared executor for the Wero camera fallback. Returns `true` when the
     Wero gate fires and the caller should stop further navigation. Keeps
     the CaptureSDK `deliver` and BankSDK `presentNextScreen` call sites
     in sync.
     */
    @MainActor
    public static func performWeroFallbackIfNeeded(pages: [GiniCapturePage],
                                                   extractionResult: ExtractionResult,
                                                   delegate: AnalysisDelegate,
                                                   documentService: DocumentServiceProtocol) -> Bool {
        guard shouldRouteBackToCameraForWeroFallback(pages: pages,
                                                     extractionResult: extractionResult) else {
            return false
        }
        /// `tryDisplayInvalidQRMessage` is `@objc optional`; fall back to the
        /// required `tryDisplayNoResultsScreen` so processing never gets stuck.
        if (delegate as AnyObject).responds(to: #selector(AnalysisDelegate.tryDisplayInvalidQRMessage)) {
            delegate.tryDisplayInvalidQRMessage?()
        } else {
            delegate.tryDisplayNoResultsScreen()
        }
        documentService.resetToInitialState()
        return true
    }
}

// MARK: - Networking methods

extension GiniNetworkingScreenAPICoordinator {
    fileprivate func startAnalysis(networkDelegate: GiniCaptureNetworkDelegate) {
        self.documentService.startAnalysis { result in
            switch result {
            case .success(let extractions):
                let mapped = self.mapWeroExtractionsIfApplicable(extractions)
                self.deliver(result: mapped, and: self.documentService.document, to: networkDelegate)
            case .failure(let error):
                guard error != .requestCancelled else { return }
                DispatchQueue.main.async {
                    networkDelegate.displayError(errorType: ErrorType(error: error), animated: true)
                }
            }
        }
    }

    fileprivate func upload(document: GiniCaptureDocument,
                            didComplete: @escaping (GiniCaptureDocument) -> Void,
                            didFail: @escaping (GiniCaptureDocument, Error) -> Void) {
        documentService.upload(document: document) { result in
            switch result {
            case .success:
                didComplete(document)
            case .failure(let error):
                didFail(document, error)
            }
        }
    }

    fileprivate func uploadAndStartAnalysis(document: GiniCaptureDocument,
                                            networkDelegate: GiniCaptureNetworkDelegate,
                                            uploadDidFail: @escaping () -> Void) {
        self.upload(document: document, didComplete: { _ in
            self.startAnalysis(networkDelegate: networkDelegate)
        }, didFail: { _, error in
            guard let giniError = error as? GiniError, giniError != .requestCancelled else { return }
            DispatchQueue.main.async {
                networkDelegate.displayError(errorType: ErrorType(error: giniError), animated: true)
            }
        })
    }
}

// MARK: - GiniCaptureDelegate

extension GiniNetworkingScreenAPICoordinator: GiniCaptureDelegate {
    
    public func didPressEnterManually() {
        resultsDelegate?.giniCaptureDidEnterManually()
    }
    
    public func didCancelCapturing() {
        resultsDelegate?.giniCaptureDidCancelAnalysis()
    }

    public func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        // The EPS QR codes are a special case, since they don't have to be analyzed by the Gini Bank API and therefore,
        // they are ready to be delivered after capturing them.
        if let qrCodeDocument = document as? GiniQRCodeDocument,
            let format = qrCodeDocument.qrCodeFormat,
            case .eps4mobile = format {
            let extractions = qrCodeDocument.extractedParameters.compactMap {
                Extraction(box: nil, candidates: nil,
                           entity: QRCodesExtractor.epsCodeUrlKey,
                           value: $0.value,
                           name: QRCodesExtractor.epsCodeUrlKey)
                }
            let extractionResult = ExtractionResult(extractions: extractions,
                                                    lineItems: [],
                                                    candidates: [:])
            
            self.deliver(result: extractionResult, to: networkDelegate)
            return
        }

        // When an non reviewable document or an image in multipage mode is captured,
        // it has to be uploaded right away.
        if giniConfiguration.multipageEnabled || !document.isReviewable {
            if !document.isReviewable {
                self.uploadAndStartAnalysis(document: document, networkDelegate: networkDelegate, uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
            } else if giniConfiguration.multipageEnabled {
                // When multipage is enabled the document updload result should be communicated to the network delegate
                upload(document: document,
                       didComplete: networkDelegate.uploadDidComplete,
                       didFail: networkDelegate.uploadDidFail)
            }
        }
    }

    public func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if giniConfiguration.multipageEnabled {
            documentService.sortDocuments(withSameOrderAs: documents)
        }

        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService.update(imageDocument: document)
        }

        // In multipage mode the analysis can be triggered once the documents have been uploaded.
        // However, in single mode, the analysis can be triggered right after capturing the image.
        // That is why the document upload should be done here and start the analysis afterwards
        if giniConfiguration.multipageEnabled {
            self.startAnalysis(networkDelegate: networkDelegate)
        } else {
            self.uploadAndStartAnalysis(document: documents[0],
                                        networkDelegate: networkDelegate,
                                        uploadDidFail: {
                self.didReview(documents: documents, networkDelegate: networkDelegate)
            })
        }
    }

    public func didCancelReview(for document: GiniCaptureDocument) {
        documentService.remove(document: document)
    }

    public func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        if pages.type == .image {
            documentService.cancelAnalysis()
        } else {
            documentService.resetToInitialState()
        }
    }

}
