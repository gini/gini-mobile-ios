//
//  SettingsViewController+SegmentedOptionModel.swift
//  GiniBankSDKExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary

protocol SegmentedOptionModelProtocol {
    var selectedIndex: Int { get set }
    var items: [String] { get }
    var title: String { get }
}

struct FileImportSegmentedOptionModel: SegmentedOptionModelProtocol {
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

struct APIEnvironmentSegmentedOptionModel: SegmentedOptionModelProtocol {
    var selectedIndex: Int = 0

    var items: [String] {
        return [APIEnvironment.production.rawValue, APIEnvironment.stage.rawValue]
    }

    var title: String {
        return "API Environment"
    }
}
