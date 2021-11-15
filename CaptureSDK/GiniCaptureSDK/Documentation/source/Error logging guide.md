Error Logging
=============================

The Gini Capture SDK logs errors to the Gini Bank API when the default networking implementation is used (see the UI with Networking (Recommended) section in Integration guide). We log only non-sensitive information like response status codes, headers and error messsages.

You can disable the default error logging by passing false to `GiniConfiguration().giniErrorLoggerIsOn`.

If you would like to get informed of error logging events you need to set `GiniConfiguration().customGiniErrorLoggerDelegate` which confirms to `GiniCaptureErrorLoggerDelegate`:

```swift
class CustomErrorLogger: GiniCaptureErrorLoggerDelegate {
    func handleErrorLog(error: ErrorLog) {
        //TODO
    }
}

let giniConfiguration = GiniConfiguration()
giniConfiguration.customGiniErrorLoggerDelegate = CustomErrorLogger()
```
