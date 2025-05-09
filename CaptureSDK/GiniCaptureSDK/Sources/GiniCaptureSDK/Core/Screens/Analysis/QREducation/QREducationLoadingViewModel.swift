//
//  QREducationLoadingViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import Combine

final class QREducationLoadingViewModel: ObservableObject {
    @Published private(set) var currentItem: QREducationLoadingItem?

    private let items: [QREducationLoadingItem]
    private var task: Task<Void, Never>?

    let completion = PassthroughSubject<Void, Never>()

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
                try? await Task.sleep(nanoseconds: item.durationInNanoseconds)
            }
            
            // At end of loop → emit completion
            await MainActor.run {
                self.completion.send()
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
