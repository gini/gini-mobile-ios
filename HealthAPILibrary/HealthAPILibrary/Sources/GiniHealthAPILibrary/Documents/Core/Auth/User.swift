//
//  User.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

struct User: Codable {
    let password: String
    let email: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

}
