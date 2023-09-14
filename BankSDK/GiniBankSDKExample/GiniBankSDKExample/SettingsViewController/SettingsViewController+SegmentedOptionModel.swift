//
//  SettingsViewController+SegmentedOptionModel.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 16.06.23.
//

struct SegmentedOptionModel {
	var selectedIndex: Int = 0
	
    enum ImportFileType: String {
        case none = "Disabled"
        case pdf = "PDF"
        case pdfAndImages = "PDF & Images"
    }

    var items: [String] {
            return [ImportFileType.none.rawValue, ImportFileType.pdf.rawValue, ImportFileType.pdfAndImages.rawValue]
    }
    
    var title: String {
        return "File import"
    }
}
