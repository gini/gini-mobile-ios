//
//  GiniBank.swift
//  GiniBank
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary
extension GiniBank {
    /**
     Terminates the current GiniBankSDK session and releases associated resources.
     Use this method to programmatically close the SDK session when it is no longer needed.
     */
    public class func closeCurrentSDK() {
        GiniBankNetworkingScreenApiCoordinator.closeSDK()
    }

    // MARK: - Screen API with Default Networking - Initializers for 'UIViewController'

    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Bank SDK as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.

     - parameter client: `GiniClient` with the information needed to enable document analysis
     - parameter importedDocuments: There should be either images or one PDF, and they should be validated before calling this method.
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter configuration: The configuration to set.
     - parameter documentMetadata: Additional HTTP headers to send when uploading documents
     - parameter api: The Gini backend API to use. Supply .custom("domain") in order to specify a custom domain.
     - parameter userApi: The Gini user backend API to use. Supply .custom("domain") in order to specify a custom domain.
     - parameter trackingDelegate: A delegate object to receive user events

     - returns: A presentable view controller.
     */
    public class func viewController(withClient client: Client,
                                     importedDocuments: [GiniCaptureDocument]? = nil,
                                     configuration: GiniBankConfiguration,
                                     resultsDelegate: GiniCaptureResultsDelegate,
                                     documentMetadata: Document.Metadata? = nil,
                                     api: APIDomain = .default,
                                     userApi: UserDomain = .default,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil) -> UIViewController {
        let screenCoordinator = GiniBankNetworkingScreenApiCoordinator(client: client,
                                                                       resultsDelegate: resultsDelegate,
                                                                       configuration: configuration,
                                                                       documentMetadata: documentMetadata,
                                                                       api: api,
                                                                       userApi: userApi,
                                                                       trackingDelegate: trackingDelegate)
        return screenCoordinator.startSDK(withDocuments: importedDocuments)
    }

    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Bank SDK as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.

     - parameter tokenSource: Alternative token source
     - parameter importedDocuments: There should be either images or one PDF, and they should be validated before calling this method.
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter configuration: The configuration to set.
     - parameter documentMetadata: Additional HTTP headers to send when uploading documents
     - parameter trackingDelegate: A delegate object to receive user events

     - returns: A presentable view controller.
     */
    public class func viewController(withAlternativeTokenSource tokenSource: AlternativeTokenSource,
                                     importedDocuments: [GiniCaptureDocument]? = nil,
                                     configuration: GiniBankConfiguration,
                                     resultsDelegate: GiniCaptureResultsDelegate,
                                     documentMetadata: Document.Metadata? = nil,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil) -> UIViewController {
        let screenCoordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: tokenSource,
                                                                       resultsDelegate: resultsDelegate,
                                                                       configuration: configuration,
                                                                       documentMetadata: documentMetadata,
                                                                       trackingDelegate: trackingDelegate)
        return screenCoordinator.startSDK(withDocuments: importedDocuments)
    }

    // MARK: - Screen API with Custom Networking - Initializers for 'UIViewController'

    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Bank SDK as it comes pre-configured and handles
     all screens and transitions out of the box with the custom networking.
     
     - parameter importedDocuments: There should be either images or one PDF, and they should be validated before calling this method.
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter configuration: The gini bank configuration to set.
     - parameter documentMetadata: Additional HTTP headers to send when uploading documents.
     - parameter trackingDelegate: A delegate object to receive user events.
     - parameter networkingService: A delegate object which implement protocol for the document processing events.
     - parameter configurationService: A delegate object which implement protocol for the customer configuration.

     - note: Screen API with custom networking only.

     - returns: A presentable view controller.
     */
    public class func viewController(importedDocuments: [GiniCaptureDocument]? = nil,
                                     configuration: GiniBankConfiguration,
                                     resultsDelegate: GiniCaptureResultsDelegate,
                                     documentMetadata: Document.Metadata? = nil,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil,
                                     networkingService: GiniCaptureNetworkService,
                                     configurationService: ClientConfigurationServiceProtocol? = nil)
    -> UIViewController {
        let screenCoordinator = GiniBankNetworkingScreenApiCoordinator(resultsDelegate: resultsDelegate,
                                                                       configuration: configuration,
                                                                       documentMetadata: documentMetadata,
                                                                       trackingDelegate: trackingDelegate,
                                                                       captureNetworkService: networkingService,
                                                                       configurationService: configurationService)
        return screenCoordinator.startSDK(withDocuments: importedDocuments)
    }

    public class func removeStoredCredentials(for client: Client) throws {
        let lib = GiniBankAPI.Builder(client: client).build()
        try lib.removeStoredCredentials()
    }
}
