//
//  FileLoader.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

struct FileLoader {
    static func loadFile(withName mockFileName: String, ofType fileType: String) -> Data? {
        guard let filePath = Bundle.module.path(forResource: mockFileName, ofType: fileType) else {
            print("File not found.")
            return nil
        }

        let fileURL = URL(fileURLWithPath: filePath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Error loading file:", error)
            return nil
        }
    }
}
