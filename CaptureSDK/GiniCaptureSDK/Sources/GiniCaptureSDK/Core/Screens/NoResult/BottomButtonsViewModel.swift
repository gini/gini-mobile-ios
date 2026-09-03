//
//  BottomButtonsViewModel.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 23/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation

final class BottomButtonsViewModel {
    private let retakePressed: (() -> Void)?
    private let enterManuallyPressed: (() -> Void)?
    private let backPressed: (() -> Void)

    init(retakeBlock: (() -> Void)? = nil,
         manuallyPressed: (() -> Void)? = nil,
         backPressed: @escaping (() -> Void)) {
        self.retakePressed = retakeBlock
        self.enterManuallyPressed = manuallyPressed
        self.backPressed = backPressed
    }

    @objc func didPressRetake() {
        errorOccurred = false
        retakePressed?()
    }

    @objc func didPressEnterManually() {
        errorOccurred = false
        enterManuallyPressed?()
    }

    @objc func didPressBack() {
        errorOccurred = false
        backPressed()
    }

    func isEnterManuallyHidden() -> Bool {
        return enterManuallyPressed == nil
    }

    func isRetakePressedHidden() -> Bool {
        return retakePressed == nil
    }
}
