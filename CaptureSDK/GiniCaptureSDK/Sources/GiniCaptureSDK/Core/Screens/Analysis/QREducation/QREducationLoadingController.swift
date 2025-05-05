//
//  QREducationLoadingController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

final class QREducationLoadingController {
    private weak var loadingView: QREducationLoadingView?
    private var timer: Timer?
    private var models: [QREducationLoadingModel] = []
    private var currentIndex = 0

    init(loadingView: QREducationLoadingView) {
        self.loadingView = loadingView
    }

    func setRotatingModels(_ models: [QREducationLoadingModel]) {
        stop()
        guard !models.isEmpty else { return }

        self.models = models
        self.currentIndex = 0
        showCurrentModel()
    }

    private func showCurrentModel() {
        guard currentIndex < models.count else { return }

        let model = models[currentIndex]
        loadingView?.configure(with: model)

        if currentIndex < models.count - 1 {
            timer = Timer.scheduledTimer(timeInterval: model.duration,
                                         target: self,
                                         selector: #selector(nextModel),
                                         userInfo: nil,
                                         repeats: false)
        }
    }

    @objc private func nextModel() {
        currentIndex += 1
        showCurrentModel()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stop()
    }
}
