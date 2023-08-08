//
//  SettingsViewController+SegmentedOptionModel.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 16.06.23.
//

struct SegmentedOptionModel {
    var optionType: OptionType
	var selectedIndex: Int = 0
	
    enum ImportFileType: String {
        case none = "Disabled"
        case pdf = "PDF"
        case pdfAndImages = "PDF & Images"
    }
    
    enum EntryPointType: String {
        case button = "Button"
        case field = "Field"
    }
    
    var items: [String] {
        switch optionType {
        case .fileImport:
            return [ImportFileType.none.rawValue, ImportFileType.pdf.rawValue, ImportFileType.pdfAndImages.rawValue]
        case .entryPoint:
            return [EntryPointType.button.rawValue, EntryPointType.field.rawValue]
        }
    }
    
    var title: String {
        switch optionType {
        case .fileImport:
            return "File import"
        case .entryPoint:
            return "Entry point"
        }
    }
    
    enum OptionType {
        case fileImport
        case entryPoint
    }
}
