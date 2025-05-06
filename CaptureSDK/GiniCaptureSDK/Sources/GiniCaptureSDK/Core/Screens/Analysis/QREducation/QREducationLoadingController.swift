//
//  QREducationLoadingController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

final class QREducationLoadingController {
    private weak var loadingView: QREducationLoadingView?
    private var timer: Timer?
    private var itemQueue: [QREducationLoadingItem] = []

    init(loadingView: QREducationLoadingView) {
        self.loadingView = loadingView
    }

    func start(with items: [QREducationLoadingItem]) {
        stop()
        guard !items.isEmpty else { return }

        self.itemQueue = items
        showNextItem()
    }

    @objc private func showNextItem() {
        guard !itemQueue.isEmpty else { return }

        let nextItem = itemQueue.removeFirst()
        loadingView?.configure(with: nextItem)

        if !itemQueue.isEmpty {
            timer = Timer.scheduledTimer(timeInterval: nextItem.duration,
                                         target: self,
                                         selector: #selector(showNextItem),
                                         userInfo: nil,
                                         repeats: false)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stop()
    }
}
