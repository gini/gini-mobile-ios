//
//  NoResultViewModel.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 23/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation

public final class NoResultScreenViewModel {
    let retakePressed: (() -> Void)
    let enterManuallyPressed: (() -> Void)
    let cancelPressed: (() -> Void)

    public init(
        retakeBlock: @escaping (() -> Void),
        manuallyPressed: @escaping(() -> Void),
        cancelPressed: @escaping(() -> Void)) {
        self.retakePressed = retakeBlock
        self.enterManuallyPressed = manuallyPressed
        self.cancelPressed = cancelPressed
    }

    @objc func didPressRetake() {
        retakePressed()
    }

    @objc func didPressEnterManually() {
        enterManuallyPressed()
    }

    @objc func didPressCancell() {
        cancelPressed()
    }
}
