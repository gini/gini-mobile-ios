//
//  SettingsViewController+CellType.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

extension SettingsViewController {
	enum CellType {
		case info(message: String)
		case switchOption(data: SwitchOptionModel)
		case segmentedOption(data: SegmentedOptionModel)
        case credentials(data: CredentialsModel)
	}
}
