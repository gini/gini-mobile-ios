//
//  SettingsViewController+Types.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

extension SettingsViewController {
	enum SectionType {
		case switchOption(data: SwitchOptionModel)
		case fileImportType(data: SegmentedOptionModel)
	}
}
