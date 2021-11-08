//
//  GiniBankNetworkingScreenApiCoordinator+Pinning.swift
//  
//
//  Created by Nadya Karaban on 08.11.21.
//

import UIKit
import GiniBankAPILibraryPinning
import GiniBankAPILibrary
import TrustKit
import GiniCaptureSDK
import GiniBankSDK


public extension GiniBankNetworkingScreenApiCoordinator {
    convenience init(client: Client,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     giniConfiguration: GiniBankConfiguration,
                     publicKeyPinningConfig: [String: Any],
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        
        let lib = GiniBankAPI
            .Builder(client: client,
                     api: api,
                     pinningConfig: publicKeyPinningConfig)
            .build()

        self.init(client: client,
             resultsDelegate: resultsDelegate,
             configuration: giniConfiguration,
             documentMetadata: documentMetadata,
             api: api,
             trackingDelegate: trackingDelegate,
             lib: lib)
    }
}
