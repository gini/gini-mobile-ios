//
//  HelpStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum HelpStrings: LocalizableStringResource {
    
    case menuTitle, menuFirstItemText, menuSecondItemText, menuThirdItemText, openWithTutorialTitle,
    openWithTutorialCollectionHeader, openWithTutorialStep1Title, openWithTutorialStep1Subtitle,
    openWithTutorialStep2Title, openWithTutorialStep2Subtitle,
    openWithTutorialStep3Title, openWithTutorialStep3Subtitle, supportedFormatsTitle, supportedFormatsSection1Title,
    supportedFormatsSection1Item1Text, supportedFormatsSection1Item2Text, supportedFormatsSection1Item3Text,
    supportedFormatsSection1Item4Text,
    supportedFormatsSection2Title, supportedFormatsSection2Item1Text, supportedFormatsSection2Item2Text,
    formatsTitle
    
    var tableName: String {
        return "help"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .menuTitle:
            return ("menu.title", "help menu view controller title")
        case .menuFirstItemText:
            return ("menu.firstItem", "help menu first item text")
        case .menuSecondItemText:
            return ("menu.secondItem", "help menu second item text")
        case .menuThirdItemText:
            return ("menu.thirdItem", "help menu third item text")
        case .openWithTutorialTitle:
            return ("openWithTutorial.title", "title shown when the view controller is within a view controller")
        case .openWithTutorialCollectionHeader:
            return ("openWithTutorial.collectionHeader", "intoduction header for further steps")
        case .openWithTutorialStep1Title:
            return ("openWithTutorial.step1.title", "first step title for open with tutorial")
        case .openWithTutorialStep1Subtitle:
            return ("openWithTutorial.step1.subTitle", "first step subtitle for open with tutorial")
        case .openWithTutorialStep2Title:
            return ("openWithTutorial.step2.title", "second step title for open with tutorial")
        case .openWithTutorialStep2Subtitle:
            return ("openWithTutorial.step2.subTitle", "second step subtitle for open with tutorial")
        case .openWithTutorialStep3Title:
            return ("openWithTutorial.step3.title", "third step title for open with tutorial")
        case .openWithTutorialStep3Subtitle:
            return ("openWithTutorial.step3.subTitle", "third step subtitle for open with tutorial")
        case .supportedFormatsTitle:
            return ("supportedFormats.title", "supported and unsupported formats screen title")
        case .supportedFormatsSection1Title:
            return ("supportedFormats.section.1.title", "title for supported formats section")
        case .supportedFormatsSection1Item1Text:
            return ("supportedFormats.section.1.item.1", "message for first item on supported formats section")
        case .supportedFormatsSection1Item2Text:
            return ("supportedFormats.section.1.item.2", "message for second item on supported formats section")
        case .supportedFormatsSection1Item3Text:
            return ("supportedFormats.section.1.item.3", "message for third item on supported formats section")
        case .supportedFormatsSection2Title:
            return ("supportedFormats.section.2.title", "title for supported formats section")
        case .supportedFormatsSection2Item1Text:
            return ("supportedFormats.section.2.item.1", "message for first item on supported formats section")
        case .supportedFormatsSection2Item2Text:
            return ("supportedFormats.section.2.item.2", "message for second item on supported formats section")
        case .supportedFormatsSection1Item4Text:
            return ("supportedFormats.section.1.item.4", "message for fouth item on supported formats section")
        case .formatsTitle:
            return ("Fomrats", "message for Formats screen")
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
