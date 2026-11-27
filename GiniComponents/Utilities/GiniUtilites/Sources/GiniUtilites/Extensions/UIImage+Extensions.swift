//
//  UIImage+Extensions.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Looks up an image asset by name with host-override precedence.

 Resolution order:
 1. The host integrator's main bundle (`Bundle.main`) — lets integrators override
    any Gini asset by shipping a same-named asset in their own asset catalog.
 2. The optional `customBundle` — used by SDK configurations that expose a
    customization bundle (e.g. `GiniBankConfiguration.customResourceBundle`).
 3. The caller module's bundle — the SDK's own default asset.

 Mirrors the per-SDK helpers (`GiniBankSDK.prefferedImage(named:)` [sic],
 `GiniCaptureSDK.UIImageNamedPreferred(named:)`), both of which read their
 custom bundle from a singleton SDK configuration. Lifted into `GiniUtilites`
 so lower-level primitives (e.g. `GiniOptionRow`) can reuse the same chain
 without redeclaring it per SDK, and so the migration target is correctly
 spelled — the per-SDK copies can delete their local versions once they adopt
 this helper.

 - Parameters:
   - name: The asset name as defined in the asset catalog.
   - customBundle: An optional bundle supplied by the host SDK's configuration.
     Pass `nil` when calling from GiniUtilites itself.
 - Returns: The resolved `UIImage`, or `nil` if the asset is absent from all
   checked bundles.
 */
public func preferredImage(named name: String,
                           in customBundle: Bundle? = nil) -> UIImage? {
    if let mainBundleImage = UIImage(named: name, in: Bundle.main, compatibleWith: nil) {
        return mainBundleImage
    }
    if let customBundle,
       let customBundleImage = UIImage(named: name, in: customBundle, compatibleWith: nil) {
        return customBundleImage
    }
    return UIImage(named: name, in: .module, compatibleWith: nil)
}
