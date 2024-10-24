//
//  SettingsViewController+SettingsButtonStates.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 27.06.23.
//

import Foundation
import GiniCaptureSDK

final class SettingsButtonStates {
	var primaryButtonState: ButtonState
	var secondaryButtonState: ButtonState
	var transparentButtonState: ButtonState
	var cameraControlButtonState: ButtonState
	var addPageButtonState: ButtonState
	
	init(primaryButtonState: ButtonState,
		 secondaryButtonState: ButtonState,
		 transparentButtonState: ButtonState,
		 cameraControlButtonState: ButtonState,
		 addPageButtonState: ButtonState) {
		self.primaryButtonState = primaryButtonState
		self.secondaryButtonState = secondaryButtonState
		self.transparentButtonState = transparentButtonState
		self.cameraControlButtonState = cameraControlButtonState
		self.addPageButtonState = addPageButtonState
	}
	
	struct ButtonState {
		var configuration: ButtonConfiguration
		var isSwitchOn: Bool
        var type: ButtonType
	}
    
    enum ButtonType {
        case primary
        case secondary
        case transparent
        case cameraControl
        case addPage
    }
}
