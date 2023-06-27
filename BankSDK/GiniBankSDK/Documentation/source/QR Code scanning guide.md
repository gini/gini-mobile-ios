QR Code Scanning
=============================

Some invoices have a QR code that allows the user to get the payment data just by scanning it from the camera screen.
Scanning and processing happens automatically. 
When a supported QR code is detected with valid payment data, white camera frame will turn into the green color with proper message that QR code is detected.

If the QR code does not have a supported payment format, white camera frame will turn into the yellow color with proper message that QR code is not supported.

Please find the list of the [supported QR codes](#supported-qr-codes).

Enable QR code scanning
------------------------

The QR code scanning feature is disabled by default, so in case that you what to use it you just need to enable it in the `GiniBankConfiguration`, like so:
```swift
    let giniBankConfiguration = GiniBankConfiguration.shared
    ...
    ...
    ...		
    giniBankConfiguration.qrCodeScanningEnabled = true
```

For activating QR code-only mode without the ability to take images, you need to enable the flag in the `GiniBankConfiguration`, but also the QR scanning ability, like so: 
```swift
    let giniBankConfiguration = GiniBankConfiguration.shared
    ...
    ...
    ...        
    giniBankConfiguration.qrCodeScanningEnabled = true
    giniBankConfiguration.onlyQRCodeScanningEnabled = true
```
During QR Code only mode the capture and import controls will be hidden from the camera screen.

Handle and process the Payment Data
------------------------------------

Once the QR code has been detected, processing will happen automatically and the payment data will be returned. In order to handle the Payment Data from the QR code: the `GiniQRCodeDocument` is received in the delegate method `GiniCaptureDelegate.didCapture(document:)`, where it must be sent to the API as though it was an image or a pdf.

Customization
----------------------

All customization options are available [here](https://developer.gini.net/gini-mobile-ios/GiniBankSDK/3.1.2/customization-guide.html#camera).

Supported QR codes
----------------------

The supported QR codes are:
- [BezahlCode](http://www.bezahlcode.de)
- [EPC069-12](https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation): ([Stuzza (AT)](https://www.stuzza.at/de/zahlungsverkehr/qr-code.html) and [GiroCode (DE)](https://www.girocode.de/rechnungsempfaenger/))
- [EPS](https://eservice.stuzza.at/de/eps-ueberweisung-dokumentation/category/5-dokumentation.html)
