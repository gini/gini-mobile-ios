//
//  SettingsViewController+SwitchOptionModel.swift
//  GiniBankSDKExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

struct SwitchOptionModel {
	let type: OptionType
	var isSwitchOn: Bool
	
	enum OptionType {
		case openWith
		case qrCodeScanning
		case qrCodeScanningOnly
		case multipage
		case flashToggle
		case flashOnByDefault
        case customResourceProvider
		case onboardingShowAtLaunch
		case onboardingShowAtFirstLaunch
		case onboardingAlignCornersIllustrationAdapter
		case onboardingLightingIllustrationAdapter
		case onboardingQRCodeIllustrationAdapter
		case onboardingMultiPageIllustrationAdapter
		case customOnboardingPages
		case onButtonLoadingIndicator
		case customLoadingIndicator
		case shouldShowSupportedFormatsScreen
		case customMenuItems
		case customNavigationController
		case shouldShowDragAndDropTutorial // just for iPad
		case digitalInvoiceOnboardingIllustrationAdapter
		case primaryButtonConfiguration
		case secondaryButtonConfiguration
		case transparentButtonConfiguration
		case cameraControlButtonConfiguration
		case addPageButtonConfiguration
		case returnAssistantEnabled
		case customDocumentValidations
		case giniErrorLoggerIsOn
		case customGiniErrorLogger
		case debugModeOn
        case skontoEnabled
        case transactionDocsEnabled
        case alreadyPaidHintEnabled
        case savePhotosLocallyEnabled
        case paymentDueHintEnabled
        case closeSDK

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
				return "Display flash button"
			case .flashOnByDefault:
				return "Flash default state"
            case .customResourceProvider:
                return "Use custom resource provider"
			case .onboardingShowAtLaunch:
				return "Onboarding screens at every launch"
			case .onboardingShowAtFirstLaunch:
				return "Onboarding screens at first launch"
			case .onboardingAlignCornersIllustrationAdapter:
				return "Onboarding `align corners` page custom illustration"
			case .onboardingLightingIllustrationAdapter:
				return "Onboarding `lighting` page custom illustration"
			case .onboardingQRCodeIllustrationAdapter:
				return "Onboarding `QR code` page custom illustration"
			case .onboardingMultiPageIllustrationAdapter:
				return "Onboarding `multi page` page custom illustration"
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
			case .customNavigationController:
				return "Custom navigation controller"
			case .shouldShowDragAndDropTutorial:
				return "Drag and drop tutorial"
			case .digitalInvoiceOnboardingIllustrationAdapter:
				return "Digital invoice onboarding custom illustration"
			case .primaryButtonConfiguration:
				return "Custom configuration for the primary button"
			case .secondaryButtonConfiguration:
				return "Custom configuration for the secondary button"
			case .transparentButtonConfiguration:
				return "Custom configuration for the transparent button"
			case .cameraControlButtonConfiguration:
				return "Custom configuration for the camera control button"
			case .addPageButtonConfiguration:
				return "Custom configuration for the add page button"
			case .returnAssistantEnabled:
				return "Return Assistant feature"
            case .skontoEnabled:
                return "Skonto feature"
            case .transactionDocsEnabled:
                return "Transaction docs feature"
            case .alreadyPaidHintEnabled:
                return "User payment warnings feature"
            case .paymentDueHintEnabled:
                return "Payment due hint feature"
            case .savePhotosLocallyEnabled:
                return "Save Photos Locally feature"
			case .customDocumentValidations:
				return "Custom document validations"
			case .giniErrorLoggerIsOn:
				return "Gini error logger"
			case .customGiniErrorLogger:
				return "Custom Gini error logger"
			case .debugModeOn:
				return "Debug mode"
            case .closeSDK:
                return "Close SDK"
            }
		}
		
		var message: String? {
			switch self {
			case .qrCodeScanningOnly:
				return "This will work if the `QR code scanning` switch is also enabled."
            case .flashToggle:
                return "Display flash button in camera screen"
			case .flashOnByDefault:
				return "This will work if the `Flash button` switch is also enabled."
            case .customResourceProvider:
                return "Enables the customization of resources to override the default Gini resources. The change will affect all screens."
			case .onButtonLoadingIndicator:
				return "Set custom loading indicator on the buttons which support loading."
			case .customLoadingIndicator:
				return "Show a custom loading indicator on the document analysis screen."
			case .shouldShowSupportedFormatsScreen:
				return "Show the supported formats screen in the Help menu."
			case .shouldShowDragAndDropTutorial:
				return "Show drag and drop tutorial step in Help menu > How to import option."
			case .onboardingShowAtFirstLaunch:
				return "Overwrites `Onboarding screens at every launch` for the first launch."
			case .customOnboardingPages:
				return "This will work if the `Onboarding show at every launch` switch is also enabled."
			case .onboardingAlignCornersIllustrationAdapter:
				return "This will work if the `Onboarding show at every launch` switch is also enabled."
			case .onboardingLightingIllustrationAdapter:
				return "This will work if the `Onboarding show at every launch` switch is also enabled."
			case .onboardingQRCodeIllustrationAdapter:
				return "This will work if the `Onboarding show at every launch` switch is also enabled."
			case .onboardingMultiPageIllustrationAdapter:
				return "This will work if the `Onboarding show at every launch` switch is also enabled."
			case .primaryButtonConfiguration:
				return "Primary button used on different screens, e.g: `Onboarding`, `Digital Invoice Onboarding`, `Error`, etc."
			case .secondaryButtonConfiguration:
				return "Secondary button used on different screens: `No Results`, `Error`."
			case .transparentButtonConfiguration:
				return "Transparent button used on `Onboarding` screen in the bottom navigation bar."
			case .cameraControlButtonConfiguration:
				return "Camera control button used for `Browse` and `Flash` buttons on `Camera` screen."
			case .addPageButtonConfiguration:
				return "Add page button used on `Review `screen."
			case .returnAssistantEnabled:
				return "Present a digital representation of the invoice"
            case .skontoEnabled:
                return "Present Skonto"
			case .customDocumentValidations:
				return "Custom document validations that can be done apart from the default ones (file size, file type...)"
			case .customGiniErrorLogger:
				return "This will work if the `Gini error logger` is also enabled."
            case .alreadyPaidHintEnabled:
                return "Features included under this flag paid state"
            case .closeSDK:
                return "Self-destruct SDK after 10 seconds"
			default:
				return nil
			}
		}
	}
}
