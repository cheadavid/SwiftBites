//
//  Recipe.swift
//  SwiftBites
//
//  Created by David Chea on 07/08/2025.
//

import SwiftUI
import SwiftData

@Model
final class Recipe {
    
    // MARK: - Properties
    
    @Attribute(.unique)
    var name: String
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    @Relationship
    var category: Category?
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var ingredients: [RecipeIngredient] = []
    
    var summary: String
    var instructions: String
    var time: Int
    var serving: Int
    
    // MARK: - Initializers
    
    init(
        name: String = "",
        imageData: Data? = nil,
        category: Category? = nil,
        summary: String = "",
        instructions: String = "",
        time: Int = 10,
        serving: Int = 1
    ) {
        self.name = name
        self.imageData = imageData
        self.category = category
        self.summary = summary
        self.instructions = instructions
        self.time = time
        self.serving = serving
    }
    
    // MARK: - Methods
    
    func temporaryCopy() -> Recipe {
        let copy = Recipe(
            name: self.name,
            imageData: self.imageData,
            category: self.category,
            summary: self.summary,
            instructions: self.instructions,
            time: self.time,
            serving: self.serving
        )
        
        copy.ingredients = self.ingredients.map {
            RecipeIngredient(ingredient: $0.ingredient, recipe: copy, quantity: $0.quantity)
        }
        
        return copy
    }
    
    func applyValues(from recipe: Recipe) {
        self.name = recipe.name
        self.imageData = recipe.imageData
        self.category = recipe.category
        self.summary = recipe.summary
        self.instructions = recipe.instructions
        self.time = recipe.time
        self.serving = recipe.serving
        
        self.ingredients = recipe.ingredients.map {
            RecipeIngredient(ingredient: $0.ingredient, recipe: self, quantity: $0.quantity)
        }
    }
}
