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
    var ingredients: [RecipeIngredient] = []
    
    var summary = ""
    var instructions = ""
    var time = 10
    var serving = 1
    
    // MARK: - Initializers
    
    init() {}
}
