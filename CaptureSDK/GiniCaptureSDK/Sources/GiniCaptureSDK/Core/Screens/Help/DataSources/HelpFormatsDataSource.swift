//
//  HelpFormatsDataSource.swift
//
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

typealias HelpFormatsCollectionSection = (title: String,
                                          formats: [String],
                                          formatsImage: UIImage?)

class HelpFormatsDataSource: HelpRoundedCornersDataSource<HelpFormatsCollectionSection, HelpFormatCell> {

    // MARK: - Properties

    lazy var qrCodeItemSections: [HelpFormatsCollectionSection] = {
        var sections: [HelpFormatsCollectionSection] = [
            (Strings.section1Title,
             [Strings.qrcodeItem1,
              Strings.qrcodeItem2,
              Strings.qrcodeItem3,
              Strings.qrcodeItem4,
              Strings.qrcodeItem5],
             Images.supportedFormatsIcon)
        ]

        return sections
    }()

    lazy var pdfItemSections: [HelpFormatsCollectionSection] = {
        var sections: [HelpFormatsCollectionSection] = [
            (Strings.section1Title,
             [Strings.section1Item1],
             Images.supportedFormatsIcon),
            (Strings.section2Title,
             [Strings.section2Item1],
             Images.nonSupportedFormatsIcon)
        ]

        if giniConfiguration.fileImportSupportedTypes != .none {
            if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
                sections[0].formats.append(Strings.section1Item2)
            }
            sections[0].formats.append(Strings.section1Item3)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            sections[0].formats.append(Strings.section1Item4)
        }

        sections[0].formats.append(Strings.section1Item5)

        if GiniCaptureUserDefaultsStorage.eInvoiceEnabled ?? false {
            sections[0].formats.append(Strings.section1Item6)
        }

        return sections
    }()

    override var items: [HelpFormatsCollectionSection] {
        get {
            if isQRCodeContent {
                return qrCodeItemSections
            }
            return pdfItemSections
        }
        set {
            if isQRCodeContent {
                qrCodeItemSections = newValue
            }
            pdfItemSections = newValue
        }
    }

    private let isQRCodeContent: Bool

    init(isQRCodeContent: Bool = false) {
        self.isQRCodeContent = isQRCodeContent
        super.init()
    }

    private func configureCellAccessibility(
        cell: HelpFormatCell,
        title: String) {
            cell.iconImageView?.accessibilityTraits = .image
            cell.iconImageView.accessibilityLabel = title
        }

    override func configureCell(cell: HelpFormatCell, indexPath: IndexPath) {
        let section = items[indexPath.section]
        let item = section.formats[indexPath.row]
        cell.descriptionLabel.text = item
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.descriptionLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1).uiColor()
        cell.descriptionLabel.adjustsFontForContentSizeCategory = true
        cell.iconImageView.image = section.formatsImage
        cell.iconImageView.backgroundColor = UIColor.clear
        cell.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark3).uiColor()
        cell.separatorView.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.light3,
            dark: UIColor.GiniCapture.dark4).uiColor()
        configureCellAccessibility(cell: cell, title: section.title.uppercased())
        if indexPath.row == items[indexPath.section].formats.count - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
    }

    private func configureHeader(
        header: HelpFormatSectionHeader,
        section: Int) {
            header.titleLabel.font = giniConfiguration.textStyleFonts[.caption1]
            header.titleLabel.adjustsFontForContentSizeCategory = true
            header.titleLabel.numberOfLines = 0
            header.titleLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                    dark: UIColor.GiniCapture.light1).uiColor()
            header.titleLabel.text = items[section].title.uppercased()
            header.backgroundView?.backgroundColor = UIColor.clear
        }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HelpFormatSectionHeader.reuseIdentifier
        ) as? HelpFormatSectionHeader {
            configureHeader(header: header, section: section)
            return header
        }
        fatalError("Section header is missing")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: HelpFormatCell.reuseIdentifier,
            for: indexPath) as? HelpFormatCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].formats.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - Strings

    private struct Strings {
        static let section1Title = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.title",
            comment: "supported format for section 1 title"
        )

        static let section2Title = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.2.title",
            comment: "supported format for section 2 title"
        )

        static let qrcodeItem1 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.qrcode.item.1",
            comment: "QR code type item 1"
        )

        static let qrcodeItem2 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.qrcode.item.2",
            comment: "QR code type item 2"
        )

        static let qrcodeItem3 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.qrcode.item.3",
            comment: "QR code type item 3"
        )

        static let qrcodeItem4 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.qrcode.item.4",
            comment: "QR code type item 4"
        )

        static let qrcodeItem5 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.qrcode.item.5",
            comment: "QR code type item 5"
        )

        static let section1Item1 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.1",
            comment: "supported format for section 1 item 1"
        )

        static let section1Item2 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.2",
            comment: "supported format for section 1 item 2"
        )

        static let section1Item3 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.3",
            comment: "supported format for section 1 item 3"
        )

        static let section1Item4 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.4",
            comment: "supported format for section 1 item 4"
        )

        static let section1Item5 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.5",
            comment: "supported format for section 1 item 5"
        )

        static let section1Item6 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.1.item.6",
            comment: "supported format for section 1 item 6"
        )

        static let section2Item1 = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.section.2.item.1",
            comment: "supported format for section 2 item 1"
        )
    }

    private struct Images {
        static let supportedFormatsIcon =  UIImageNamedPreferred(named: "supportedFormatsIcon")
        static let nonSupportedFormatsIcon = UIImageNamedPreferred(named: "nonSupportedFormatsIcon")
    }
}
