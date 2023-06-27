Enable your app to open PDFs and Images from other apps
========================================

General considerations
----------------------

Enabling your app to open PDFs and images allows your users to open any kind of files which are identified by the OS as PDFs or images. To do so, just follow these steps:


1. Register PDF and image file types
------------------------------------

Add the following to your `Info.plist`:

```swift
<key>CFBundleDocumentTypes</key>
<array>
        <dict>
            <key>CFBundleTypeIconFiles</key>
            <array/>
            <key>CFBundleTypeName</key>
            <string>PDF</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.adobe.pdf</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Images</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.jpeg</string>
                <string>public.png</string>
                <string>public.tiff</string>
                <string>com.compuserve.gif</string>
            </array>
        </dict>
</array>
```

You can also add these by going to your target’s *Info* tab and enter the values into the *Document Types* section.

In order to initiate `Open with` from your app’s Documents folder add [`UISupportsDocumentBrowser`](https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportsdocumentbrowser) to your `Info.plist`.

### Documentation

-   [Document types](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/DocumentInteraction_TopicsForIOS/Articles/RegisteringtheFileTypesYourAppSupports.html) from _Apple documentation_.

2. Enable it inside Gini Bank SDK
---------------------------------
In order to allow the Gini Bank SDK to handle files imported from other apps and to show the _Open With tutorial_ in the _Help_ menu, it is necessary to indicate it in the `GiniBankConfiguration`.

```swift
        let giniBankConfiguration = GiniBankConfiguration.shared
        ...
        ...
        giniBankConfiguration.openWithEnabled = true
```

3. Handle incoming PDFs and images
---------------------------------

When your app is requested to handle a PDF or an image your `AppDelegate`’s `application(_:open:options:)` (__Swift__) method is called. You can then use the supplied url to create a document as shown below.

In some cases, in particular when the `LSSupportsOpeningDocumentsInPlace` flag is enabled in your `Info.plist` file, reading data directly from the url may fail. For that reason, `GiniCapture` uses the asynchronous `UIDocument` API internally which handles any of the potential security requirements.

In order to determine that the file opened is valid (correct size, correct type and number of pages below the threshold on PDFs), it is necessary to validate it before using it.

Gini Bank
------------

```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {            

        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        documentBuilder.build(with: url) { [weak self] (document) in
            
            guard let self = self else { return }
            
            // 2. Validate the document
            if let document = document {
                do {
                    try GiniCapture.validate(document,
                                             withConfig: giniBankConfiguration.captureConfiguration())
                    // Load the GiniCapture with the validated document
                } catch {
                    // Show an error pointing out that the document is invalid
                }
            }
        }

        return true
}
```

### Documentation

-   [AppDelegate resource handling](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application) from _Apple Documentation_
-   [Supported file formats](http://developer.gini.net/gini-api/html/documents.html#supported-file-formats) from _Gini API_

Enable your app to open images from Photos app
==============================================

For enabling your app to be opened with share functionality from Photos you need to implement a shared extension. 
[Share extensions](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html), in particular, allow you to share content to your application.

1. Add a share extension to your project
---------------------------------
Go to `File -> New -> Target` and select `Share Extension`. Please make sure you link it to the main app.
The system will ask you if you want to activate the `Share scheme`, just select `Activate`. 

2. Set the extension activation rule
---------------------------------
To do this you need to change the [`NSExtensionActivationRule`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsextension/nsextensionattributes/nsextensionactivationrule) in the `Info.plist` in your extension target.

Please check the example [here](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKShareExtension/Info.plist).

3. Handling the URL
---------------------------------
Find the example implementation [here](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKShareExtension/ShareViewController.swift#L41)

4. Pass the data from the extension to the main app
---------------------------------
Here we connect the share extension directly to the main app using `AppGroups` and `UserDefaults`.
Add [AppGroups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups) to the capabilities of both the extension and main app using the same app group.

Check the example [here](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKShareExtension/ShareViewController.swift#L33)

5. Open the main app and retrieve the shared data
---------------------------------------------
 - Register your app extension scheme in the URL types for the main app.

 - Open the main app from the [extension](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKShareExtension/ShareViewController.swift#L61).

 - Handle incoming URL from the app extension in `AppDelegate` and retrieve data from the shared `UserDefaults`.
The system delivers the URL to your app by calling your app delegate’s `application(_:open:options:)` method.
You can check our example implementation [here](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKExample/AppDelegate.swift#L29).
