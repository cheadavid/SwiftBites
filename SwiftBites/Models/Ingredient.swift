//
//  Ingredient.swift
//  SwiftBites
//
//  Created by David Chea on 07/08/2025.
//

import SwiftData

@Model
final class Ingredient {
    
    // MARK: - Properties
    
    @Attribute(.unique)
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.ingredient)
    var recipeIngredients: [RecipeIngredient]
    
    // MARK: - Initializers
    
    init(name: String) {
        self.name = name
        self.recipeIngredients = []
    }
}
