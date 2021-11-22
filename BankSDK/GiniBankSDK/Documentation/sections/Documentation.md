<p align="center">
<img src="img/repo-logo.png" width="250">
</p>

# Gini Bank SDK for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)]()
[![Swift package manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)]()


The Gini Bank SDK provides components for uploading, reviewing and analyzing photos of invoices and remittance slips.

By integrating this SDK into your application you can allow your users to easily upload a picture of a document, review it and get analysis results from the Gini backend, create a payment and send it to the prefferable payment provider.

## Documentation

Further documentation with installation, integration or customization guides can be found in our [website](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/).

## Example apps

### Capture feature

You can find implementation example of the capture feature under 'GiniBankSDKExample' target. The example illustrates two integration options. A Screen API that is easy to implement and a more complex, but also more flexible Component API. Both APIs can access the complete functionality of the SDK.

You need to specify the NSCameraUsageDescription key in your Info.plist file. This key is mandatory for all apps since iOS 10 when using the Camera framework.

**Note: iOS 14**
Starting in iOS 14, PhotoKit further enhances user privacy controls with the addition of the limited Photos library, which lets users select specific assets and resources to share with an app. Add an entry to your Info.plist file with the appropriate key. If your app only adds to the library, use the NSPhotoLibraryAddUsageDescription key. For all other cases, use NSPhotoLibraryUsageDescription.

In order to run [the example app](https://github.com/gini/gini-mobile-ios/tree/main/BankSDK/GiniBankSDKExample/GiniBankSDKExample), clone the repo ,open the project file and Resolve Package Versions in Xcode `File->Packages->Resolve Package Versions`.

### Payment feature

The banking example app demonstrates how to integrate the Gini Bank SDK. 
To run the apps, clone the repo, open the project file and Resolve Package Versions in Xcode `File->Packages->Resolve Package Versions`.
To inject your API credentials into the Health and Bank example apps you need to fill in your credentials in [`HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/Credentials.plist) and [`BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist`](https://github.com/gini/gini-mobile-ios/blob/main/BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist/), respectively.

An example health app is available under the link [Gini Health SDK's example](https://github.com/gini/gini-mobile-ios/blob/main/HealthSDK/GiniHeathSDKExample).
You can use the same Gini Bank API client credentials in the health example app as in your app, if not otherwise specified.
The example business app initiates the payment flow.

The Gini Health SDK will use a payment provider which will open your banking app via the URL scheme you will set during the integration of the Gini Bank SDK.

To check the redirection from the example health app please run your banking app before running the health app.

## Requirements

- iOS 11+
- Xcode 12+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 11 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).

## Author

Gini GmbH, hello@gini.net

## License

The Gini Bank SDK for iOS is licensed under a Private License. See [the license](http://developer.gini.net/gini-mobile-ios/GiniBankSDK/license.html) for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
