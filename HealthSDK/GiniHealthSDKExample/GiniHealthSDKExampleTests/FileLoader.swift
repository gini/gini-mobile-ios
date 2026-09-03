//
//  FileLoader.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniUtilites

struct FileLoader {
    static func loadFile(withName mockFileName: String, ofType fileType: String) -> Data? {
        guard let filePath = Bundle.main.path(forResource: mockFileName, ofType: fileType) else {
            GiniUtilites.Log("File not found.", event: .warning)
            return nil
        }

        let fileURL = URL(fileURLWithPath: filePath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            GiniUtilites.Log("Error loading file: \(error)", event: .error)
            return nil
        }
    }
}
