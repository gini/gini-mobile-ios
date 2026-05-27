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

Find the names of the color resources in the color palette (you can also view it in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=17116-10662&t=frkU7wM8jb9IqqA4-4)).

### Images

Customizing of images is done via overriding of image sets. 
If you want to override specific SDK images:
1. Create an asset catalog for images called `GiniImages.xcassets` in your app.
2. Add your own images to `GiniImages.xcassets` using the image names from the SDK's UI customization guide. It is important to name the images you wish to override exactly as shown in the UI customization guide, otherwise overriding won’t work.

### Typography

We provide global typography based on text appearance styles from UIFont.TextStyle.
Preview our typography and find the names of the style resources (you can also view it in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=17116-10470&t=frkU7wM8jb9IqqA4-4)).

In the example below you can see to override a font for `.body1`

```swift
let configuration = GiniHealthConfiguration()

configuration.updateFont(UIFont(name: "Impact", size: 15)!, for: .body1)     
health.setConfiguration(configuration)
```

#### Dynamic Type

The SDK fully supports Dynamic Type. Built-in Gini fonts scale automatically with the user's Accessibility font size setting.

If you provide a custom font via `updateFont(_:for:)`, you are responsible for pre-scaling it so it also responds to Dynamic Type. Use `UIFontMetrics` to do this:

```swift
let myFont = UIFont(name: "MyBrandFont-Regular", size: 16)!
let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: myFont)

configuration.updateFont(scaledFont, for: .body1)
```

Alternatively, use the Gini utility method:

```swift
let scaledFont = UIFont.scaledFont(myFont, textStyle: .body)
configuration.updateFont(scaledFont, for: .body1)
```

A custom font passed without scaling will render at a fixed size and will **not** grow or shrink when the user changes the font size in Settings → Accessibility → Display & Text Size.

### Text

Text customization is done via overriding of string resources.
For example you would like to customize pay invoice button label in the Payment Review screen:

1. Find a string key for a text that you would like to customize.
   For the [To the banking app button label](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=16914-14742&t=frkU7wM8jb9IqqA4-4) in the Payment Review screen we use `gini.health.paymentcomponent.to.banking.app.label`. 
2. Add the string key with a desired value to `Localizable.strings` in your app.
    2.1 For German informal tone, you must add a key with `.informal` suffix to `Localizable.strings` in your app. For example, `gini.health.paymentcomponent.to.banking.app.label.informal`.
### Supporting dark mode

We support dark mode in our SDK. If you decide to customize the color palette, please ensure that the text colors are also set in contrast to the background colors.

## Payment Component
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12906-23094&t=frkU7wM8jb9IqqA4-4).

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

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12906-23094&embed-host=share" allowfullscreen></iframe>

## Bank Selection Bottom Sheet

You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-10274&t=frkU7wM8jb9IqqA4-4).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-10274&embed-host=share" allowfullscreen></iframe>

## Payment Feature Info Screen

You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-11429&t=frkU7wM8jb9IqqA4-4).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-11429&embed-host=share" allowfullscreen></iframe>

## Payment Review screen
 
You can also view the UI customisation guide in Figma [here](https://www.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-12507&t=frkU7wM8jb9IqqA4-4).

**Note:**
To copy text from Figma you need to have a Figma account. If you don't have one, you can create one for free.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://embed.figma.com/design/pImKS4S03V7d8NQhzbnDKa/iOS-Gini-Health-SDK-6.0.0?node-id=12907-12507&embed-host=share" allowfullscreen></iframe>


> **Note:** 
> - PaymentReviewViewController contains the following configuration options:
> - paymentReviewStatusBarStyle: Sets the status bar style on the payment review screen. Only if `View controller-based status bar appearance` = `YES` in `Info.plist`.
