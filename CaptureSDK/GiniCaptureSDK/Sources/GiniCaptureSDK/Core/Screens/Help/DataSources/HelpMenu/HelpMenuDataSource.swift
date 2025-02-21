//
//  HelpMenuDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 28/07/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

protocol HelpMenuDataSourceDelegate: UIViewController {
    func didSelectHelpItem(at index: Int)
}

final class HelpMenuDataSource: HelpRoundedCornersDataSource<HelpMenuItem, HelpMenuCell> {

    private lazy var defaultItems: [HelpMenuItem] = {
        var defaultItems: [HelpMenuItem] = [ .noResultsTips]

        if giniConfiguration.shouldShowSupportedFormatsScreen {
            defaultItems.append(.supportedFormats)
        }
        if giniConfiguration.openWithEnabled {
            defaultItems.append(.openWithTutorial)
        }
        return defaultItems
    }()

    var helpItemsAnalyticsValues = [String]()
    weak var delegate: HelpMenuDataSourceDelegate?

    required init(configuration: GiniConfiguration) {
        super.init()
        self.items.append(contentsOf: defaultItems)
        self.items.append(contentsOf: configuration.customMenuItems)

        items.forEach { item in
            helpItemsAnalyticsValues.append(item.title)
        }
    }

    override func configureCell(cell: HelpMenuCell, indexPath: IndexPath) {
        cell.accessibilityTraits.insert(.button)
        cell.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark3).uiColor()
        cell.titleLabel.text = items[indexPath.row].title
        cell.titleLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1).uiColor()
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        let chevronImage = UIImageNamedPreferred(named: "chevron")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.image = chevronImage
        cell.accessoryView = chevronImageView
        cell.selectionStyle = .none
        cell.separatorView.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.light3,
            dark: UIColor.GiniCapture.dark4
        ).uiColor()
        if indexPath.row == self.items.count - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectHelpItem(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

}
