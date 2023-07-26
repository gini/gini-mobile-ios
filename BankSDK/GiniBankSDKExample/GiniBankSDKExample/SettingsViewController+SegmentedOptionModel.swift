//
//  SettingsViewController+SegmentedOptionModel.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 16.06.23.
//

struct SegmentedOptionModel {
	let title = "File import"
	let items: [SegmentedOptionModel.OptionType] = [.none, .pdf, .pdfAndImages]
	var selectedIndex: Int = 0
	
	enum OptionType {
		case none
		case pdf
		case pdfAndImages
		
		var title: String {
			switch self {
			case .none:
				return "Disabled"
			case .pdf:
				return "PDF"
			case .pdfAndImages:
				return "PDF & Images"
			}
		}
	}
}
