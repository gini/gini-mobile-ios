//
//  DocumentList.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 3/25/19.
//

import Foundation

struct DocumentList {
    let totalCount: Int?
    let documents: [Document]
}

// MARK: - Decodable

extension DocumentList: Decodable {
    
}
