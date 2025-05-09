//
//  QREducationLoadingViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

final class QREducationLoadingViewModel: ObservableObject {
    @Published private(set) var currentItem: QREducationLoadingItem?

    private let items: [QREducationLoadingItem]
    private var task: Task<Void, Never>?

    init(items: [QREducationLoadingItem]) {
        self.items = items
    }

    func start() {
        stop()

        guard !items.isEmpty else { return }

        task = Task {
            for item in items {
                await MainActor.run {
                    self.currentItem = item
                }
                try? await Task.sleep(nanoseconds: item.duration.nanoseconds)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    deinit {
        stop()
    }
}

fileprivate extension TimeInterval {
    var nanoseconds: UInt64 {
        UInt64(self * 1_000_000_000)
    }
}
