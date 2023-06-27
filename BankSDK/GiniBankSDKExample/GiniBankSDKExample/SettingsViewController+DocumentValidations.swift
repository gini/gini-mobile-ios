//
//  SettingsViewController+DocumentValidations.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 27.06.23.
//

import Foundation
import GiniCaptureSDK

final class DocumentValidationsState {
	var validations: ((GiniCaptureDocument) -> CustomDocumentValidationResult)
	var isSwitchOn: Bool
	
	init(validations: @escaping (GiniCaptureDocument) -> CustomDocumentValidationResult,
		 isSwitchOn: Bool) {
		self.validations = validations
		self.isSwitchOn = isSwitchOn
	}
}
