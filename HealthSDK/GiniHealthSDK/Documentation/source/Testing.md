Testing
=============================

## Gini Pay Deep Link For Your App

In order for banking apps to be able to return the user to your app after the payment has been resolved you need register a scheme for your app to respond to a deep link scheme known by the Gini Pay API.

You should already have a scheme and host from us. Please contact us in case you don't have them.

The following is an example for the deep link gini-health://payment-requester:
<br>
<center><img src="img/Integration guide/SchemeExample.png" width="600"/></center>
</br>

## Testing

An example banking app is available in the [Gini Pay Bank SDK's](https://github.com/gini/bank-sdk-ios) repository.

In order to test using our example banking app you need to use development client credentials. This will make sure
the Gini Health SDK uses a test payment provider which will open our example banking app. To inject your API credentials into the Bank example app you need to fill in your credentials in `Example/Bank/Credentials.plist`.

#### End to end testing

The app scheme in our banking example app: `ginipay-bank://`. Please, specify this scheme `LSApplicationQueriesSchemes` in your app in `Info.plist` file.

After you've set the client credentials in the example banking app and installed it on your device you can run your app
and verify that `healthtSDK.isAnyBankingAppInstalled(appSchemes: [String])` returns true and check other preconditions.

After following the integration steps above you'll arrive at the payment review screen.

Check that the extractions and the document preview are shown and then press the `Pay` button:

<br>
<center><img src="img/Customization guide/PaymentReview.PNG" height="500"/></center>
</br>

You should be redirected to the example banking app where the final extractions are shown:

<br>
<center><img src="img/Integration guide/ReviewScreenBeforeResolvingPayment.PNG" height="500"/></center>
</br>

After you press the `Pay` button the Gini Pay Bank SDK resolves the payment and allows you to return to your app:

<br>
<center><img src="img/Integration guide/ReviewScreenAfterResolvingPayment.PNG" height="500"/></center>
</br>

For handling incoming url in your app after redirecting back from the banking app you need to implement to handle the incoming url:
The following is an example for the url `gini-health://payment-requester`:

```swift
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "payment-requester" {
            // hadle incoming url from the banking app
        }
        return true
    }
```

With these steps completed you have verified that your app, the Gini Pay API, the Gini Health SDK and the Gini Pay
Bank SDK work together correctly.

#### Testing in production

The steps are the same but instead of the development client credentials you will need to use production client
credentials. This will make sure the Gini Healthh SDK receives real payment providers which open real banking apps.

You will also need to install a banking app which uses the Gini Pay Bank SDK. Please contact us in case you don't know
which banking app(s) to install.

Lastly make sure that for production you register the scheme we provided you for deep linking and you are not using 
`gini-health://payment-requester`.