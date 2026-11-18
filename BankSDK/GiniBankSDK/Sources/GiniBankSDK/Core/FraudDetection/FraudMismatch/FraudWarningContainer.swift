//
//  FraudWarningContainer.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 Composition root for the fraud warning screen. Observes
 `FraudWarningViewModel` and drives the IBAN picker sheet at a medium
 detent when the user taps Proceed. Hosted by `FraudWarningCoordinator.start()`.
 */
struct FraudWarningContainer: View {

    @ObservedObject var viewModel: FraudWarningViewModel

    @State private var isShowingPicker: Bool = false

    var body: some View {
        FraudWarningView(viewModel: viewModel,
                         onCancel: viewModel.didTapCancel,
                         onProceed: { isShowingPicker = true })
            .sheet(isPresented: $isShowingPicker) {
                IBANPickerPlaceholder(onConfirm: {
                    isShowingPicker = false
                    viewModel.didTapProceed()
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}
