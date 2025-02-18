//
//  FileManagerHelper.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation

class FileManagerHelper {
    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    private func fileURL() -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent(fileName)
    }

    // Generic read method with auto-creation of file
    @discardableResult
    func read<T: Codable>() -> [T] {
        guard let fileURL = fileURL() else { return [] }

        // If the file does not exist, create an empty file
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            createEmptyFile()
        }
        
        print(String(data: try! Data(contentsOf: fileURL), encoding: .utf8) ?? "Empty file")

        // Read the file
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([T].self, from: data)) ?? []
    }

    // Append new items to the JSON file
    func append<T: Codable>(_ newItems: [T]) {
        var existingItems: [T] = read()
        existingItems.append(contentsOf: newItems) // Append new items to the existing ones
        write(existingItems) // Write the updated list back to the file
    }

    // Write data to the file (generic)
   func write<T: Codable>(_ objects: [T]) {
        guard let fileURL = fileURL() else { return }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(objects)
            try data.write(to: fileURL)
            print("Data written to file \(fileName) successfully.")
        } catch {
            print("Error writing data to file \(fileName): \(error.localizedDescription)")
        }
    }

    // Private helper to create an empty file
    private func createEmptyFile() {
        guard let fileURL = fileURL() else { return }

        let emptyArray: [String] = [] // Represents an empty JSON array
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(emptyArray)
            try data.write(to: fileURL)
            print("Created empty file \(fileName) in the documents directory.")
        } catch {
            print("Error creating empty file \(fileName): \(error.localizedDescription)")
        }
    }
}
