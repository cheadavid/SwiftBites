//
//  Category.swift
//  SwiftBites
//
//  Created by David Chea on 07/08/2025.
//

import SwiftData

@Model
final class Category {
    
    // MARK: - Properties
    
    @Attribute(.unique)
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
    var recipes: [Recipe]
    
    // MARK: - Initializers
    
    init(name: String) {
        self.name = name
        self.recipes = []
    }
}
