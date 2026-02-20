//
//  ModuleHostView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

protocol BankSDKProtocol {
    var bankSDKProtocolDelegate: GiniBankSDKDelegate? { get set }
}

struct ModuleHostView: View, BankSDKProtocol {

    var viewModel: GiniBankSDKModel

    init(for viewModel: GiniBankSDKModel) {
        self.viewModel = viewModel
    }

    var bankSDKProtocolDelegate: GiniBankSDKDelegate? {
        get { viewModel.delegate }
        set { viewModel.delegate = newValue  }
    }

    var body: some View {
        viewModel.giniContentView
    }
}

