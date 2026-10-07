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
     (e.g. `cell(for: "Bank")`).
     */
    func cell(for bankName: String) -> XCUIElement {
        app.cells["bankSelection.cell.\(bankName)"]
    }

    /**
     Returns the first available bank cell — any row whose identifier starts
     with `bankSelection.cell.`. Used by tests that only need to prove the
     flow landed in Payment Review and don't care which specific bank is
     picked (e.g. HEAL-285 locally, where the client config may list a
     different lineup than the HEAL-282 BrowserStack build).
     */
    var anyBankCell: XCUIElement {
        app.cells
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "bankSelection.cell."))
            .firstMatch
    }
}
