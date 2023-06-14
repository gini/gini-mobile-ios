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

struct SwitchOptionModel {
	let type: OptionType
	var isActive: Bool
	
	enum OptionType {
		case openWith
		case qrCodeScanning
		case qrCodeScanningOnly
		case multipage
		case flashToggle
		case bottomNaviagtionBar
		
		var title: String {
			switch self {
			case .openWith:
				return "Open with"
			case .qrCodeScanning:
				return "QR code scanning"
			case .qrCodeScanningOnly:
				return "QR Code Scanning Only"
			case .multipage:
				return "Multipage"
			case .flashToggle:
				return "Flash Toggle"
			case .bottomNaviagtionBar:
				return "Bottom Navigation Bar"
			}
		}
	}
}

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
