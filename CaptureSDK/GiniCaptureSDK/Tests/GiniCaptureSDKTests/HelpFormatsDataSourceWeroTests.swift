//
//  HelpFormatsDataSourceWeroTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("HelpFormatsDataSource – Wero QR entry")
struct HelpFormatsDataSourceWeroTests {

    private static let weroString = NSLocalizedStringPreferredFormat(
        "ginicapture.help.supportedFormats.qrcode.item.11",
        comment: "QR code type item 11"
    )

    private static let baselineQRFormats: [String] = [
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.1", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.2", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.3", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.4", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.5", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.6", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.7", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.8", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.9", comment: ""),
        NSLocalizedStringPreferredFormat("ginicapture.help.supportedFormats.qrcode.item.10", comment: "")
    ]

    @Test("Flag ON appends Wero at slot 11 after HUB3 (R1)")
    func weroFlagOnQRCodeSectionAppendsWeroAtSlot11() {
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let dataSource = HelpFormatsDataSource(isQRCodeContent: true)
            let formats = dataSource.qrCodeItemSections[0].formats

            #expect(formats.count == 11)
            #expect(formats[10] == Self.weroString)
            #expect(Array(formats.prefix(10)) == Self.baselineQRFormats)
            #expect(formats == Self.baselineQRFormats + [Self.weroString])
        }
    }

    @Test("Flag OFF yields the original 10-item list (R2)")
    func weroFlagOffQRCodeSectionIsTenItemsNoWero() {
        GiniCaptureTestsHelper.withWeroFlag(false) {
            let dataSource = HelpFormatsDataSource(isQRCodeContent: true)
            let formats = dataSource.qrCodeItemSections[0].formats

            #expect(formats.count == 10)
            #expect(formats == Self.baselineQRFormats)
            #expect(formats.contains(Self.weroString) == false)
        }
    }

    @Test("Flag missing (nil) yields the original 10-item list (R3)")
    func weroFlagMissingQRCodeSectionIsTenItemsNoWero() {
        GiniCaptureTestsHelper.withWeroFlag(nil) {
            let dataSource = HelpFormatsDataSource(isQRCodeContent: true)
            let formats = dataSource.qrCodeItemSections[0].formats

            #expect(formats.count == 10)
            #expect(formats == Self.baselineQRFormats)
            #expect(formats.contains(Self.weroString) == false)
        }
    }

    @Test(
        "pdfItemSections unchanged under every flag value (R4)",
        arguments: [nil, false, true] as [Bool?]
    )
    func pdfItemSectionsUnchangedUnderEveryFlagValue(flag: Bool?) {
        var baselineSectionCount = 0
        var baselineRowCounts: [Int] = []
        var baselineFormats: [[String]] = []

        GiniCaptureTestsHelper.withWeroFlag(false) {
            let baseline = HelpFormatsDataSource()
            baselineSectionCount = baseline.pdfItemSections.count
            baselineRowCounts = baseline.pdfItemSections.map { $0.formats.count }
            baselineFormats = baseline.pdfItemSections.map { $0.formats }
        }

        GiniCaptureTestsHelper.withWeroFlag(flag) {
            let dataSource = HelpFormatsDataSource()
            let sections = dataSource.pdfItemSections

            #expect(sections.count == baselineSectionCount)
            #expect(sections.map { $0.formats.count } == baselineRowCounts)
            #expect(sections.map { $0.formats } == baselineFormats)
        }
    }

    @Test("Wero localization key resolves to \"Wero QR code\" (R6)")
    func weroStringKeyResolves() {
        #expect(Self.weroString == "Wero QR code")
    }

    @Test("Slot-11 row renders the Wero string with supportedFormats icon (R5)")
    @MainActor
    func weroRowRendersSupportedFormatsIconAndText() throws {
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let dataSource = HelpFormatsDataSource(isQRCodeContent: true)
            let tableView = UITableView(frame: .zero, style: .insetGrouped)
            tableView.register(UINib(nibName: "HelpFormatCell", bundle: giniCaptureBundle()),
                               forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)

            let indexPath = IndexPath(row: 10, section: 0)
            let cell = try #require(
                dataSource.tableView(tableView, cellForRowAt: indexPath) as? HelpFormatCell
            )

            #expect(cell.descriptionLabel.text == Self.weroString)
            #expect(cell.accessibilityLabel == Self.weroString)
            #expect(cell.iconImageView.image != nil)
        }
    }
}
