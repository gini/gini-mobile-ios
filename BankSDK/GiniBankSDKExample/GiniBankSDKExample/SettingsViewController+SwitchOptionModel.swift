//
//  SettingsViewController+SwitchOptionModel.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 16.06.23.
//

struct SwitchOptionModel {
	let type: OptionType
	var isActive: Bool
	
	enum OptionType {
		case openWith
		case qrCodeScanning
		case qrCodeScanningOnly
		case multipage
		case flashToggle
		case flashOnByDefault
		case bottomNavigationBar
		case onboardingShowAtLaunch
		case customOnboardingPages
		case onButtonLoadingIndicator
		case customLoadingIndicator
		case shouldShowSupportedFormatsScreen
		case customMenuItems
		
		var title: String {
			switch self {
			case .openWith:
				return "Open with"
			case .qrCodeScanning:
				return "QR code scanning"
			case .qrCodeScanningOnly:
				return "QR code scanning only"
			case .multipage:
				return "Multipage"
			case .flashToggle:
				return "Flash toggle"
			case .flashOnByDefault:
				return "Flash ON by default"
			case .bottomNavigationBar:
				return "Bottom navigation bar"
			case .onboardingShowAtLaunch:
				return "Show Onboarding screens at launch"
			case .customOnboardingPages:
				return "Custom onboarding pages"
			case .onButtonLoadingIndicator:
				return "Buttons custom loading indicator"
			case .customLoadingIndicator:
				return "Screen custom loading indicator"
			case .shouldShowSupportedFormatsScreen:
				return "Supported formats screen"
			case .customMenuItems:
				return "Help custom menu items"
			}
		}
		
		var message: String? {
			switch self {
			case .qrCodeScanningOnly:
				return "This will work if the `qrCodeScanning` switch is also enabled."
			case .flashOnByDefault:
				return "This will work if the `flashToggle` switch is also enabled."
			case .customOnboardingPages:
				return "This will work if the `onboardingShowAtLaunch` switch is also enabled."
			case .onButtonLoadingIndicator:
				return "Set custom loading indicator on the buttons which support loading."
			case .customLoadingIndicator:
				return "Show a custom loading indicator on the document analysis screen."
			case .shouldShowSupportedFormatsScreen:
				return "In case of `off` the option won't be shown in the Help menu."
			default:
				return nil
			}
		}
	}
}
