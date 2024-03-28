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

Find the names of the color resources in the color palette (you can also view it in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=8905%3A975&mode=design&t=o5dQ7ZlNOfbapxmp-1)).

### Images

Customizing of images is done via overriding of image sets. 
If you want to override specific SDK images:
1. Create an asset catalog for images called `GiniImages.xcassets` in your app.
2. Add your own images to `GiniImages.xcassets` using the image names from the SDK's UI customization guide. It is important to name the images you wish to override exactly as shown in the UI customization guide, otherwise overriding won’t work.

### Typography

We provide global typography based on text appearance styles from UIFont.TextStyle.
Preview our typography and find the names of the style resources (you can also view it in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=2574%3A12863&mode=design&t=o5dQ7ZlNOfbapxmp-1)).

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
For the [Pay the invoice button label](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=8987%3A2854&mode=design&t=o5dQ7ZlNOfbapxmp-1) in the Payment Component we use `ginihealth.paymentcomponent.payInvoice.label`. 
2. Add the string key with a desired value to `Localizable.strings` in your app.

### Supporting dark mode

We support dark mode in our SDK. If you decide to customize the color palette, please ensure that the text colors are also set in contrast to the background colors.

## Payment Component
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=8987%3A2854&mode=design&t=o5dQ7ZlNOfbapxmp-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FrnNBzzwk41f7mB6z58oqV8%2FiOS-Gini-Health-SDK-4.0.0-UI-Customisation%3Ftype%3Ddesign%26node-id%3D8987%253A2854%26mode%3Ddesign%26t%3Do5dQ7ZlNOfbapxmp-1" allowfullscreen></iframe>

## Bank Selection Bottom Sheet

You can also view the UI customisation guide in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=9008%3A1654&mode=design&t=o5dQ7ZlNOfbapxmp-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FrnNBzzwk41f7mB6z58oqV8%2FiOS-Gini-Health-SDK-4.0.0-UI-Customisation%3Ftype%3Ddesign%26node-id%3D9008%253A1654%26mode%3Ddesign%26t%3Do5dQ7ZlNOfbapxmp-1" allowfullscreen></iframe>

## Payment Feature Info Screen

You can also view the UI customisation guide in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=9044%3A1582&mode=design&t=o5dQ7ZlNOfbapxmp-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FrnNBzzwk41f7mB6z58oqV8%2FiOS-Gini-Health-SDK-4.0.0-UI-Customisation%3Ftype%3Ddesign%26node-id%3D9044%253A1582%26mode%3Ddesign%26t%3Do5dQ7ZlNOfbapxmp-1" allowfullscreen></iframe>

## Payment Review screen
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/file/rnNBzzwk41f7mB6z58oqV8/iOS-Gini-Health-SDK-4.0.0-UI-Customisation?type=design&node-id=9008%3A1300&mode=design&t=o5dQ7ZlNOfbapxmp-1).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FrnNBzzwk41f7mB6z58oqV8%2FiOS-Gini-Health-SDK-4.0.0-UI-Customisation%3Ftype%3Ddesign%26node-id%3D9008%253A1300%26mode%3Ddesign%26t%3Do5dQ7ZlNOfbapxmp-1" allowfullscreen></iframe>

> **Note:** 
> - PaymentReviewViewController contains the following configuration options:
> - paymentReviewStatusBarStyle: Sets the status bar style on the payment review screen. Only if `View controller-based status bar appearance` = `YES` in `Info.plist`.
> - showPaymentReviewCloseButton: If set to true, a floating close button will be shown in the top right corner of the screen.
Default value is false.

For enabling `showPaymentReviewCloseButton`:

```swift
let giniConfiguration = GiniHealthConfiguration()
config.showPaymentReviewCloseButton =  true
healthSDK.setConfiguration(config)
```

