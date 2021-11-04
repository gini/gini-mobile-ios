//
//  GiniCapture+GiniCaptureDelegate.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import GiniBankAPILibrary

extension GiniCapture {
    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Capture SDK as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.
     
     - parameter client: `GiniClient` with the information needed to enable document analysis
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter configuration: The configuration to set.
     - parameter documentMetadata: Additional HTTP headers to send when uploading documents
     - parameter api: The Gini backend API to use. Supply .custom("domain") in order to specify a custom domain.
     - parameter userApi: The Gini user backend API to use. Supply .custom("domain") in order to specify a custom domain.
     - parameter trackingDelegate: A delegate object to receive user events

     - note: Screen API only.

     - returns: A presentable view controller.
     */
    public class func viewController(withClient client: Client,
                                     importedDocuments: [GiniCaptureDocument]? = nil,
                                     configuration: GiniConfiguration,
                                     resultsDelegate: GiniCaptureResultsDelegate,
                                     documentMetadata: Document.Metadata? = nil,
                                     api: APIDomain = .default,
                                     userApi: UserDomain = .default,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil) -> UIViewController {
        GiniCapture.setConfiguration(configuration)
        let screenCoordinator = GiniNetworkingScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: configuration,
                                                         documentMetadata: documentMetadata,
                                                         api: api,
                                                         userApi: userApi,
                                                         trackingDelegate: trackingDelegate)
        configuration.giniErrorLogger = GiniErrorLogger(documentService: screenCoordinator.documentService)
        return screenCoordinator.start(withDocuments: importedDocuments)
    }
    
    public class func removeStoredCredentials(for client: Client) throws {
        let lib = GiniBankAPI.Builder(client: client).build()
        
        try lib.removeStoredCredentials()
    }
    
}
