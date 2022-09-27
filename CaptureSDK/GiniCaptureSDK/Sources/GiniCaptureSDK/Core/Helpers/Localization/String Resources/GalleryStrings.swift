//
//  GalleryStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 8/1/18.
//

import Foundation

enum GalleryStrings: LocalizableStringResource {
    
    case albumsTitle, imagePickerOpenButton
    
    var tableName: String {
        switch self {
        case .albumsTitle:
            return "albums"
        case .imagePickerOpenButton:
            return "imagepicker"
        }
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .albumsTitle:
            return ("title", "title for the albums picker view controller")
        case .imagePickerOpenButton:
            return ("openbutton", "Open button title")
        }
    }
    
    var isCustomizable: Bool {
        return true
    }
    
    var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }
}
