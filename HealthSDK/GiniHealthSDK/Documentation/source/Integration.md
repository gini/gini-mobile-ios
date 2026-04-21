Integration
=============================

The Gini Health SDK for iOS provides all the UI and functionality needed to use the Gini Health API in your app to extract payment and health information from invoices and from digital payment orders. The payment information can be reviewed and then the invoice/orders can be paid using any available payment provider app (e.g., banking app).

The Gini Health API provides an information extraction service for analyzing health invoices. Specifically, it extracts information such as the document sender or the payment relevant information (amount to pay, IBAN, etc.). In addition it also provides a secure channel for sharing payment related information between clients. 

> ⚠️  **Important:**

For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## GiniHealthAPI initialization (if you use transparent proxy with your own authentication)

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let giniApiLib =  GiniHealthAPI.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

> ⚠️  **Important:**

When you implement `AlternativeTokenSource` protocol make sure that you call the completion in one specific thread

```swift
private class MyAlternativeTokenSource: AlternativeTokenSource {
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        // fetch token from any thread
        // then call the completion in one specific thread
        completion(.success(Token()))
    }
}
```
## GiniHealth initialization

### Certificate pinning (optional)

If you want to use _Certificate pinning_, provide metadata for the upload process, you can pass your public key pinning configuration as follows:
```swift
    private lazy var healthSDK = GiniHealth(id: clientID, secret: clientPassword, domain: clientDomain, pinningConfig: ["PinnedDomains" : ["PublicKeyHashes"]])
```

> ⚠️  **Important:**

You should have received Gini Health API client credentials from us. Please get in touch with us in case you don't have them.

You can easily initialize `GiniHealth` with the client credentials:

```swift
 let healthSDK = GiniHealth(id: clientID, secret: clientPassword, domain: clientDomain)
```
Or initialize it with previously created `GiniHealthAPI`:

```swift
 let healthSDK = GiniHealth(with: giniApiLib)
```

## Handling documents

### Document upload
 
For the document upload if you plan to do it with `GiniHealth`. First you need get document service and create partial document.

```swift
let documentService = healthSDK.documentService()
documentService.createDocument(fileName:"ginipay-partial",
                               docType: nil,
                               type: .partial(documentData),
                               metadata: nil)
```
The method above returns the completion block with partial `Document` in success case.

After receiving the partial document in completion you can get actual composite document:

```swift
let partialDocs = [PartialDocumentInfo(document: createdDocument.links.document)]
self.healthSDK.documentService
            .createDocument(fileName: "ginipay-composite",
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: partialDocs)),
                            metadata: nil)

```

### Check which documents/invoices are payable

We provide 2 ways of doing this.
1. GiniHealth provides a variable for checking if the document is payable or not. You can look for `payment_state` of the document/invoice. The document/invoice is payable if `payment_state` is `Payable` 

2. GiniHealth provides a method for checking if the document is payable or not.

```swift
healthSDK.checkIfDocumentIsPayable(docId: String,
                                   completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
```

The method returns success and `true` value if `payment_state` was extracted.

> - We recommend using a `DispatchGroup` for these requests, waiting till all of them are ready, and then, reloading the list.

```swift
for giniDocument in dataDocuments {
   dispatchGroup.enter()
   self.healthSDK.checkIfDocumentIsPayable(docId: createdDocument.id, completion: { [weak self] result in
       switch result {
       // ...
       }
       self?.dispatchGroup.leave()
   })
}
dispatchGroup.notify(queue: .main) {
    // Reload List
}
```

### Check if the document contains multiple invoices

GiniHealth provides a method to check whether a document contains multiple invoices:

```swift
healthSDK.checkIfDocumentContainsMultipleInvoices(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
```

The method returns `true` in the success case if the `contains_multiple_docs` field was extracted and its value is `true`.

> - Recommendation: Use this check in a specific order. First, call the `checkIfDocumentIsPayable` method, and then call `checkIfDocumentContainsMultipleInvoices` method.

### Delete a batch of documents

GiniHealth provides a method to delete multiple documents at once:

```swift
healthSDK.deleteDocuments(documentIds: [String], completion: @escaping (Result<String, GiniError>) -> Void)
```

This method enables clients to delete multiple documents simultaneously by passing an array of document IDs. Upon success, it returns an array of successfully deleted documents. In case of an error, a specific error message is provided.

## Subscribing to GiniHealthDelegate

Conforming to `GiniHealthDelegate` protocol will allow you:
- Configure an option for implementing a custom error handling or keep an internal one.
- Getting a payment requestId which you will need for checking the payment status.
- Listening to the dismissal of the Gini Health SDK.

Please see the example of implementation:

```swift
extension YourCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        return true
    }
    
    func didCreatePaymentRequest(paymentRequestId: String) {
        GiniUtilites.Log("Created payment request with id \(paymentRequestId)", event: .success)
    }
    
    func didDismissHealthSDK() {
        GiniUtilites.Log("GiniHealthSDK was dismissed", event: .info)
    }
}

healthSDK.delegate = self
```

## Error handling

### Error types

The SDK surfaces errors through two types.

**`GiniHealthError`** — the top-level error thrown by `GiniHealth` operations:

| Case | Description |
|------|-------------|
| `.noInstalledApps` | No payment-provider app that supports Gini Pay Connect is installed on the device. |
| `.apiError(GiniError)` | The Gini Health API returned a failure. The associated `GiniError` carries HTTP status details and structured error items. |
| `.noPaymentDataExtracted` | The API response did not contain the expected payment extractions. |

**`GiniError`** — structured API error wrapped inside `.apiError(...)`:

```swift
public struct GiniError: Error {
    var message: String?           // Human-readable error message
    var statusCode: Int?           // HTTP status code (e.g. 400, 401, 404)
    var requestId: String          // Trace ID — include this when contacting Gini support
    var items: [ErrorItem]?        // Structured error items from the API response body
    var response: HTTPURLResponse?
    var data: Data?
}
```

Each `ErrorItem` in `items` identifies a specific sub-error:

```swift
public struct ErrorItem: Codable {
    var code: String       // Error code, e.g. "2013" (unauthorized), "2014" (not found)
    var message: String?   // Optional description of the sub-error
    var object: [String]?  // IDs of affected objects (e.g. document IDs)
}
```

### Controlling error presentation with `shouldHandleErrorInternally`

`GiniHealthDelegate.shouldHandleErrorInternally(error:)` lets you decide — per error — whether the SDK shows its built-in error UI or hands the error back to your app.

| Return value | Behaviour |
|---|---|
| `true` | The SDK displays its own error alert / screen. |
| `false` | The SDK suppresses its UI entirely. You must react **before** returning `false` — no further callback is issued. |

The simplest integration uses a single flag, matching the approach in the example app:

```swift
extension YourCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        return handleErrorsInternally  // true by default; toggled by the user/debug menu
    }
}
```

For finer control, switch on the error type:

```swift
extension YourCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        switch error {
        case .noInstalledApps:
            // Let the SDK show its "no banking app found" screen
            return true
        case .apiError(let giniError) where giniError.statusCode == 401:
            // Handle 401 yourself — act here, then return false
            showSessionExpiredAlert()
            return false
        case .apiError:
            return true
        case .noPaymentDataExtracted:
            return true
        }
    }
}
```

> ⚠️ **Important:** When you return `false` the SDK does nothing further. Any recovery UI or logging must happen inside `shouldHandleErrorInternally` before it returns.

### Inspecting structured API errors

When you receive a `.apiError` and need to inspect which documents failed and why, use the convenience helpers on `GiniError`:

```swift
case .apiError(let giniError):
    // Full summary for logs or crash reporters
    print(giniError.detailedDescription)
    // Output:
    // Status: 400 | Request ID: a497-01aa-b6f0-cc17-43d3-76a8
    // Message: Bad request
    // Items: 2013: [doc-id-1, doc-id-2]

    // Compact list of all sub-errors
    print(giniError.itemsDescription)
    // Output: "2013: [doc-id-1, doc-id-2]; 2014: [doc-id-3]"

    // Extract the IDs of documents that failed with a specific error code
    let unauthorizedDocIds = giniError.objectsWithCode("2013")
    let notFoundDocIds = giniError.objectsWithCode("2014")
```

### Common `ErrorItem` codes

| Code | Meaning |
|------|---------|
| `"2013"` | Document access denied / not authorized |
| `"2014"` | Document not found |
| `"2015"` | Composite document missing |

> When contacting Gini support about an API error, always include `GiniError.requestId`.

## Starting the Payment flow

We provide a custom payment flow for the users to pay the invoice/document/digital payment.
Please follow the steps below for the payment component integration.

### 1. Setup `GiniHealthConfiguration`.

> ⚠️  **Important:**
If you need to handle a flow with a document/invoice use a code snippet below:

```swift
    private let giniHealthConfiguration: GiniHealthConfiguration = {
        let config = GiniHealthConfiguration()
        config.useInvoiceWithoutDocument = false
        return config
    }()

    healthSDK.setConfiguration(giniHealthConfiguration)
```

### 2. Start the Payment Flow

After configuring the healthSDK, you should call can start a payment flow:

If you have a document/invoice:

```swift
healthSDK.startPaymentFlow(documentId: documentId,
                           paymentInfo: nil,
                           navigationController: navigationController,
                           trackingDelegate: self)
```

Parameters:
- `documentId`: An optional document ID for flows that involve an invoice or document.
- `paymentInfo`: An optional `PaymentInfo` object containing payment details, used when there is no document.
- `navigationController`: The `UINavigationController` used to present subsequent view controllers.
- `trackingDelegate`: A `GiniHealthTrackingDelegate` that receives events from the Payment Review screen.

If you don't have any document/invoice you need to pass `GiniHealthSDK.PaymentInfo` into the method below:

```swift

let paymentInfo = PaymentInfo(recipient: recipient,
                              iban: iban,
                              bic: "",
                              amount: amountToPay,
                              purpose: purpose,
                              paymentUniversalLink: "",
                              paymentProviderId: "")

health.startPaymentFlow(documentId: nil,
                        paymentInfo: paymentInfo,
                        navigationController: navigationController,
                        trackingDelegate: self)
```

### Optional (Recommended start payment entry button):

We also provide trust marker information for creating a subview that displays the available banks and their respective numbers. See Figma [here](https://www.figma.com/design/tHVSZ2BOlnx1mrfFrWeo87/iOS-Gini-Health-SDK-5.6-UI-Customization--WCAG-2.1-?node-id=16914-16138&t=vrAVy8gvjhDLHRca-1)
For that please call next method:

```swift
    let logos = health.fetchBankLogos().logos // for the first two payment providers available
    let additionalBankNumberToShow = health.fetchBankLogos().additionalBankCount // for the number of additional payment providers available
```

## Delete a payment request

GiniHealth provides a method to delete a single payment request:

```swift
healthSDK.deletePaymentRequest(id: String, completion: @escaping (Result<String, GiniError>) -> Void)
```

This method enables clients to delete single payment request by passing the payment request ID. Upon success, it returns the ID of successfully deleted payment request. In case of an error, a specific error message is provided.

## Getting a payment

GiniHealth provides a method to retrieve a payment of an specified payment request:

```swift
healthSDK.getPayment(id: String, completion: @escaping (Result<Payment, GiniError>) -> Void)
```

This method enables clients to retrieve the `payment` of an specified request by passing the payment request ID. Upon success, it returns the `payment` associated with the given payment request id. In case of an error, a specific error message is provided.
