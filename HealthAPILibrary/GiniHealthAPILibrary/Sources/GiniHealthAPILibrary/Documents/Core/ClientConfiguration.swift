//
//  Configuration.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
/**
 A struct representing configuration settings.
 
 This struct holds various configuration options that can be used to customize the behavior and features.
 */
public struct ClientConfiguration: Codable {
    /**
     Creates a new `ClientConfiguration` instance.
     
     - parameter clientID: A unique identifier for the client.
     - parameter communicationTone: A configuration that indicates the comunication tone of the texts. Defaults to `nil
     - parameter ingredientBrandType: A configuration that indicates the presence of the ingredient brand. Defaults to `nil`.
     */
    public init(clientID: String,
                communicationTone: CommunicationToneEnum? = nil,
                ingredientBrandType: IngredientBrandTypeEnum? = .invisible) {
        self.clientID = clientID
        self.communicationTone = communicationTone
        self.ingredientBrandType = ingredientBrandType
    }
    
    public let clientID: String
    public var communicationTone: CommunicationToneEnum?
    public var ingredientBrandType: IngredientBrandTypeEnum?
}
