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
    var name = ""
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    @Relationship
    var category: Category?
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var recipeIngredients: [RecipeIngredient] = []
    
    var summary = ""
    var instructions = ""
    var time = 10
    var serving = 1
    
    // MARK: - Initializers
    
    init(
        name: String,
        imageData: Data?,
        category: Category?,
        recipeIngredients: [RecipeIngredient],
        summary: String,
        instructions: String,
        time: Int,
        serving: Int
    ) {
        self.name = name
        self.imageData = imageData
        self.category = category
        self.summary = summary
        self.instructions = instructions
        self.time = time
        self.serving = serving
        
        self.recipeIngredients = recipeIngredients
        self.recipeIngredients.forEach { $0.recipe = self }
    }
}
