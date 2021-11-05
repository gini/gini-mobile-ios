Enable your app to open PDFs and Images
=============================

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

### Documentation

-   [Document types](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/DocumentInteraction_TopicsForIOS/Articles/RegisteringtheFileTypesYourAppSupports.html) from _Apple documentation_.

2. Enable it inside Gini Bank SDK
---------------------------------
In order to allow the Gini Bank SDK to handle files imported from other apps and to show the _Open With tutorial_ in the _Help_ menu, it is necessary to indicate it in the `GiniBankConfiguration`.

```swift
        let giniBankConfiguration = GiniBankConfiguration()
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
