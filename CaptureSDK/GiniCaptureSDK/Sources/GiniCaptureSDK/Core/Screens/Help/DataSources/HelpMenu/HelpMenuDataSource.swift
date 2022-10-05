//
//  HelpMenuDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 28/07/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

protocol HelpMenuDataSourceDelegate: UIViewController {
    func didSelectHelpItem(didSelect item: HelpMenuItem)
}

final public class HelpMenuDataSource: HelpRoundedCornersDataSource<HelpMenuItem, HelpMenuCell> {

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

    weak var delegate: HelpMenuDataSourceDelegate?

    required init(
        configuration: GiniConfiguration
    ) {
        super.init(configuration: configuration)
        self.items.append(contentsOf: defaultItems)
        self.items.append(contentsOf: configuration.customMenuItems)
    }

    public override func configureCell(cell: HelpMenuCell, indexPath: IndexPath) {
        cell.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark3).uiColor()
        cell.titleLabel.text = items[indexPath.row].title
        cell.titleLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1).uiColor()
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        cell.accessoryType = .disclosureIndicator
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
    public  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        self.delegate?.didSelectHelpItem(didSelect: item)
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

}
