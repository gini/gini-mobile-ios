//
//  Mapping.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniPaymentComponents

//MARK: - Mapping Extraction
extension Extraction {
    convenience init(healthExtraction: GiniHealthAPILibrary.Extraction) {
        self.init(box: nil,
                  candidates: healthExtraction.candidates,
                  entity: healthExtraction.entity,
                  value: healthExtraction.value,
                  name: healthExtraction.name)
    }

    func toHealthExtraction() -> GiniHealthAPILibrary.Extraction {
        return GiniHealthAPILibrary.Extraction(box: nil,
                                               candidates: candidates,
                                               entity: entity,
                                               value: value,
                                               name: name)
    }
}

extension ExtractionResult {
    convenience init(healthExtractionResult: GiniHealthAPILibrary.ExtractionResult) {
        let extractions = healthExtractionResult.extractions.map { Extraction(healthExtraction: $0) }
        let payment = healthExtractionResult.payment?.map { $0.map { Extraction(healthExtraction: $0) } }
        let lineItems = healthExtractionResult.lineItems?.map { $0.map { Extraction(healthExtraction: $0) } }

        self.init(extractions: extractions,
                  payment: payment,
                  lineItems: lineItems)
    }

    func toHealthExtractionResult() -> GiniHealthAPILibrary.ExtractionResult {
        let healthExtractions = extractions.map { $0.toHealthExtraction() }
        let healthPayment = payment?.map { $0.map { $0.toHealthExtraction() } }
        let healthLineItems = lineItems?.map { $0.map { $0.toHealthExtraction() } }
        return GiniHealthAPILibrary.ExtractionResult(extractions: healthExtractions,
                                                     payment: healthPayment,
                                                     lineItems: healthLineItems)
    }
}

//MARK: - PaymentProvider

extension PaymentProvider {
    init(healthPaymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        let openWithPlatforms = healthPaymentProvider.openWithSupportedPlatforms.compactMap { PlatformSupported(rawValue: $0.rawValue) }
        let gpcSupportedPlatforms = healthPaymentProvider.gpcSupportedPlatforms.compactMap { PlatformSupported(rawValue: $0.rawValue) }
        let colors = ProviderColors(healthProviderColors: healthPaymentProvider.colors)
        let minAppVersions: MinAppVersions?
        if let healthMinAppVersions = healthPaymentProvider.minAppVersion {
            minAppVersions = MinAppVersions(healthMinAppVersions: healthMinAppVersions)
        } else {
            minAppVersions = nil
        }

        self.init(id: healthPaymentProvider.id,
                  name: healthPaymentProvider.name,
                  appSchemeIOS: healthPaymentProvider.appSchemeIOS,
                  minAppVersion: minAppVersions,
                  colors: colors,
                  iconData: healthPaymentProvider.iconData,
                  appStoreUrlIOS: healthPaymentProvider.appStoreUrlIOS,
                  universalLinkIOS: healthPaymentProvider.universalLinkIOS,
                  index: healthPaymentProvider.index,
                  gpcSupportedPlatforms: gpcSupportedPlatforms,
                  openWithSupportedPlatforms: openWithPlatforms)
    }

    func toHealthPaymentProvider() -> GiniHealthAPILibrary.PaymentProvider {
        let gpcSupportedPlatforms = self.gpcSupportedPlatforms.compactMap { GiniHealthAPILibrary.PlatformSupported(rawValue: $0.rawValue) }
        let openWithPlatforms = openWithSupportedPlatforms.compactMap { GiniHealthAPILibrary.PlatformSupported(rawValue: $0.rawValue) }

        return GiniHealthAPILibrary.PaymentProvider(id: id,
                                                    name: name,
                                                    appSchemeIOS: appSchemeIOS,
                                                    minAppVersion: minAppVersion?.healthMinAppVersions,
                                                    colors: colors.toHealthProviderColors(),
                                                    iconData: iconData,
                                                    appStoreUrlIOS: appStoreUrlIOS,
                                                    universalLinkIOS: universalLinkIOS,
                                                    index: index,
                                                    gpcSupportedPlatforms: gpcSupportedPlatforms,
                                                    openWithSupportedPlatforms:openWithPlatforms)
    }
}

extension ProviderColors {
    init(healthProviderColors: GiniHealthAPILibrary.ProviderColors) {
        self.init(background: healthProviderColors.background,
                  text: healthProviderColors.text)
    }

    func toHealthProviderColors() -> GiniHealthAPILibrary.ProviderColors {
        return GiniHealthAPILibrary.ProviderColors(background: background,
                                                   text: text)
    }
}

extension MinAppVersions {
    init(healthMinAppVersions: GiniHealthAPILibrary.MinAppVersions) {
        self.healthMinAppVersions = healthMinAppVersions
    }
}

//MARK: - Document

extension Document {
    init(healthDocument: GiniHealthAPILibrary.Document) {
        self.init(compositeDocuments: healthDocument.compositeDocuments?.compactMap { CompositeDocument(document: $0.document) },
                  creationDate: healthDocument.creationDate,
                  id: healthDocument.id,
                  name: healthDocument.name,
                  origin: Origin(rawValue: healthDocument.origin.rawValue) ?? .unknown,
                  pageCount: healthDocument.pageCount,
                  pages: healthDocument.pages?.compactMap { Document.Page(healthPage: $0) },
                  links: Links(giniAPIDocumentURL: healthDocument.links.extractions),
                  partialDocuments: healthDocument.partialDocuments?.compactMap { PartialDocumentInfo(document: $0.document, rotationDelta: $0.rotationDelta) },
                  progress: Progress(rawValue: healthDocument.progress.rawValue) ?? .completed,
                  sourceClassification: SourceClassification(rawValue: healthDocument.sourceClassification.rawValue) ?? .scanned,
                  expirationDate: healthDocument.expirationDate)
    }

    func toHealthDocument() -> GiniHealthAPILibrary.Document {
        GiniHealthAPILibrary.Document(creationDate: creationDate,
                                      id: id,
                                      name: name,
                                      links: GiniHealthAPILibrary.Document.Links(giniAPIDocumentURL: links.extractions),
                                      sourceClassification: GiniHealthAPILibrary.Document.SourceClassification(rawValue: sourceClassification.rawValue) ?? .scanned,
                                      expirationDate: expirationDate)
    }
}

extension Document.Page {
    init(healthPage: GiniHealthAPILibrary.Document.Page) {
        let images = healthPage.images.compactMap { (size: Document.Page.Size(healthSize: $0.size), url: $0.url) }
        self.init(number: healthPage.number, images: images)
    }
}

extension Document.Page.Size {
    init(healthSize: GiniHealthAPILibrary.Document.Page.Size) {
        self.init(rawValue: healthSize.rawValue)!
    }
}

extension Document.Layout {
    init(healthLayout: GiniHealthAPILibrary.Document.Layout) {
        self.init(pages: healthLayout.pages.compactMap { Document.Layout.Page(healthPage: $0) })
    }
}

extension Document.Layout.Page {
    init(healthPage: GiniHealthAPILibrary.Document.Layout.Page) {
        self.init(number: healthPage.number,
                  sizeX: healthPage.sizeX,
                  sizeY: healthPage.sizeY,
                  textZones: healthPage.textZones.compactMap { Document.Layout.TextZone(healthTextZone: $0) },
                  regions: healthPage.regions?.compactMap { Document.Layout.Region(healthRegion: $0) })
    }
}

extension Document.Layout.Region {
    init(healthRegion: GiniHealthAPILibrary.Document.Layout.Region) {
        self.init(l: healthRegion.l,
                  t: healthRegion.t,
                  w: healthRegion.w,
                  h: healthRegion.h,
                  type: healthRegion.type,
                  lines: healthRegion.lines?.compactMap { Document.Layout.Region.init(healthRegion: $0) },
                  wds: healthRegion.wds?.compactMap { Document.Layout.Word.init(healthWord: $0) })
    }
}

extension Document.Layout.Word {
    init(healthWord: GiniHealthAPILibrary.Document.Layout.Word) {
        self.init(l: healthWord.l,
                  t: healthWord.t,
                  w: healthWord.w,
                  h: healthWord.h,
                  fontSize: healthWord.fontSize,
                  fontFamily: healthWord.fontFamily,
                  bold: healthWord.bold,
                  text: healthWord.text)
    }
}

extension Document.Layout.TextZone {
    init(healthTextZone: GiniHealthAPILibrary.Document.Layout.TextZone) {
        self.init(paragraphs: healthTextZone.paragraphs.compactMap { Document.Layout.Region(healthRegion: $0) })
    }
}

extension CompositeDocumentInfo {
    func toHealthCompositeDocumentInfo() -> GiniHealthAPILibrary.CompositeDocumentInfo {
        GiniHealthAPILibrary.CompositeDocumentInfo(partialDocuments: partialDocuments.map { GiniHealthAPILibrary.PartialDocumentInfo(document: $0.document) })
    }
}

extension Document.TypeV2 {
    func toHealthType() -> GiniHealthAPILibrary.Document.TypeV2 {
        switch self {
        case .partial(let data):
            return .partial(data)
        case .composite(let info):
            return .composite(info.toHealthCompositeDocumentInfo())
        }
    }
}

//MARK: - Log

extension LogLevel {
    func toHealthLogLevel() -> GiniHealthAPILibrary.LogLevel {
        switch self {
        case .debug:
            return .debug
        case .none:
            return .none
        }
    }
}

//MARK: - PaymentProvider

extension PaymentInfo {
    init(paymentConponentsInfo: GiniPaymentComponents.PaymentInfo) {
        self.init(recipient: paymentConponentsInfo.recipient,
                  iban: paymentConponentsInfo.iban,
                  bic: paymentConponentsInfo.bic,
                  amount: paymentConponentsInfo.amount,
                  purpose: paymentConponentsInfo.purpose,
                  paymentUniversalLink: paymentConponentsInfo.paymentUniversalLink,
                  paymentProviderId: paymentConponentsInfo.paymentProviderId)
    }
}
