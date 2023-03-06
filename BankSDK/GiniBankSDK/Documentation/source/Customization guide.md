Customization guide
=============================

The Gini Bank SDK components can be customized either through the `GiniBankConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Onboarding screens](#onboarding-screens)
- [Camera screen](#camera-screen)
- [Gallery album screen](#gallery-album-screen)
- [Review screen](#review-screen)
- [Analysis screen](#analysis-screen)
- [Help screens](#help-screens)
- [No result screen](#no-result-screen)
- [Error screens](#error-screens)

## Colors

We are providing a global color palette `GiniColors.xcassets` which you are free to override. The custom colors will be then applied on all screens.
You can find the names of the colors in [GiniColors.xcassets](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/GiniColors.xcassets).

 You can view our color palette here:

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D14%253A355%26t%3DwpenBBM8QsagJzOg-1" allowfullscreen></iframe>

## Typography

We provide a global typography based on text appearance styles from `UIFont.TextStyle`. 

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FH4WFJ4xaw4YNU4VaJYWiQq%2FiOS-Gini-Capture-SDK-2.0.0-UI-Customisation%3Fnode-id%3D123%253A2326%26t%3DwpenBBM8QsagJzOg-1" allowfullscreen></iframe>

To override them in your application please use `GiniBankConfiguration.updateFont(_ font: UIFont, for textStyle: UIFont.TextStyle)`. For example:

```swift

    // If you need to scale your font please use our method `scaledFont()`. Please, find the example below.
    let configuration = GiniBankConfiguration.shared
    let customFontToBeScaled = UIFont.scaledFont(UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 7, weight: .regular), textStyle: .caption1)
    configuration.updateFont(customFontToBeScaled, for: .caption1)

    // If you would like to pass us already scaled font.
    let customScaledFont = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 28))
    configuration.updateFont(customScaledFont, for: .caption2)
```

## Images

Images customization is done via overriding of [GiniImages.xcassets](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/GiniImages.xcassets) resources.

## Text

 Text customization is done via overriding of string resources.

 If you plan to use a custom name for localizable strings, you need to set it in `GiniBankConfiguration.localizedStringsTableName`.

 You can find all the string resources in [Localizable.strings](https://github.com/gini/gini-mobile-ios/blob/new-ui/CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/de.lproj/Localizable.strings).

## Generic components

##### 1. Top Navigation bar

Colors, typography, texts can be customized as described above.

To inject your own navigation bar view you need to pass your navigation view controller to 
`GiniBankConfiguration.shared.customNavigationController`.
The view from the custom navigation view controller will then be displayed on all screens as the top navigation bar.

##### 2. Bottom Navigation bar

You can opt to show a bottom navigation bar. To enable it pass `true` to
`GiniBankConfiguration.shared.bottomNavigationBarEnabled`.

**Note**:  The top navigation bar will still be used, but its  functionality will be limited to showing the screen's title and
an optional close button.
Please inject a custom top navigation bar if your design requires it even if you have enabled the bottom navigation bar.

For each screen we provide a possibility to inject a custom bottom navigation bar.
More details will be added below during the specific screen customization.

## Onboarding screens

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D243%253A3305%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

## Camera screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D243%253A3306%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

### Single Page

By default, the Gini Capture SDK is configured to capture single page documents.
No further configuration is required for this.

### Multi-Page

The multi-page feature allows the SDK to capture documents with multiple pages.

To enable this feature simply pass `true` to `GiniBankConfiguration.shared.multipageEnabled`.

### Camera

- Enable the flash toggle button:
To allow users toggle the camera flash pass `true` to `GiniBankConfiguration.shared.flashToggleEnabled`.

- Turn off flash by default:
Flash is on by default, and you can turn it off by passing `false` to `GiniBankConfiguration.shared.flashOnByDefault`.

### Camera access

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D0%253A1%26t%3DtmWKIcsvPJbmqnrS-1" allowfullscreen></iframe>

### QR Code Scanning

When a supported QR code is detected with valid payment data, the QR Code will be processed automatically without any further user interaction.
The QR Code scanning may be triggered directly without the need to analyze the document.

You can show a custom loading indicator with custom animation support.
Your custom loading indicator should implement `CustomLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.customLoadingIndicator`.

If the QR code does not have a supported payment format then a popup informs the user that a QR code was detected, but it cannot be used.

Please find more information in the [QR Code scanning guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/qr-code-scanning-guide.html).

### QR Code Only

During QR Code only mode the capture and import controls will be hidden from the camera screen.

For enabling QR code only mode the both flags `GiniBankConfiguration.shared.qrCodeScanningEnabled` and `GiniBankConfiguration.shared.onlyQRCodeScanningEnabled` should be `true`.

More information about the customization is available [here](https://www.figma.com/file/1985HMF83siAXmysSn3dC6/iOS-Gini-Capture-SDK-3.0.0-UI-Customisation?node-id=212%3A2331&t=cRAvcUKVlwGtGpuh-1)

### Document Import

This feature enables the Gini Capture SDK to import documents from the camera screen. When it's enabled an additional button is shown next to the camera trigger. Using this button allows the user to pick either an image or a pdf from the device.

Please find more information in the [Import PDFs and images guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/import-pdfs-and-images-guide.html).

### Camera import error handling

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D0%253A1%26t%3DtmWKIcsvPJbmqnrS-1" allowfullscreen></iframe>

## Review screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D261%253A8256%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

You can show a custom loading indicator with custom animation support on the process button.
Your custom loading indicator should implement `OnButtonLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.onButtonLoadingIndicator`.

The example implementation is available [here](https://github.com/gini/gini-mobile-ios/blob/GiniCaptureSDK%3B3.0.0-beta05/BankSDK/GiniBankSDKExample/GiniBankSDKExample/CustomLoadingIndicator.swift#L36).

## Analysis screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D501%253A7494%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

You can show a custom loading indicator with custom animation support.
Your custom loading indicator should implement `CustomLoadingIndicatorAdapter` interface and be passed  to `GiniBankConfiguration.shared.customLoadingIndicator`.

The example implementation is available [here](https://github.com/gini/gini-mobile-ios/blob/GiniCaptureSDK%3B3.0.0-beta05/BankSDK/GiniBankSDKExample/GiniBankSDKExample/CustomLoadingIndicator.swift).

## Help screens

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D141%253A2328%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

You can show your own help screens in the Gini Capture SDK.
You can pass the title and view controller for each screen to the
`GiniBankConfiguration.shared.customMenuItems` using a list of `HelpMenuItem` structs:

``` swift

        let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())

        configuration.customMenuItems = [customMenuItem]
 ```           
 
The example implementation is availible [here](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift).

You can also disable the supported formats help screen by passing `false` to
`GiniBankConfiguration.shared.shouldShowSupportedFormatsScreen`.

## Gallery album screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D279%253A7588%26t%3DtmWKIcsvPJbmqnrS-1" allowfullscreen></iframe>

## No result screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D263%253A6989%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

You can show your own UI for data input if an error occurred and the user clicks the "Enter manually" button on the error screen.
For this you must to implement `GiniCaptureResultsDelegate.giniCaptureDidEnterManually() `.

You can show a bottom navigation bar by passing true to `GiniBankConfiguration.shared.bottomNavigationBarEnabled`. There is a default implementation, but you can also use
your own by implementing the `NoResultBottomNavigationBarAdapter` interface and passing it to `GiniBankConfiguration.shared.noResultNavigationBarBottomAdapter`.

You can find more details [here](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta05/features.html#no-result-screen-customization).

## Error screen

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="600" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2F1985HMF83siAXmysSn3dC6%2FiOS-Gini-Capture-SDK-3.0.0-UI-Customisation%3Fnode-id%3D263%253A6858%26t%3DcRAvcUKVlwGtGpuh-1" allowfullscreen></iframe>

You can find more details [here](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/3.0.0-beta05/features.html#error-screen-customization).
