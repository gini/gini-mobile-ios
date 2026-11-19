//
//  FraudWarningContainer.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 Composition root for the fraud warning screen.

 Observes a `FraudWarningViewModel` and wires `FraudWarningView`'s button
 callbacks to the ViewModel's tap methods, keeping `FraudWarningView` free
 of any state dependency. Hosted inside a `UIHostingController` by
 `FraudWarningCoordinator.start()`.
 */
struct FraudWarningContainer: View {

    /** ViewModel backing the view; owned by the Coordinator, observed here. */
    @ObservedObject var viewModel: FraudWarningViewModel

    var body: some View {
        FraudWarningView(onCancel: viewModel.didTapCancel,
                         onProceed: viewModel.didTapProceed)
    }
}
