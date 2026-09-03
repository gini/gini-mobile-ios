//
//  ShareViewController.swift
//  GiniBankSDKShareExtension
//
//  Created by Nadya Karaban on 13.10.22.
//

import UIKit
import Social
import CoreServices

class ShareViewController: UIViewController {
    private let typeURL = String(kUTTypeImage)
    private let typePNG = String(kUTTypePNG)
    private let typeGIF = String(kUTTypeGIF)
    private let typeJPG = String(kUTTypeJPEG)
    private let typeTIFF = String(kUTTypeTIFF)
    private let appURL = "BankSDKExtension://"
    private let groupName = "group.bank.extension.test"
    private let urlDefaultName = "incomingURL"
    private let imageKey = "imageData"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
                extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return
        }

        for type in [typeURL, typePNG, typeGIF, typeJPG, typeTIFF] {
            if itemProvider.hasItemConformingToTypeIdentifier(type) {
                handleIncomingItem(itemProvider: itemProvider, type: type)
                return
            }
        }

        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
      
    private func save(_ data: Data, key: String, value: Any) {
        // You must use the userdefaults of an app group, otherwise the main app don't have access to it.
        if let userDefaults = UserDefaults(suiteName: groupName) {
            userDefaults.set(data, forKey: imageKey)
        }
    }
        

    private func handleIncomingItem(itemProvider: NSItemProvider, type: String) {
        itemProvider.loadItem(forTypeIdentifier: type, options: nil) { [weak self] (item, error) in
            guard let self else { return }
            
            if let error = error { print("URL-Error: \(error.localizedDescription)") }

            if let url = item as? URL {
                let urlString = url.absoluteString
                let imageData = try? Data(contentsOf: url as URL)
                save(imageData!, key: imageKey, value: imageData!)
                saveURLString(urlString)
            }

            self.openMainApp()
        }
    }

    private func saveURLString(_ urlString: String) {
        if let userDefaults = UserDefaults(suiteName: groupName){
            userDefaults.setValue(urlString, forKey: urlDefaultName)
        }
    }

    private func openMainApp() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: { [weak self] _ in
            guard let self, let url = URL(string: self.appURL) else { return }
            
            openURL(url)
        })
    }

    private func openURL(_ url: URL) {
        var responder: UIResponder? = self

        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:])
            }

            responder = responder?.next
        }
    }
}
