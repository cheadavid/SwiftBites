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
    var ingredients: [RecipeIngredient]
    
    var summary: String
    var instructions: String
    var serving: Int
    var time: Int
    
    // MARK: - Initializers
    
    init(
        name: String,
        imageData: Data?,
        category: Category?,
        summary: String,
        instructions: String,
        serving: Int,
        time: Int
    ) {
        self.name = name
        self.imageData = imageData
        self.category = category
        self.ingredients = []
        self.summary = summary
        self.instructions = instructions
        self.serving = serving
        self.time = time
    }
}
