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
    
    init(name: String = "",
         imageData: Data? = nil,
         category: Category? = nil,
         summary: String = "",
         instructions: String = "",
         time: Int = 10,
         serving: Int = 1) {
        self.name = name
        self.imageData = imageData
        self.category = category
        self.summary = summary
        self.instructions = instructions
        self.time = time
        self.serving = serving
    }
}
