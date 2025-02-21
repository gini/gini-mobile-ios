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
        private static let userCommentRotation = "RotDeltaDeg"
        private static let userCommentContentId = "ContentId"
        private static let userCommentPlatform = "Platform"
        private static let userCommentOSVer = "OSVer"
        private static let userCommentGiniVersionVer = "GiniCaptureVer"
        private static let userCommentDeviceOrientation = "DeviceOrientation"
        private static let userCommentSource = "Source"
        private static let userCommentImportMethod = "ImportMethod"
        private static let userCommentEntryPoint = "EntryPoint"

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
            let data = [
                (userCommentPlatform, "iOS"),
                (userCommentOSVer, osVersion),
                (userCommentGiniVersionVer, giniVersion),
                (userCommentContentId, contentId),
                (userCommentSource, source),
                (userCommentEntryPoint, entryPoint),
                (userCommentImportMethod, importMethod),
                (userCommentDeviceOrientation, deviceOrientation),
                (userCommentRotation, rotation)
            ]
            return Self.userComment(createFrom: data)
        }

        static func userComment(createFrom data: [(key: String, value: String)]) -> String {
            var comment = ""
            for (paramName, value) in data {
                guard !paramName.isEmpty, !value.isEmpty else { continue }
                if !comment.isEmpty {
                    comment += ","
                }
                comment += "\(paramName)=\(value)"
            }
            return comment
        }

        static func userComment(_ existingComment: String, valueAtKey wantedKey: String) -> String? {
            let keyValues = existingComment
                .split(separator: ",")
                .map { $0.split(separator: "=") }
                .filter { $0.count == 2 }
                .map { ($0[0], $0[1]) }
            let keyValuesStrings = keyValues
                .map { (String($0.0), String($0.1)) }
            guard let value = keyValuesStrings.first(where: { $0.0 == wantedKey })?.1 else {
                return nil
            }

            return value
        }

        static func userComment(_ existingComment: String, valuePresentAtKey value: String) -> Bool {
            return userComment(existingComment, valueAtKey: value) != nil
        }

        static func userComment(_ existingComment: String?, addingIfNotPresent value: String, forKey key: String) -> String {
            let newValueString = "\(key)=\(value)"
            guard let existingComment, existingComment.isNotEmpty else {
                return newValueString
            }

            guard !userComment(existingComment, valuePresentAtKey: key) else {
                return existingComment
            }
            return existingComment + "," + newValueString
        }
    }
}
