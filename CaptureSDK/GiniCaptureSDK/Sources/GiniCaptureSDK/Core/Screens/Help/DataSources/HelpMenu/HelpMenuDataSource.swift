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
        cell.backgroundColor = UIColorPreferred(named: "systemWhite")
        cell.textLabel?.text = items[indexPath.row].title
        cell.textLabel?.textColor = UIColorPreferred(named: "labelColor")
        cell.textLabel?.font = giniConfiguration.textStyleFonts[.body]
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        if indexPath.row == self.items.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
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
