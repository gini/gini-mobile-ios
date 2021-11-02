//
//  GiniCapture+Pinning.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//

import UIKit
import GiniBankAPILibrary
import GiniBankAPILibraryPinning
import GiniCaptureSDK
import TrustKit

extension GiniCapture {
    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Capture SDK as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.
     
     - parameter client: `GiniClient` with the information needed to enable document analysis
     - parameter configuration: The configuration to set.
     - parameter importedDocuments: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter publicKeyPinningConfig: Public key pinning configuration.
     
     - note: Screen API only.
     
     - returns: A presentable view controller.
     */
    
    public class func viewController(withClient client: Client,
                                     importedDocuments: [GiniCaptureDocument]? = nil,
                                     configuration: GiniConfiguration,
                                     resultsDelegate: GiniCaptureResultsDelegate,
                                     publicKeyPinningConfig: [String: Any],
                                     documentMetadata: Document.Metadata? = nil,
                                     api: APIDomain = .default,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil
    ) -> UIViewController {
        
        GiniCapture.setConfiguration(configuration)

        let screenCoordinator = GiniNetworkingScreenAPICoordinator(client: client,
                                                                   resultsDelegate: resultsDelegate,
                                                                   giniConfiguration: configuration,
                                                                   publicKeyPinningConfig: publicKeyPinningConfig,
                                                                   documentMetadata: documentMetadata,
                                                                   api: api,
                                                                   trackingDelegate: trackingDelegate)
        return screenCoordinator.start(withDocuments: importedDocuments)
    }
    
}
