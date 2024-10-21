//
//  SettingsViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK
import UIKit

protocol SettingsViewModelDelegate: AnyObject {
    func contentDataUpdated()
}

final class SettingsViewModel {
    private var giniConfiguration: GiniBankConfiguration
    private var settingsButtonStates: SettingsButtonStates
    private var documentValidationsState: DocumentValidationsState
    private(set) var contentData: [SettingsSection] = []

    weak var delegate: SettingsViewModelDelegate?
    
    private var flashToggleSettingEnabled: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)?.hasFlash ?? false
        #endif
    }()
    
    init(apiEnvironment: APIEnvironment,
         client: Client? = nil,
         giniConfiguration: GiniBankConfiguration,
         settingsButtonStates: SettingsButtonStates,
         documentValidationsState: DocumentValidationsState) {
        self.giniConfiguration = giniConfiguration
        self.settingsButtonStates = settingsButtonStates
        self.documentValidationsState = documentValidationsState
        setupSectionedContentData(apiEnvironment: apiEnvironment, client: client)
    }
    
    private func setupSectionedContentData(apiEnvironment: APIEnvironment,
                                      client: Client? = nil) {
        var sections: [SettingsSection] = []

        // Default configuration
        var defaultConfigSection = SettingsSection(title: "Default Configuration", items: [])
        defaultConfigSection.items.append(.info(message: "Please relaunch the app to use the default GiniConfiguration values."))
        sections.append(defaultConfigSection)
        
        // Credentials
        var credentialsSection = SettingsSection(title: "Credentials", items: [])
        credentialsSection.items.append(.credentials(data: .init(clientId: client?.id ?? "", secretId: client?.secret ?? "")))
        var selectedAPISegmentIndex = 0
        switch apiEnvironment {
        case .production:
            selectedAPISegmentIndex = 0
        case .stage:
            selectedAPISegmentIndex = 1
        }
        credentialsSection.items.append(.segmentedOption(data: APIEnvironmentSegmentedOptionModel(selectedIndex: selectedAPISegmentIndex)))
        sections.append(credentialsSection)

        // Feature toggles
        var featureTogglesSection = SettingsSection(title: "Feature Toggles", items: [])
        var selectedFileImportTypeSegmentIndex = 0
        switch giniConfiguration.fileImportSupportedTypes {
        case .none:
            selectedFileImportTypeSegmentIndex = 0
        case .pdf:
            selectedFileImportTypeSegmentIndex = 1
        case .pdf_and_images:
            selectedFileImportTypeSegmentIndex = 2
        }
        featureTogglesSection.items.append(.segmentedOption(data: FileImportSegmentedOptionModel(selectedIndex: selectedFileImportTypeSegmentIndex)))
        
        featureTogglesSection.items.append(.switchOption(data: .init(type: .openWith,
                                                     isSwitchOn: giniConfiguration.openWithEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .qrCodeScanning,
                                                     isSwitchOn: giniConfiguration.qrCodeScanningEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .qrCodeScanningOnly,
                                                     isSwitchOn: giniConfiguration.onlyQRCodeScanningEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .multipage,
                                                     isSwitchOn: giniConfiguration.multipageEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .returnAssistantEnabled,
                                                     isSwitchOn: giniConfiguration.returnAssistantEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .skontoEnabled,
                                                     isSwitchOn: giniConfiguration.skontoEnabled)))
        featureTogglesSection.items.append(.switchOption(data: .init(type: .transactionDocsEnabled,
                                                     isSwitchOn: giniConfiguration.transactionDocsEnabled)))
        sections.append(featureTogglesSection)

        // Bottom navigation bars
        var bottomNavBarsSection = SettingsSection(title: "Bottom Navigation Bars", items: [])
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .bottomNavigationBar,
                                                     isSwitchOn: giniConfiguration.bottomNavigationBarEnabled)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .onboardingNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.onboardingNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .cameraNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.cameraNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .helpNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.helpNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .reviewNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.reviewNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .imagePickerNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.imagePickerNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .digitalInvoiceNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .digitalInvoiceHelpNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .digitalInvoiceSkontoNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceSkontoNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .skontoNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.skontoNavigationBarBottomAdapter != nil)))
        bottomNavBarsSection.items.append(.switchOption(data: .init(type: .skontoHelpNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.skontoHelpNavigationBarBottomAdapter != nil)))
        sections.append(bottomNavBarsSection)

        // Onboarding
        var onboardingSection = SettingsSection(title: "Onboarding", items: [])
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingShowAtLaunch,
                                                     isSwitchOn: giniConfiguration.onboardingShowAtLaunch)))
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingShowAtFirstLaunch,
                                                     isSwitchOn: giniConfiguration.onboardingShowAtFirstLaunch)))
        onboardingSection.items.append(.switchOption(data: .init(type: .customOnboardingPages,
                                                     isSwitchOn: giniConfiguration.customOnboardingPages != nil)))
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingAlignCornersIllustrationAdapter,
                                                     isSwitchOn: giniConfiguration.onboardingAlignCornersIllustrationAdapter != nil)))
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingLightingIllustrationAdapter,
                                                     isSwitchOn: giniConfiguration.onboardingLightingIllustrationAdapter != nil)))
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingQRCodeIllustrationAdapter,
                                                     isSwitchOn: giniConfiguration.onboardingQRCodeIllustrationAdapter != nil)))
        onboardingSection.items.append(.switchOption(data: .init(type: .onboardingMultiPageIllustrationAdapter,
                                                     isSwitchOn: giniConfiguration.onboardingMultiPageIllustrationAdapter != nil)))
        sections.append(onboardingSection)

        // Camera
        if flashToggleSettingEnabled {
            var cameraSection = SettingsSection(title: "Camera", items: [])
            cameraSection.items.append(.switchOption(data: .init(type: .flashToggle,
                                                         isSwitchOn: giniConfiguration.flashToggleEnabled)))
            cameraSection.items.append(.switchOption(data: .init(type: .flashOnByDefault,
                                                         isSwitchOn: giniConfiguration.flashOnByDefault)))
            sections.append(cameraSection)
        }

        // Help
        var helpSection = SettingsSection(title: "Help", items: [])
        helpSection.items.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
                                                     isSwitchOn: giniConfiguration.shouldShowSupportedFormatsScreen)))
        helpSection.items.append(.switchOption(data: .init(type: .customMenuItems,
                                                     isSwitchOn: !giniConfiguration.customMenuItems.isEmpty)))
        sections.append(helpSection)

        // Return Assistant
        var returnAssistantSection = SettingsSection(title: "Return Assistant", items: [])
        returnAssistantSection.items.append(.switchOption(data: .init(type: .enableReturnReasons,
                                                     isSwitchOn: giniConfiguration.enableReturnReasons)))
        returnAssistantSection.items.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingIllustrationAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter != nil)))
        sections.append(returnAssistantSection)
        
        // Transaction Docs
        var transactionDocsSection = SettingsSection(title: "Transaction Docs", items: [])
        let alwaysAttachDocsValue = GiniBankConfiguration.shared.transactionDocsDataCoordinator.getAlwaysAttachDocsValue()
        transactionDocsSection.items.append(.userDefaults(message: "Reset TransactionDocs 'always attach' flag from UserDefaults",
                                         buttonActive: alwaysAttachDocsValue))
        sections.append(transactionDocsSection)

        // General UI customization
        var uiCustomizationSection = SettingsSection(title: "General UI Customization", items: [])
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .primaryButtonConfiguration,
                                                     isSwitchOn: settingsButtonStates.primaryButtonState.isSwitchOn)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .secondaryButtonConfiguration,
                                                     isSwitchOn: settingsButtonStates.secondaryButtonState.isSwitchOn)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .transparentButtonConfiguration,
                                                     isSwitchOn: settingsButtonStates.transparentButtonState.isSwitchOn)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .cameraControlButtonConfiguration,
                                                     isSwitchOn: settingsButtonStates.cameraControlButtonState.isSwitchOn)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .addPageButtonConfiguration,
                                                     isSwitchOn: settingsButtonStates.addPageButtonState.isSwitchOn)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .customLoadingIndicator,
                                                     isSwitchOn: giniConfiguration.customLoadingIndicator != nil)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .onButtonLoadingIndicator,
                                                     isSwitchOn: giniConfiguration.onButtonLoadingIndicator != nil)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .customNavigationController,
                                                     isSwitchOn: giniConfiguration.customNavigationController != nil)))
        uiCustomizationSection.items.append(.switchOption(data: .init(type: .customResourceProvider,
                                                     isSwitchOn: giniConfiguration.customResourceProvider != nil)))
        if UIDevice.current.isIpad {
            uiCustomizationSection.items.append(.switchOption(data: .init(type: .shouldShowDragAndDropTutorial,
                                                                          isSwitchOn: giniConfiguration.shouldShowDragAndDropTutorial)))
        }
        sections.append(uiCustomizationSection)

        // Debug and Development Options
        var debugSection = SettingsSection(title: "Debug and Development Options", items: [])
        debugSection.items.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
                                                     isSwitchOn: giniConfiguration.giniErrorLoggerIsOn)))
        debugSection.items.append(.switchOption(data: .init(type: .customGiniErrorLogger,
                                                     isSwitchOn: giniConfiguration.customGiniErrorLoggerDelegate != nil)))
        debugSection.items.append(.switchOption(data: .init(type: .debugModeOn,
                                                     isSwitchOn: giniConfiguration.debugModeOn)))
        debugSection.items.append(.switchOption(data: .init(type: .customDocumentValidations,
                                                     isSwitchOn: documentValidationsState.isSwitchOn)))
        sections.append(debugSection)

        contentData = sections
    }
    
    func handleOnToggle(at indexPath: IndexPath, isSwitchOn: Bool) {
        let option = contentData[indexPath.section].items[indexPath.row]
        guard case .switchOption(var data) = option else { return }
        data.isSwitchOn = isSwitchOn
        contentData[indexPath.section].items[indexPath.row] = .switchOption(data: data)
        
        switch data.type {
        case .openWith:
            giniConfiguration.openWithEnabled = data.isSwitchOn
        case .qrCodeScanning:
            // TODO: check if flash logic correctly removed
            giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
            if !data.isSwitchOn && giniConfiguration.onlyQRCodeScanningEnabled {
                // if `qrCodeScanningEnabled` is disabled and `onlyQRCodeScanningEnabled` is enabled,
                // make `onlyQRCodeScanningEnabled` disabled
                // onlyQRCodeScanningEnabled cell is right after
                let option = SettingsViewController.CellType.switchOption(data:(SwitchOptionModel(type: .qrCodeScanningOnly, isSwitchOn: data.isSwitchOn)))
                contentData[indexPath.section].items[indexPath.row + 1] = option
                delegate?.contentDataUpdated()
                giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
            }
        case .qrCodeScanningOnly:
            giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
            if data.isSwitchOn && !giniConfiguration.qrCodeScanningEnabled {
                // if `onlyQRCodeScanningEnabled` is enabled and `qrCodeScanningEnabled` is disabled, make `qrCodeScanningEnabled` enabled
                // qrCodeScanningEnabled cell is right above this
                let option = SettingsViewController.CellType.switchOption(data:(SwitchOptionModel(type: .qrCodeScanning, isSwitchOn: data.isSwitchOn)))
                contentData[indexPath.section].items[indexPath.row - 1] = option
                delegate?.contentDataUpdated()
                giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
            }
        case .multipage:
            giniConfiguration.multipageEnabled = data.isSwitchOn
        case .flashToggle:
            giniConfiguration.flashToggleEnabled = data.isSwitchOn
            if !data.isSwitchOn && giniConfiguration.flashOnByDefault {
                // if `flashToggle` is disabled and `flashOnByDefault` is enabled, make `flashOnByDefault` disabled
                // flashOnByDefault cell is right after
                let option = SettingsViewController.CellType.switchOption(data:(SwitchOptionModel(type: .flashOnByDefault, isSwitchOn: data.isSwitchOn)))
                contentData[indexPath.section].items[indexPath.row + 1] = option
                delegate?.contentDataUpdated()
                giniConfiguration.flashOnByDefault = data.isSwitchOn
            }
        case .flashOnByDefault:
            giniConfiguration.flashOnByDefault = data.isSwitchOn
            if data.isSwitchOn && !giniConfiguration.flashToggleEnabled {
                // if `flashOnByDefault` is enabled and `flashToggle` is disabled, make `flashToggle` enabled
                // flashToggle cell is right above this
                let option = SettingsViewController.CellType.switchOption(data:(SwitchOptionModel(type: .flashToggle, isSwitchOn: data.isSwitchOn)))
                contentData[indexPath.section].items[indexPath.row - 1] = option
                delegate?.contentDataUpdated()
                giniConfiguration.flashToggleEnabled = data.isSwitchOn
            }
        case .customResourceProvider:
            let customProvider = GiniBankCustomResourceProvider()
            giniConfiguration.customResourceProvider = data.isSwitchOn ? customProvider : nil
        case .bottomNavigationBar:
            giniConfiguration.bottomNavigationBarEnabled = data.isSwitchOn
        case .helpNavigationBarBottomAdapter:
            let customAdapter = CustomBottomNavigationBarAdapter()
            giniConfiguration.helpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .cameraNavigationBarBottomAdapter:
            let customAdapter = CustomCameraBottomNavigationBarAdapter()
            giniConfiguration.cameraNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .reviewNavigationBarBottomAdapter:
            let customAdapter = CustomReviewScreenBottomNavigationBarAdapter()
            giniConfiguration.reviewNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .imagePickerNavigationBarBottomAdapter:
            let customAdapter = CustomBottomNavigationBarAdapter()
            giniConfiguration.imagePickerNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .onboardingShowAtLaunch:
            giniConfiguration.onboardingShowAtLaunch = data.isSwitchOn
        case .onboardingShowAtFirstLaunch:
            giniConfiguration.onboardingShowAtFirstLaunch = data.isSwitchOn
            let onboardingShowedUserDefault = UserDefaults.standard.bool(forKey: "ginicapture.defaults.onboardingShowed")
            if !data.isSwitchOn && onboardingShowedUserDefault {
                UserDefaults.standard.removeObject(forKey: "ginicapture.defaults.onboardingShowed")
            }
        case .customOnboardingPages:
            let customPage1 = OnboardingPage(imageName: "captureSuggestion1",
                                             title: "Page 1",
                                             description: "Description for page 1")
            let customPage2 = OnboardingPage(imageName: "captureSuggestion2",
                                             title: "Page 2",
                                             description: "Description for page 2")
            let customPage3 = OnboardingPage(imageName: "captureSuggestion3",
                                             title: "Page 3",
                                             description: "Description for page 3")
            let customPage4 = OnboardingPage(imageName: "captureSuggestion4",
                                             title: "Page 4",
                                             description: "Description for page 4")
            let customPage5 = OnboardingPage(imageName: "captureSuggestion1",
                                             title: "Page 5",
                                             description: "Description for page 5")
            let customOnboardingPages = data.isSwitchOn ? [customPage1, customPage2, customPage3, customPage4, customPage5] : nil
            giniConfiguration.customOnboardingPages = customOnboardingPages
        case .onboardingAlignCornersIllustrationAdapter:
            let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "page1Animation",
                                                                    backgroundColor: .red)
            giniConfiguration.onboardingAlignCornersIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
        case .onboardingLightingIllustrationAdapter:
            let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "cameraAnimation",
                                                                    backgroundColor: .yellow)
            giniConfiguration.onboardingLightingIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
        case .onboardingQRCodeIllustrationAdapter:
            let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
                                                                    backgroundColor: .blue)
            giniConfiguration.onboardingQRCodeIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
        case .onboardingMultiPageIllustrationAdapter:
            let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "uploadAnimation",
                                                                    backgroundColor: .green)
            giniConfiguration.onboardingMultiPageIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
        case .onboardingNavigationBarBottomAdapter:
            let customAdapter = CustomOnboardingBottomNavigationBarAdapter()
            giniConfiguration.onboardingNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .onButtonLoadingIndicator:
            giniConfiguration.onButtonLoadingIndicator = data.isSwitchOn ? OnButtonLoading() : nil
        case .customLoadingIndicator:
            giniConfiguration.customLoadingIndicator = data.isSwitchOn ? CustomLoadingIndicator() : nil
        case .shouldShowSupportedFormatsScreen:
            giniConfiguration.shouldShowSupportedFormatsScreen = data.isSwitchOn
        case .customMenuItems:
            let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())
            giniConfiguration.customMenuItems = data.isSwitchOn ? [customMenuItem] : []
        case .customNavigationController:
            let navigationViewController = UINavigationController()
            navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
            giniConfiguration.customNavigationController = data.isSwitchOn ? navigationViewController : nil
        case .shouldShowDragAndDropTutorial:
            giniConfiguration.shouldShowDragAndDropTutorial = data.isSwitchOn
        case .returnAssistantEnabled:
            giniConfiguration.returnAssistantEnabled = data.isSwitchOn
        case .enableReturnReasons:
            giniConfiguration.enableReturnReasons = data.isSwitchOn
        case .skontoEnabled:
            giniConfiguration.skontoEnabled = data.isSwitchOn
        case .transactionDocsEnabled:
            giniConfiguration.transactionDocsEnabled = data.isSwitchOn
        case .giniErrorLoggerIsOn:
            giniConfiguration.giniErrorLoggerIsOn = data.isSwitchOn
        case .customGiniErrorLogger:
            if data.isSwitchOn && giniConfiguration.giniErrorLoggerIsOn {
                giniConfiguration.customGiniErrorLoggerDelegate = self
            } else {
                giniConfiguration.customGiniErrorLoggerDelegate = nil
            }
            
        case .debugModeOn:
            giniConfiguration.debugModeOn = data.isSwitchOn
        case .digitalInvoiceOnboardingIllustrationAdapter:
            let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
                                                                    backgroundColor: UIColor.blue)
            giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
        case .digitalInvoiceHelpNavigationBarBottomAdapter:
            let customAdapter = CustomBottomNavigationBarAdapter()
            giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .digitalInvoiceOnboardingNavigationBarBottomAdapter:
            let customAdapter = CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter()
            giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .digitalInvoiceNavigationBarBottomAdapter:
            let customAdapter = CustomDigitalInvoiceBottomNavigationBarAdapter()
            giniConfiguration.digitalInvoiceNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .digitalInvoiceSkontoNavigationBarBottomAdapter:
            let customAdapter = CustomDigitalInvoiceSkontoBottomNavigationBarAdapter()
            giniConfiguration.digitalInvoiceSkontoNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .primaryButtonConfiguration:
            guard data.isSwitchOn else {
                giniConfiguration.primaryButtonConfiguration = settingsButtonStates.primaryButtonState.configuration
                return
            }
            settingsButtonStates.primaryButtonState.isSwitchOn = data.isSwitchOn
            
            let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
                                                          borderColor: .red,
                                                          titleColor: .green,
                                                          shadowColor: .clear,
                                                          cornerRadius: 22,
                                                          borderWidth: 4,
                                                          shadowRadius: 0,
                                                          withBlurEffect: false)
            giniConfiguration.primaryButtonConfiguration = buttonConfiguration
        case .secondaryButtonConfiguration:
            guard data.isSwitchOn else {
                giniConfiguration.secondaryButtonConfiguration = settingsButtonStates.secondaryButtonState.configuration
                return
            }
            settingsButtonStates.secondaryButtonState.isSwitchOn = data.isSwitchOn
            let buttonConfiguration = ButtonConfiguration(backgroundColor: .cyan,
                                                          borderColor: .blue,
                                                          titleColor: .green,
                                                          shadowColor: .clear,
                                                          cornerRadius: 22,
                                                          borderWidth: 4,
                                                          shadowRadius: 0,
                                                          withBlurEffect: false)
            giniConfiguration.secondaryButtonConfiguration = buttonConfiguration
        case .transparentButtonConfiguration:
            guard data.isSwitchOn else {
                giniConfiguration.transparentButtonConfiguration = settingsButtonStates.transparentButtonState.configuration
                return
            }
            settingsButtonStates.transparentButtonState.isSwitchOn = data.isSwitchOn
            let buttonConfiguration = ButtonConfiguration(backgroundColor: .green,
                                                          borderColor: .yellow,
                                                          titleColor: .green,
                                                          shadowColor: .clear,
                                                          cornerRadius: 22,
                                                          borderWidth: 4,
                                                          shadowRadius: 0,
                                                          withBlurEffect: false)
            giniConfiguration.transparentButtonConfiguration = buttonConfiguration
        case .cameraControlButtonConfiguration:
            guard data.isSwitchOn else {
                giniConfiguration.cameraControlButtonConfiguration = settingsButtonStates.cameraControlButtonState.configuration
                return
            }
            settingsButtonStates.cameraControlButtonState.isSwitchOn = data.isSwitchOn
            let buttonConfiguration = ButtonConfiguration(backgroundColor: .magenta,
                                                          borderColor: .lightGray,
                                                          titleColor: .green,
                                                          shadowColor: .clear,
                                                          cornerRadius: 22,
                                                          borderWidth: 4,
                                                          shadowRadius: 0,
                                                          withBlurEffect: false)
            giniConfiguration.cameraControlButtonConfiguration = buttonConfiguration
        case .addPageButtonConfiguration:
            guard data.isSwitchOn else {
                giniConfiguration.addPageButtonConfiguration = settingsButtonStates.addPageButtonState.configuration
                return
            }
            settingsButtonStates.addPageButtonState.isSwitchOn = data.isSwitchOn
            let buttonConfiguration = ButtonConfiguration(backgroundColor: .white,
                                                          borderColor: .red,
                                                          titleColor: .green,
                                                          shadowColor: .clear,
                                                          cornerRadius: 22,
                                                          borderWidth: 4,
                                                          shadowRadius: 0,
                                                          withBlurEffect: false)
            giniConfiguration.addPageButtonConfiguration = buttonConfiguration
        case .customDocumentValidations:
            guard data.isSwitchOn else {
                giniConfiguration.customDocumentValidations = documentValidationsState.validations
                return
            }
            documentValidationsState.isSwitchOn = data.isSwitchOn
            giniConfiguration.customDocumentValidations = { document in
                // As an example of custom document validation, we add a more strict check for file size
                let maxFileSize = 0.5 * 1024 * 1024
                if document.data.count > Int(maxFileSize) {
                    let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als \(maxFileSize)MB")
                    return CustomDocumentValidationResult.failure(withError: error)
                }
                return CustomDocumentValidationResult.success()
            }
        case .skontoNavigationBarBottomAdapter:
            let customAdapter = CustomSkontoNavigationBarBottomAdapter()
            giniConfiguration.skontoNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .skontoHelpNavigationBarBottomAdapter:
            let customAdapter = CustomBottomNavigationBarAdapter()
            giniConfiguration.skontoHelpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        }
    }
    
    func handleFileImportOption(fileImportIndex: Int) {
        switch fileImportIndex {
        case 0:
            giniConfiguration.fileImportSupportedTypes = .none
        case 1:
            giniConfiguration.fileImportSupportedTypes = .pdf
        case 2:
            giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        default:
            return
        }
    }
}

extension SettingsViewModel: GiniCaptureErrorLoggerDelegate {
    func handleErrorLog(error: GiniCaptureSDK.ErrorLog) {
        print("💻 custom - log error event called")
    }
}
