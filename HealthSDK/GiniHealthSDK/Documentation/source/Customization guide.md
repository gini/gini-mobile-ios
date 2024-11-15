Customization guide
=============================

The Gini Health SDK components can be customized either through the `GiniHealthConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Overview of the UI customization options](#overview-of-the-ui-customization-options)
- [Payment Component](#payment-component)
- [Bank Selection Bottom Sheet](#bank-selection-bottom-sheet)
- [Payment Feature Info Screen](#payment-feature-info-screen)
- [Payment Review screen](#payment-review-screen)


## Overview of the UI customization options

### Colors

We provide a global color palette `GiniColors.xcassets` which you are free to override. 
For example, if you want to override Accent01 color you need to create an Accent01.colorset with your wished value in your main bundle.
The custom colors are then applied to all screens.

Find the names of the color resources in the color palette (you can also view it in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=8905-975&t=vNb6FqqGtzIAVdJl-1)).

### Images

Customizing of images is done via overriding of image sets. 
If you want to override specific SDK images:
1. Create an asset catalog for images called `GiniImages.xcassets` in your app.
2. Add your own images to `GiniImages.xcassets` using the image names from the SDK's UI customization guide. It is important to name the images you wish to override exactly as shown in the UI customization guide, otherwise overriding won’t work.

### Typography

We provide global typography based on text appearance styles from UIFont.TextStyle.
Preview our typography and find the names of the style resources (you can also view it in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=8906-1104&t=vNb6FqqGtzIAVdJl-1)).

In the example below you can see to override a font for `.body1`

```swift
let configuration = GiniHealthConfiguration()

configuration.updateFont(UIFont(name: "Impact", size: 15)!, for: .body1)     
health.setConfiguration(configuration)
```

### Text

Text customization is done via overriding of string resources.
For example you would like to customize pay invoice button label in the Payment Component:

1. Find a string key for a text that you would like to customize.
For the [Pay the invoice button label](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=8987-2854&t=vNb6FqqGtzIAVdJl-1) in the Payment Component we use `ginihealth.paymentcomponent.payInvoice.label`. 
2. Add the string key with a desired value to `Localizable.strings` in your app.

### Supporting dark mode

We support dark mode in our SDK. If you decide to customize the color palette, please ensure that the text colors are also set in contrast to the background colors.

## Payment Component
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=8987-2854&t=vNb6FqqGtzIAVdJl-1).

For configuring the the payment component height use `paymentComponentButtonsHeight` configuration option:

```swift
let giniConfiguration = GiniHealthConfiguration()
// Ensure the height of the payment component buttons meets the [iOS minimum standard](https://developer.apple.com/design/human-interface-guidelines/buttons).
// If the specified height is less than 44.0 points, it will be reset to 44.0 points.
config.paymentComponentButtonsHeight =  45.0
healthSDK.setConfiguration(config)
```

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Fdesign%2FwBBjc38iihjxrKMnLfbOD4%2FiOS-Gini-Health-SDK-4.1-UI-Customisation%3Fnode-id%3D8987-2854%26t%3DvNb6FqqGtzIAVdJl-1" allowfullscreen></iframe>

## Bank Selection Bottom Sheet

You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=9008-1654&t=vNb6FqqGtzIAVdJl-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Fdesign%2FwBBjc38iihjxrKMnLfbOD4%2FiOS-Gini-Health-SDK-4.1-UI-Customisation%3Fnode-id%3D9008-1654%26t%3DvNb6FqqGtzIAVdJl-1" allowfullscreen></iframe>

## Payment Feature Info Screen

You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=9044-1582&t=vNb6FqqGtzIAVdJl-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Fdesign%2FwBBjc38iihjxrKMnLfbOD4%2FiOS-Gini-Health-SDK-4.1-UI-Customisation%3Fnode-id%3D9044-1582%26t%3DvNb6FqqGtzIAVdJl-1" allowfullscreen></iframe>

## Payment Review screen
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/wBBjc38iihjxrKMnLfbOD4/iOS-Gini-Health-SDK-4.1-UI-Customisation?node-id=9008-1300&t=vNb6FqqGtzIAVdJl-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Fdesign%2FwBBjc38iihjxrKMnLfbOD4%2FiOS-Gini-Health-SDK-4.1-UI-Customisation%3Fnode-id%3D9008-1300%26t%3DvNb6FqqGtzIAVdJl-1" allowfullscreen></iframe>

> **Note:** 
> - PaymentReviewViewController contains the following configuration options:
> - paymentReviewStatusBarStyle: Sets the status bar style on the payment review screen. Only if `View controller-based status bar appearance` = `YES` in `Info.plist`.