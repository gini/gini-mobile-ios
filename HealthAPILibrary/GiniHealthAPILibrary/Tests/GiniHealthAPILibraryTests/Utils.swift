//
//  Utils.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

@testable import GiniHealthAPILibrary

func loadFile(withName name: String, ofType type: String) -> Data {
    
    guard let fileURLPath = Bundle.module.path(forResource: name, ofType: type),
          let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath)) else {
        fatalError("Could not load \(name).\(type) in tests")
    }
    return data
}

func load<T: Decodable>(fromFile named: String, type: String) -> T {
    let jsonData = loadFile(withName: named, ofType: type)
    do {
        let decoded = try JSONDecoder().decode(T.self, from: jsonData)
        return decoded
    } catch {
        fatalError("Could not decode \(named).\(type) in tests: \(error)")
    }
}

