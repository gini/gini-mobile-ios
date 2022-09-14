//
//  CameraButtonsViewModel.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//

import Foundation

public final class CameraButtonsViewModel {
    var isFlashOn: Bool = false
    var flashAction: (( Bool) -> Void)?
    var importAction: (() -> Void)?
    var captureAction: (() -> Void)?
    var imageStackAction: (() -> Void)?
    
    enum ButtonAction: Equatable {
        case fileImport, capture, imagesStack, flashToggle(Bool)
    }

    @objc func toggleFlash() {
        isFlashOn = !isFlashOn
    }
    
    @objc func importPressed() {
        cameraButtons(didTapOn: .fileImport)
    }
    
    @objc func thumbnailPressed() {
        cameraButtons(didTapOn: .imagesStack)
    }
    
    @objc func capturePressed() {
        cameraButtons(didTapOn: .capture)
    }
    
    func cameraButtons(didTapOn button: ButtonAction) {
        switch button {
        case let .flashToggle(isOn):
            flashAction?(isOn)
        case .fileImport:
            importAction?()
        case .capture:
            captureAction?()
        case .imagesStack:
            imageStackAction?()
        }
    }
    
}
