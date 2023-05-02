
<p align="center">
<img src="./GiniBank_Logo.png" width="250">
</p>

# Gini Bank SDK for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)]()
[![Swift package manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)]()

The Gini Bank SDK provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this SDK into your application you can allow your users to easily take a picture of a document, review it and get analysis results from the Gini backend.

The Gini Bank SDK can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Bank SDK has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

## Documentation

Further documentation with installation, integration or customization guides can be found in our [website](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/).

## Example

In order to run [the example app](https://github.com/gini/gini-mobile-ios/tree/main/BankSDK/GiniBankSDKExample/GiniBankSDKExample), clone the repo ,open the project file and Resolve Package Versions in Xcode `File->Packages->Resolve Package Versions` and inject your API credentials in 
[`BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist)

### Payment feature

The other [example app](https://github.com/gini/gini-mobile-ios/tree/main/BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank) demonstrates how to integrate the payment feature of Gini Bank SDK.
 
To run the apps, clone the repo, open the project file and Resolve Package Versions in Xcode `File->Packages->Resolve Package Versions`.

To inject your API credentials into the Bank example app you need to fill in your credentials in
[`BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist/).

An example health app is available under the link [Gini Health SDK's example](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample).
You can use the same Gini Bank API client credentials in the health example app as in your app, if not otherwise specified and inject them into 
[`HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/Credentials.plist).
The example business app initiates the payment flow.

## Requirements

- iOS 12+
- Xcode 12+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 12 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).

## Author

Gini GmbH, hello@gini.net

## License

The Gini Bank SDK for iOS is licensed under a Private License. See [the license](http://developer.gini.net/gini-mobile-ios/GiniBankSDK/license.html) for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
