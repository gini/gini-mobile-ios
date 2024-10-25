//
//  Document+UploadMetadata.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

extension Document {
    /**
     * The metadata contains document upload metadata
     */
    public class UploadMetadata: NSObject {
        var userComment: String
        static let userCommentRotation = "RotDeltaDeg"
        static let userCommentContentId = "ContentId"
        static let userCommentPlatform = "Platform"
        static let userCommentOSVer = "OSVer"
        static let userCommentGiniVersionVer = "GiniCaptureVer"
        static let userCommentDeviceOrientation = "DeviceOrientation"
        static let userCommentSource = "Source"
        static let userCommentImportMethod = "ImportMethod"
        static let userCommentEntryPoint = "EntryPoint"

        /**
         * The document upload metadata initializer
         * headers.
         *
         * - Parameter giniCaptureVersion:   GiniCapture version
         * - Parameter deviceOrientation:    Device orientation, portrait or landscape
         * - Parameter source:               Source of the document
         * - Parameter importMethod:         Import method
         * - Parameter entryPoint:           Entry point
         * - Parameter osVersion:            OS version
         */
        public init(
            giniCaptureVersion: String,
            deviceOrientation: String,
            source: String,
            importMethod: String,
            entryPoint: String,
            osVersion: String
        ) {
            userComment = Self.constructComment(
                osVersion: osVersion,
                giniVersion: giniCaptureVersion,
                contentId: "",
                source: source,
                entryPoint: entryPoint,
                importMethod: importMethod,
                deviceOrientation: deviceOrientation,
                rotation: ""
            )
        }
        public static func constructComment(
            osVersion: String,
            giniVersion: String,
            contentId: String,
            source: String,
            entryPoint: String,
            importMethod: String,
            deviceOrientation: String,
            rotation: String
        ) -> String {
            var comment = "\(userCommentPlatform)=iOS"
            let data = [
                (userCommentOSVer, osVersion),
                (userCommentGiniVersionVer, giniVersion),
                (userCommentContentId, contentId),
                (userCommentSource, source),
                (userCommentEntryPoint, entryPoint),
                (userCommentImportMethod, importMethod),
                (userCommentDeviceOrientation, deviceOrientation),
                (userCommentRotation, rotation)
            ]
            for (paramName, value) in data {
                if !value.isEmpty {
                    comment += ",\(paramName)=\(value)"
                }
            }
            return comment
        }
    }
}
