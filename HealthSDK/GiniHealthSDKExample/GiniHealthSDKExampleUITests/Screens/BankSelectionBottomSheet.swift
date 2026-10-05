//
//  BankSelectionBottomSheet.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 UIKit bank-selection bottom sheet (`BanksBottomView` + `BankSelectionTableViewCell`).

 Cells are keyed by bank name (identifier set in
 `BankSelectionTableViewCell.updateCell(_:)`), so each bank is addressable
 without relying on cell index or on-screen position.
 */
final class BankSelectionBottomSheet {

    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    /**
     Returns the cell for the given bank display name
     (e.g. `cell(for: "Black bank")`).
     */
    func cell(for bankName: String) -> XCUIElement {
        app.cells["bankSelection.cell.\(bankName)"]
    }
}
