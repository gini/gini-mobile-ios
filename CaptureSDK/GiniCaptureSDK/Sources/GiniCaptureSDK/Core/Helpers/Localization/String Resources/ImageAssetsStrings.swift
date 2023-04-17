//
//  ImageAssetsStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/23/19.
//

import Foundation

public enum ImageAssetsStrings: LocalizableStringResource {

    case openWithTutorialStep1, openWithTutorialStep2, openWithTutorialStep3

    public var tableName: String {
        return "images"
    }

    public var tableEntry: LocalizationEntry {
        switch self {
        case .openWithTutorialStep1:
            return ("openWithTutorialStep1", "Firs step image name")
        case .openWithTutorialStep2:
            return ("openWithTutorialStep2", "Second step image name")
        case .openWithTutorialStep3:
            return ("openWithTutorialStep3", "Third step image name")
        }
    }

    public var isCustomizable: Bool {
        return true
    }

    public var fallbackTableEntry: String {
        return ""
    }
}
