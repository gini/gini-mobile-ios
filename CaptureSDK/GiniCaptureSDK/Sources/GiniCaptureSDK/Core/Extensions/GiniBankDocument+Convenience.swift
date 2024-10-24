//
//  GiniBankDocument+Convenience.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit

extension Document.UploadMetadata {
    convenience init(
        interfaceOrientation: UIInterfaceOrientation,
        documentSource: DocumentSource,
        importMethod: DocumentImportMethod?
    ) {
        self.init(
            giniCaptureVersion: GiniCaptureSDKVersion,
            deviceOrientation: interfaceOrientation.isLandscape ? "landscape" : "portrait",
            source: documentSource.value,
            importMethod: importMethod?.rawValue ?? "",
            entryPoint: GiniConfiguration.shared.entryPoint.stringValue,
            osVersion: UIDevice.current.systemVersion
        )
    }

    convenience init(
        deviceOrientation: UIDeviceOrientation,
        documentSource: DocumentSource,
        importMethod: DocumentImportMethod?
    ) {
        self.init(
            giniCaptureVersion: GiniCaptureSDKVersion,
            deviceOrientation: deviceOrientation.isLandscape ? "landscape" : "portrait",
            source: documentSource.value,
            importMethod: importMethod?.rawValue ?? "",
            entryPoint: GiniConfiguration.shared.entryPoint.stringValue,
            osVersion: UIDevice.current.systemVersion
        )
    }
}
