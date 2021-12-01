Getting started
=============================

The Gini Health API Library provides ways to interact with the Gini Health API and therefore, adds the possiblity to scan documents and retrieve the extractions from them.

In order to create an instance of the `GiniHealthAPI` class, you need both your client id and your client secret. If you don’t have a client id and client secret yet, you need to contact us and we’ll provide you with credential.

All requests to the Gini Health API are made on behalf of a user. This means particularly that all created documents are bound to a specific user account. But since you are most likely only interested in the results of the semantic document analysis and not in a cloud document storage system, the Gini Health API has the feature of anonymous users. This means that user accounts are created on the fly and the user account is unknown to your application’s user.

## Initializing the library

To initialize the library, you just need to provide the API credentials:

```swift
    let giniHealthAPI = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```

## Public Key Pinning

If you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), the metadata information (the [Gini Health API](http://developer.gini.net/gini-api/html/index.html) is used by default) as follows:

```swift
    let yourPublicPinningConfig = [
            kTSKPinnedDomains: [
            "health-api.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
            "user.gini.net": [
                kTSKPublicKeyHashes: [
                // old *.gini.net public key
                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
                // new *.gini.net public key, active from around June 2020
                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
            ]],
        ]] as [String: Any]
    let giniHealthAPI = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .default,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```
> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.

For customizing an API domain please, use the following snippet:

```swift
    let giniHealthAPI = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .custom(domain: "custom-api.net"),
                 pinningConfig: yourPublicPinningConfig)
        .build()
```

## Extract Hash From gini.net

The current Gini Health API public key SHA256 hash digest in Base64 encoding can be extracted with the following openssl commands:

```bash
$ openssl s_client -servername gini.net -connect gini.net:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```
## Extract Hash From Public Key

You can also extract the hash from a public key. The following example shows how to extract it from a public key named gini.pub:

```bash
$ cat gini.pub | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

## Using the library

You can also extract the hash from a public key. The following example shows how to extract it from a public key named gini.pub:

Now that the `GiniHealthAPI` has been initialized, you can start using it. To do so, just get the _Document service_ from it. 

On one hand, if you choose to continue with the `default` _Document service_, you should use the `DefaultDocumentService`:

```swift
let documentService: DefaultDocumentService = giniHealthAPI.documentService()
```

You are all set 🚀! You can start using the Gini Health API through the `documentService`.

### Upload a document

As the key aspect of the Gini Health API is to provide information extraction for analyzing documents, the API is mainly built around the concept of documents. A document can be any written representation of information such as invoices, reminders, contracts and so on.

The Gini Health API lib supports creating documents from images, PDFs or UTF-8 encoded text. Images are usually a picture of a paper document which was taken with the device’s camera.

The following example shows how to create a new document from a byte array containing a JPEG image.
```swift
documentService.createDocument(fileName: "myFirstDocument.jpg",
                            docType: docType,
                            type: .partial(document.data),
                            metadata: metadata) { result in
    switch result {
    case let .success(createdDocument):
        print("📄 Created document with id: \(createdDocument.id) " +
            "for vision document \(document.id)")
        completion(.success(createdDocument))
    case let .failure(error):
        print("❌ Document creation failed: \(error)")
        completion(.failure(error))
    }
}
```

Each page of a document needs to uploaded as a partial document. In addition documents consisting of one page also should be uploaded as a partial document.

> ⚠️  **Note**
> - PDFs and UTF-8 encoded text should also be uploaded as partial documents. Even though PDFs might contain multiple pages and text is “pageless”, creating partial documents for these keeps your interaction with Gini consistent for all the supported document types.

Extractions are not available for partial documents. Creating a partial document is analogous to an upload. For retrieving extractions see Getting extractions section.

> ⚠️  **Note**
> - The `filename` (myFirstDocument.jpg in the example) is not required, it could be nil, but setting a filename is a good practice for human readable document identification.

#### Setting the document type hint

To easily set the document type hint we introduced the `DocType` enum. It is safer and easier to use than a String. For more details about the document type hints see the Document Type Hints in the [Gini Health API documentation](https://pay-api.gini.net/documentation/#document-types)

### Getting extractions

After you have successfully created the partial documents, you most likely want to get the extractions for the document. Composite documents consist of previously created partial documents. You can consider creating partial documents analogous to uploading pages of a document and creating a composite document analogous to processing those pages as a single document.

Before retrieving extractions you need to create a composite document from your partial documents

Gini needs to process the composite document first before you can fetch the extractions. Effectively this means that you won’t get any extractions before the composite document is fully processed. The processing time may vary, usually it is in the range of a couple of seconds, but blurred or slightly rotated images are known to drasticly increase the processing time.

The `DocumentService` provides `extractions()` method which can be used to fetch the extractions after the processing of the document is completed. The following example shows how to achieve this in detail.

```swift
documentService
    .createDocument(fileName: "composite-myFirstDocument.jpg",
                    docType: nil,
                    type: .composite(CompositeDocumentInfo(partialDocuments: documents)),
                    metadata: metadata) { [weak self] result in
    guard let self = self else { return }
    switch result {
    case let .success(createdDocument):
        print("🔎 Starting analysis for composite document with id \(createdDocument.id)")
        self.documentService.extractions(for: createdDocument,
                           cancellationToken: CancellationToken()) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(extractionResult):
                    completion(.success(extractionResult.extractions))
                    print("The specific extractions: \(extractionResult.extractions)")
                    print("The line item compound extractions : \(extractionResult.lineItems)")
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    case let .failure(error):
        print("❌ Composite document creation failed: \(error)")
        completion(.failure(error))
    }
}
```

### Sending feedback

Depending on your use case your app probably presents the extractions to the user and gives them the opportunity to correct them. By sending us feedback for the extractions we are able to continuously improve the extraction quality.

Your app should send feedback only for the extractions the user has seen and accepted. Feedback should be sent for corrected extractions and for correct extractions. The code example below shows how to correct extractions and send feedback.

```swift
guard let document = document else { return }

// specific extractions,that we've received in the section above
var updatedExtractions: [Extraction] = extractionResult.extractions

// amountToPay was wrong, we'll correct it
updatedExtractions.first {
    $0.name == "amountToPay"
}?.value = "31:00:EUR"

documentService.submitFeedback(for: document, with: updatedExtractions) { result in
    switch result {
    case .success:
        print("🚀 Feedback sent with \(updatedExtractions.count) extractions")
    case .failure(let error):
        print("❌ Error sending feedback for document with id: \(document.id) error: \(error)")
    }
}
```

### Handling errors

All errors that occur during request execution are handed over transparently. You can react on those errors in the `failure` case of the completion result. We recommend checking the network status when a request failed and retrying it.