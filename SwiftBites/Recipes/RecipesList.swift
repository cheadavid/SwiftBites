//
//  RecipesList.swift
//  SwiftBites
//
//  Created by David Chea on 10/08/2025.
//

import SwiftUI
import SwiftData

struct RecipesList: View {
    
    // MARK: - Queries
    
    @Query private var recipes: [Recipe]
    
    // MARK: - Properties
    
    private let searchText: String
    private let sortOrder: SortDescriptor<Recipe>
    
    // MARK: - Initializers
    
    init(searchText: String, sortOrder: SortDescriptor<Recipe>) {
        self.searchText = searchText
        self.sortOrder = sortOrder
        
        _recipes = Query(
            filter: searchText.isEmpty
            ? #Predicate<Recipe> { _ in true }
            : #Predicate<Recipe> { $0.name.localizedStandardContains(searchText) || $0.summary.localizedStandardContains(searchText) },
            sort: [sortOrder]
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        if recipes.isEmpty && searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Recipes", systemImage: "list.clipboard")
                },
                description: {
                    Text("Recipes you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Recipe", value: RecipeForm.Mode.add)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else if recipes.isEmpty && !searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Text("Couldn't find \"\(searchText)\"")
                }
            )
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 10) {
                    ForEach(recipes, id: \.persistentModelID, content: RecipeCell.init)
                }
            }
        }
    }
}
