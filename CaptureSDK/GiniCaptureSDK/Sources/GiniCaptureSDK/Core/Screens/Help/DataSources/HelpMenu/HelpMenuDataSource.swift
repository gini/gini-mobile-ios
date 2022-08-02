//
//  HelpMenuDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 28/07/2022.
//

import UIKit

protocol HelpMenuDataSourceDelegate: UIViewController {
    func didSelectHelpItem(didSelect item: HelpMenuItem)
}

final public class HelpMenuDataSource: HelpBaseDataSource<HelpMenuItem, HelpMenuCell> {
    
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

    override init(
        configuration: GiniConfiguration
    ) {
        super.init(configuration: configuration)
        self.items.append(contentsOf: defaultItems)
        self.items.append(contentsOf: giniConfiguration.customMenuItems)
    }

    public override func configureCell(cell: HelpMenuCell, indexPath: IndexPath) {

        cell.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenCellsBackgroundColor)
        cell.textLabel?.text = items[indexPath.row].title
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
    }

    // MARK: - UITableViewDelegate
    public  override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        self.delegate?.didSelectHelpItem(didSelect: item)
    }
}
