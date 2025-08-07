//
//  RecipeIngredient.swift
//  SwiftBites
//
//  Created by David Chea on 07/08/2025.
//

import SwiftData

@Model
final class RecipeIngredient {
    
    // MARK: - Properties
    
    @Relationship
    var ingredient: Ingredient
    
    @Relationship
    var recipe: Recipe?
    
    var quantity: String
    
    // MARK: - Initializers
    
    init(ingredient: Ingredient, quantity: String) {
        self.ingredient = ingredient
        self.quantity = quantity
    }
}
