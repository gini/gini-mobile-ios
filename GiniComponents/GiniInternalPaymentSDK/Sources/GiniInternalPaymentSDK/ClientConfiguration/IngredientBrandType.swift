//
//  IngredientBrandTypeEnum.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 An enumeration representing the visibility type of an ingredient brand.
 Use this enum to indicate how the ingredient brand is displayed.
 */
public enum IngredientBrandTypeEnum: String, Codable, CaseIterable {
    case fullVisible = "FULL_VISIBLE"
    case paymentComponent = "PAYMENT_COMPONENT"
    case invisible = "INVISIBLE"
}
