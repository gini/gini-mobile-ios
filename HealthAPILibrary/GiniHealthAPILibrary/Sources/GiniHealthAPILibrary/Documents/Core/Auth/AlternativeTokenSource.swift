//
//  AlternativeTokenSource.swift
//  AppAuth
//
//  Created by Maciej Trybilo on 25.10.19.
//

import Foundation

public protocol AlternativeTokenSource {
    
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void)
}
