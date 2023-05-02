//
//  SettingsViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import Foundation
import UIKit
import GiniCaptureSDK
import AVFoundation

protocol SettingsViewControllerDelegate: AnyObject {
    func settings(settingViewController: SettingsViewController,
                  didChangeConfiguration captureConfiguration: GiniConfiguration)
}

final class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    var giniConfiguration: GiniConfiguration!

    @IBOutlet weak var fileImportControl: UISegmentedControl!
    @IBOutlet weak var openWithSwitch: UISwitch!
    @IBOutlet weak var qrCodeScanningSwitch: UISwitch!
    @IBOutlet weak var multipageSwitch: UISwitch!
    @IBOutlet weak var flashToggleSwitch: UISwitch!
    @IBOutlet weak var bottomBarSwitch: UISwitch!
    @IBOutlet weak var onlyQRCodeScanningSwitch: UISwitch!

    @IBAction func fileImportOptions(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            giniConfiguration.fileImportSupportedTypes = .none
        case 1:
            giniConfiguration.fileImportSupportedTypes = .pdf
        case 2:
            giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        default: return
        }
        
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    

    @IBAction func bottomNavigationBarSwitched(_ sender: UISwitch) {
        giniConfiguration.bottomNavigationBarEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openWithSwitch(_ sender: UISwitch) {
        giniConfiguration.openWithEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func qrCodeScanningSwitch(_ sender: UISwitch) {
        giniConfiguration.qrCodeScanningEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func multipageSwitch(_ sender: UISwitch) {
        giniConfiguration.multipageEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)

    }
    
    @IBAction func flashToggleSwitch(_ sender: UISwitch) {
        giniConfiguration.flashToggleEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func resetUserDefaults(_ sender: Any) {
        UserDefaults().removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    @IBAction func qrCodeScanningOnlySwitch(_ sender: UISwitch) {
        giniConfiguration.onlyQRCodeScanningEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomBarSwitch.setOn(giniConfiguration.bottomNavigationBarEnabled, animated: false)
        openWithSwitch.setOn(giniConfiguration.openWithEnabled, animated: false)
        qrCodeScanningSwitch.setOn(giniConfiguration.qrCodeScanningEnabled, animated: false)
        multipageSwitch.setOn(giniConfiguration.multipageEnabled, animated: false)
        flashToggleSwitch.setOn(giniConfiguration.flashToggleEnabled, animated: false)
        onlyQRCodeScanningSwitch.setOn(giniConfiguration.onlyQRCodeScanningEnabled, animated: false)
        flashToggleSwitch.isEnabled = isFlashTogglSettingEnabled()
        switch giniConfiguration.fileImportSupportedTypes {
        case .none:
            fileImportControl.selectedSegmentIndex = 0
        case .pdf:
            fileImportControl.selectedSegmentIndex = 1
        case .pdf_and_images:
            fileImportControl.selectedSegmentIndex = 2
        }
    }
    
    private func isFlashTogglSettingEnabled() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                  for: .video,
                                                                  position: .back)?.hasFlash ?? false
        #endif
    }


}
