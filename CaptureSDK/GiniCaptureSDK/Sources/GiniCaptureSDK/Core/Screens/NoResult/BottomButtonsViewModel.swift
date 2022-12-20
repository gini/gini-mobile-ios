//
//  BottomButtonsViewModel.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 23/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation

final class BottomButtonsViewModel {
    let retakePressed: (() -> Void)?
    let enterManuallyPressed: (() -> Void)?
    let cancelPressed: (() -> Void)

    init(
        retakeBlock: (() -> Void)? = nil,
        manuallyPressed: (() -> Void)? = nil,
        cancelPressed: @escaping(() -> Void)) {
        self.retakePressed = retakeBlock
        self.enterManuallyPressed = manuallyPressed
        self.cancelPressed = cancelPressed
    }

    @objc func didPressRetake() {
        retakePressed?()
    }

    @objc func didPressEnterManually() {
        enterManuallyPressed?()
    }

    @objc func didPressCancell() {
        cancelPressed()
    }

    func isEnterManuallyHidden() -> Bool {
        return enterManuallyPressed == nil
    }

    func isRetakePressedHidden() -> Bool {
        return retakePressed == nil
    }
}
