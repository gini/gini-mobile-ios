//
//  ImagePickerViewControllerDelegateMock.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
final class ImagePickerViewControllerDelegateMock: ImagePickerViewControllerDelegate {
    var selectedAssets: [Asset] = []

    func imagePicker(_ viewController: ImagePickerViewController, didSelectAsset asset: Asset, at index: IndexPath) {
        selectedAssets.append(asset)
        viewController.selectCell(at: index)
    }
    
    func imagePicker(_ viewController: ImagePickerViewController, didDeselectAsset asset: Asset, at index: IndexPath) {
        if let selectedIndex = selectedAssets.firstIndex(where: { $0.identifier == asset.identifier}) {
            selectedAssets.remove(at: selectedIndex)
        }
        viewController.deselectCell(at: index)
    }
    
}
