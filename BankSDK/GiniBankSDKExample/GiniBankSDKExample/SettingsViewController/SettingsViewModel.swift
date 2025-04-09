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
import AVFoundation

protocol SettingsViewModelDelegate: AnyObject {
    func contentDataUpdated()
}

final class SettingsViewModel {
    static private(set) var shouldCloseSDKAfterTenSeconds = false
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
        setupContentData(apiEnvironment: apiEnvironment, client: client)
    }

    private func setupContentData(apiEnvironment: APIEnvironment, client: Client? = nil) {
        var sections: [SettingsSection] = []
        
        sections.append(setupDefaultConfigSection())
        sections.append(setupCredentialsSection(apiEnvironment: apiEnvironment, client: client))
        sections.append(setupFeatureTogglesSection())
        sections.append(setupBottomNavBarsSection())
        sections.append(setupOnboardingSection())
        
        if flashToggleSettingEnabled {
            sections.append(setupCameraSection())
        }
        
        sections.append(setupHelpSection())
        sections.append(setupReturnAssistantSection())
        sections.append(setupTransactionDocsSection())
        sections.append(setupUICustomizationSection())
        sections.append(setupDebugSection())
        
        contentData = sections
    }

    private func setupDefaultConfigSection() -> SettingsSection {
        var defaultConfigSection = SettingsSection(title: "Default Configuration", items: [])
        defaultConfigSection.items.append(.info(message: "Please relaunch the app to use the default GiniConfiguration values."))
        return defaultConfigSection
    }

    private func setupCredentialsSection(apiEnvironment: APIEnvironment, client: Client? = nil) -> SettingsSection {
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
        return credentialsSection
    }

    private func setupFeatureTogglesSection() -> SettingsSection {
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
        return featureTogglesSection
    }

    private func setupBottomNavBarsSection() -> SettingsSection {
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
        return bottomNavBarsSection
    }

    private func setupOnboardingSection() -> SettingsSection {
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
        return onboardingSection
    }

    private func setupCameraSection() -> SettingsSection {
        var cameraSection = SettingsSection(title: "Camera", items: [])
        cameraSection.items.append(.switchOption(data: .init(type: .flashToggle,
                                                             isSwitchOn: giniConfiguration.flashToggleEnabled)))
        cameraSection.items.append(.switchOption(data: .init(type: .flashOnByDefault,
                                                             isSwitchOn: giniConfiguration.flashOnByDefault)))
        return cameraSection
    }

    private func setupHelpSection() -> SettingsSection {
        var helpSection = SettingsSection(title: "Help", items: [])
        helpSection.items.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
                                                           isSwitchOn: giniConfiguration.shouldShowSupportedFormatsScreen)))
        helpSection.items.append(.switchOption(data: .init(type: .customMenuItems,
                                                           isSwitchOn: !giniConfiguration.customMenuItems.isEmpty)))
        return helpSection
    }

    private func setupReturnAssistantSection() -> SettingsSection {
        var returnAssistantSection = SettingsSection(title: "Return Assistant", items: [])
        returnAssistantSection.items.append(.switchOption(data: .init(type: .enableReturnReasons,
                                                                      isSwitchOn: giniConfiguration.enableReturnReasons)))
        returnAssistantSection.items.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingIllustrationAdapter,
                                                                      isSwitchOn: giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter != nil)))
        return returnAssistantSection
    }

    private func setupTransactionDocsSection() -> SettingsSection {
        var transactionDocsSection = SettingsSection(title: "Transaction Docs", items: [])
        let alwaysAttachDocsValue = GiniBankConfiguration.shared.transactionDocsDataCoordinator.getAlwaysAttachDocsValue()
        transactionDocsSection.items.append(.userDefaults(message: "Reset TransactionDocs 'always attach' flag from UserDefaults",
                                                          buttonActive: alwaysAttachDocsValue))
        return transactionDocsSection
    }

    private func setupUICustomizationSection() -> SettingsSection {
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
        return uiCustomizationSection
    }

    private func setupDebugSection() -> SettingsSection {
        var debugSection = SettingsSection(title: "Debug and Development Options", items: [])
        debugSection.items.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
                                                            isSwitchOn: giniConfiguration.giniErrorLoggerIsOn)))
        debugSection.items.append(.switchOption(data: .init(type: .customGiniErrorLogger,
                                                            isSwitchOn: giniConfiguration.customGiniErrorLoggerDelegate != nil)))
        debugSection.items.append(.switchOption(data: .init(type: .debugModeOn,
                                                            isSwitchOn: giniConfiguration.debugModeOn)))
        debugSection.items.append(.switchOption(data: .init(type: .customDocumentValidations,
                                                            isSwitchOn: documentValidationsState.isSwitchOn)))
        debugSection.items.append(.switchOption(data: .init(type: .closeSDK,
                                                            isSwitchOn: Self.shouldCloseSDKAfterTenSeconds)))
        return debugSection
    }

    func handleOnToggle(at indexPath: IndexPath, isSwitchOn: Bool) {
        let option = contentData[indexPath.section].items[indexPath.row]
        guard case .switchOption(var data) = option else { return }
        data.isSwitchOn = isSwitchOn
        contentData[indexPath.section].items[indexPath.row] = .switchOption(data: data)
        
        updateGiniConfiguration(for: data)
        handleSwitchDependencies(for: data, at: indexPath)
    }

    private func updateGiniConfiguration(for data: SwitchOptionModel) {
        switch data.type {
        case .openWith:
            giniConfiguration.openWithEnabled = data.isSwitchOn
        case .qrCodeScanning:
            giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
        case .qrCodeScanningOnly:
            giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
        case .multipage:
            giniConfiguration.multipageEnabled = data.isSwitchOn
        case .flashToggle:
            giniConfiguration.flashToggleEnabled = data.isSwitchOn
        case .flashOnByDefault:
            giniConfiguration.flashOnByDefault = data.isSwitchOn
        case .customResourceProvider:
            giniConfiguration.customResourceProvider = data.isSwitchOn ? GiniBankCustomResourceProvider() : nil
        case .bottomNavigationBar:
            giniConfiguration.bottomNavigationBarEnabled = data.isSwitchOn
        case .helpNavigationBarBottomAdapter:
            giniConfiguration.helpNavigationBarBottomAdapter = data.isSwitchOn ? CustomBottomNavigationBarAdapter() : nil
        case .cameraNavigationBarBottomAdapter:
            giniConfiguration.cameraNavigationBarBottomAdapter = data.isSwitchOn ? CustomCameraBottomNavigationBarAdapter() : nil
        case .reviewNavigationBarBottomAdapter:
            giniConfiguration.reviewNavigationBarBottomAdapter = data.isSwitchOn ? CustomReviewScreenBottomNavigationBarAdapter() : nil
        case .imagePickerNavigationBarBottomAdapter:
            giniConfiguration.imagePickerNavigationBarBottomAdapter = data.isSwitchOn ? CustomBottomNavigationBarAdapter() : nil
        case .onboardingShowAtLaunch:
            giniConfiguration.onboardingShowAtLaunch = data.isSwitchOn
        case .onboardingShowAtFirstLaunch:
            giniConfiguration.onboardingShowAtFirstLaunch = data.isSwitchOn
            clearOnboardingDefaultsIfNeeded(isSwitchOn: data.isSwitchOn)
        case .customOnboardingPages:
            giniConfiguration.customOnboardingPages = data.isSwitchOn ? createCustomOnboardingPages() : nil
        case .onboardingAlignCornersIllustrationAdapter:
            giniConfiguration.onboardingAlignCornersIllustrationAdapter = createCustomIllustrationAdapter(
                isSwitchOn: data.isSwitchOn, animationName: "page1Animation", color: .red)
        case .onboardingLightingIllustrationAdapter:
            giniConfiguration.onboardingLightingIllustrationAdapter = createCustomIllustrationAdapter(
                isSwitchOn: data.isSwitchOn, animationName: "cameraAnimation", color: .yellow)
        case .onboardingQRCodeIllustrationAdapter:
            giniConfiguration.onboardingQRCodeIllustrationAdapter = createCustomIllustrationAdapter(
                isSwitchOn: data.isSwitchOn, animationName: "magicAnimation", color: .blue)
        case .onboardingMultiPageIllustrationAdapter:
            giniConfiguration.onboardingMultiPageIllustrationAdapter = createCustomIllustrationAdapter(
                isSwitchOn: data.isSwitchOn, animationName: "uploadAnimation", color: .green)
        case .onboardingNavigationBarBottomAdapter:
            giniConfiguration.onboardingNavigationBarBottomAdapter = data.isSwitchOn ? CustomOnboardingBottomNavigationBarAdapter() : nil
        case .onButtonLoadingIndicator:
            giniConfiguration.onButtonLoadingIndicator = data.isSwitchOn ? OnButtonLoading() : nil
        case .customLoadingIndicator:
            giniConfiguration.customLoadingIndicator = data.isSwitchOn ? CustomLoadingIndicator() : nil
        case .shouldShowSupportedFormatsScreen:
            giniConfiguration.shouldShowSupportedFormatsScreen = data.isSwitchOn
        case .customMenuItems:
            giniConfiguration.customMenuItems = data.isSwitchOn ? [HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())] : []
        case .customNavigationController:
            giniConfiguration.customNavigationController = data.isSwitchOn ? createCustomNavigationController() : nil
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
            updateCustomGiniErrorLogger(isSwitchOn: data.isSwitchOn)
        case .debugModeOn:
            giniConfiguration.debugModeOn = data.isSwitchOn
        case .digitalInvoiceOnboardingIllustrationAdapter:
            giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter = createCustomIllustrationAdapter(
                isSwitchOn: data.isSwitchOn, animationName: "magicAnimation", color: .blue)
        case .digitalInvoiceHelpNavigationBarBottomAdapter:
            giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter = data.isSwitchOn ? CustomBottomNavigationBarAdapter() : nil
        case .digitalInvoiceOnboardingNavigationBarBottomAdapter:
            giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter = data.isSwitchOn ? CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter() : nil
        case .digitalInvoiceNavigationBarBottomAdapter:
            giniConfiguration.digitalInvoiceNavigationBarBottomAdapter = data.isSwitchOn ? CustomDigitalInvoiceBottomNavigationBarAdapter() : nil
        case .digitalInvoiceSkontoNavigationBarBottomAdapter:
            giniConfiguration.digitalInvoiceSkontoNavigationBarBottomAdapter = data.isSwitchOn ? CustomDigitalInvoiceSkontoBottomNavigationBarAdapter() : nil
        case .primaryButtonConfiguration:
            updateButtonConfiguration(for: &giniConfiguration.primaryButtonConfiguration, state: &settingsButtonStates.primaryButtonState, isSwitchOn: data.isSwitchOn)
        case .secondaryButtonConfiguration:
            updateButtonConfiguration(for: &giniConfiguration.secondaryButtonConfiguration, state: &settingsButtonStates.secondaryButtonState, isSwitchOn: data.isSwitchOn)
        case .transparentButtonConfiguration:
            updateButtonConfiguration(for: &giniConfiguration.transparentButtonConfiguration, state: &settingsButtonStates.transparentButtonState, isSwitchOn: data.isSwitchOn)
        case .cameraControlButtonConfiguration:
            updateButtonConfiguration(for: &giniConfiguration.cameraControlButtonConfiguration, state: &settingsButtonStates.cameraControlButtonState, isSwitchOn: data.isSwitchOn)
        case .addPageButtonConfiguration:
            updateButtonConfiguration(for: &giniConfiguration.addPageButtonConfiguration, state: &settingsButtonStates.addPageButtonState, isSwitchOn: data.isSwitchOn)
        case .customDocumentValidations:
            updateCustomDocumentValidations(isSwitchOn: data.isSwitchOn)
        case .skontoNavigationBarBottomAdapter:
            giniConfiguration.skontoNavigationBarBottomAdapter = data.isSwitchOn ? CustomSkontoNavigationBarBottomAdapter() : nil
        case .skontoHelpNavigationBarBottomAdapter:
            giniConfiguration.skontoHelpNavigationBarBottomAdapter = data.isSwitchOn ? CustomBottomNavigationBarAdapter() : nil
        case .closeSDK:
            Self.shouldCloseSDKAfterTenSeconds = data.isSwitchOn
        }
    }

    private func handleSwitchDependencies(for data: SwitchOptionModel, at indexPath: IndexPath) {
        switch data.type {
        case .qrCodeScanning:
            handleQRCodeScanningDependency(data: data, at: indexPath)
        case .qrCodeScanningOnly:
            handleQRCodeScanningOnlyDependency(data: data, at: indexPath)
        case .flashToggle:
            handleFlashToggleDependency(data: data, at: indexPath)
        case .flashOnByDefault:
            handleFlashOnByDefaultDependency(data: data, at: indexPath)
        default:
            break
        }
    }

    private func handleQRCodeScanningDependency(data: SwitchOptionModel, at indexPath: IndexPath) {
        guard !data.isSwitchOn, giniConfiguration.onlyQRCodeScanningEnabled else { return }
        giniConfiguration.onlyQRCodeScanningEnabled = false
        updateOption(type: .qrCodeScanningOnly, isSwitchOn: false, indexOffset: 1, at: indexPath)
    }

    private func handleQRCodeScanningOnlyDependency(data: SwitchOptionModel, at indexPath: IndexPath) {
        guard data.isSwitchOn, !giniConfiguration.qrCodeScanningEnabled else { return }
        giniConfiguration.qrCodeScanningEnabled = true
        updateOption(type: .qrCodeScanning, isSwitchOn: true, indexOffset: -1, at: indexPath)
    }

    private func handleFlashToggleDependency(data: SwitchOptionModel, at indexPath: IndexPath) {
        guard !data.isSwitchOn, giniConfiguration.flashOnByDefault else { return }
        giniConfiguration.flashOnByDefault = false
        updateOption(type: .flashOnByDefault, isSwitchOn: false, indexOffset: 1, at: indexPath)
    }

    private func handleFlashOnByDefaultDependency(data: SwitchOptionModel, at indexPath: IndexPath) {
        guard data.isSwitchOn, !giniConfiguration.flashToggleEnabled else { return }
        giniConfiguration.flashToggleEnabled = true
        updateOption(type: .flashToggle, isSwitchOn: true, indexOffset: -1, at: indexPath)
    }

    private func updateOption(type: SwitchOptionModel.OptionType, isSwitchOn: Bool, indexOffset: Int, at indexPath: IndexPath) {
        let option = SettingsViewController.CellType.switchOption(data: SwitchOptionModel(type: type, isSwitchOn: isSwitchOn))
        contentData[indexPath.section].items[indexPath.row + indexOffset] = option
        delegate?.contentDataUpdated()
    }

    private func clearOnboardingDefaultsIfNeeded(isSwitchOn: Bool) {
        let onboardingShowedUserDefault = UserDefaults.standard.bool(forKey: "ginicapture.defaults.onboardingShowed")
        if !isSwitchOn && onboardingShowedUserDefault {
            UserDefaults.standard.removeObject(forKey: "ginicapture.defaults.onboardingShowed")
        }
    }

    private func createCustomIllustrationAdapter(isSwitchOn: Bool, animationName: String, color: UIColor) -> CustomOnboardingIllustrationAdapter? {
        return isSwitchOn ? CustomOnboardingIllustrationAdapter(animationName: animationName, backgroundColor: color) : nil
    }

    private func createCustomNavigationController() -> UINavigationController {
        let navigationViewController = UINavigationController()
        navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
        return navigationViewController
    }

    private func updateCustomGiniErrorLogger(isSwitchOn: Bool) {
        giniConfiguration.customGiniErrorLoggerDelegate = isSwitchOn && giniConfiguration.giniErrorLoggerIsOn ? self : nil
    }

    private func updateButtonConfiguration(for configuration: inout ButtonConfiguration, state: inout SettingsButtonStates.ButtonState, isSwitchOn: Bool) {
        guard isSwitchOn else {
            configuration = state.configuration
            return
        }
        state.isSwitchOn = isSwitchOn
        configuration = createCustomButtonConfiguration(for: state.type)
    }

    private func createCustomButtonConfiguration(for type: SettingsButtonStates.ButtonType) -> ButtonConfiguration {
        var backgroundColor: UIColor
        var borderColor: UIColor

        switch type {
        case .primary:
            backgroundColor = .yellow
            borderColor = .red
        case .secondary:
            backgroundColor = .cyan
            borderColor = .blue
        case .transparent:
            backgroundColor = .green
            borderColor = .yellow
        case .cameraControl:
            backgroundColor = .magenta
            borderColor = .lightGray
        case .addPage:
            backgroundColor = .white
            borderColor = .red
        }

        return ButtonConfiguration(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            titleColor: .green,
            shadowColor: .clear,
            cornerRadius: 22,
            borderWidth: 4,
            shadowRadius: 0,
            withBlurEffect: false
        )
    }

    private func updateCustomDocumentValidations(isSwitchOn: Bool) {
        giniConfiguration.customDocumentValidations = isSwitchOn ? { document in
            let maxFileSize = 0.5 * 1024 * 1024
            if document.data.count > Int(maxFileSize) {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als \(maxFileSize)MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        } : documentValidationsState.validations
    }

    private func createCustomOnboardingPages() -> [OnboardingPage] {
        return [
            OnboardingPage(imageName: "captureSuggestion1", title: "Page 1", description: "Description for page 1"),
            OnboardingPage(imageName: "captureSuggestion2", title: "Page 2", description: "Description for page 2"),
            OnboardingPage(imageName: "captureSuggestion3", title: "Page 3", description: "Description for page 3"),
            OnboardingPage(imageName: "captureSuggestion4", title: "Page 4", description: "Description for page 4"),
            OnboardingPage(imageName: "captureSuggestion1", title: "Page 5", description: "Description for page 5")
        ]
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
