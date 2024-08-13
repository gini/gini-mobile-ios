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
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return
        }
        for type in [typeURL, typePNG, typeGIF, typeJPG, typeTIFF] {
            if itemProvider.hasItemConformingToTypeIdentifier(type) {
                handleIncomingItem(itemProvider: itemProvider, type: type)
                return
            }
        }
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
      
    private func save(_ data: Data, key: String, value: Any) {
      // You must use the userdefaults of an app group, otherwise the main app don't have access to it.
        if let userDefaults = UserDefaults(suiteName: groupName){
            userDefaults.set(data, forKey: imageKey)
        }
    }
        

    private func handleIncomingItem(itemProvider: NSItemProvider, type: String) {
        itemProvider.loadItem(forTypeIdentifier: type, options: nil) { (item, error) in
            if let error = error { print("URL-Error: \(error.localizedDescription)") }

            if let url = item as? NSURL, let urlString = url.absoluteString {
                let imageData = try? Data(contentsOf: url as URL)
                self.save(imageData!, key: self.imageKey, value: imageData!)
                self.saveURLString(urlString)
            }

            self.openMainApp()
        }
    }

    private func saveURLString(_ urlString: String) {
        if let userDefaults = UserDefaults(suiteName: self.groupName){
            userDefaults.setValue(urlString, forKey: self.urlDefaultName)
        }
    }

    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: self.appURL) else { return }
            _ = self.openURL(url)
        })
    }

    // Function must be named exactly like this so a selector can be found by the compiler
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
