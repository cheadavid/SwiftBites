//
//  IngredientsList.swift
//  SwiftBites
//
//  Created by David Chea on 08/08/2025.
//

import SwiftUI
import SwiftData

struct IngredientsList: View {
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Queries
    
    @Query private var ingredients: [Ingredient]
    
    // MARK: - Properties
    
    private let searchText: String
    private let selection: Selection?
    
    // MARK: - Initializers
    
    init(searchText: String, selection: Selection?) {
        self.searchText = searchText
        self.selection = selection
        
        _ingredients = Query(
            filter: searchText.isEmpty
            ? #Predicate<Ingredient> { _ in true }
            : #Predicate<Ingredient> { $0.name.localizedStandardContains(searchText) },
            sort: \Ingredient.name
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        if ingredients.isEmpty && searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Ingredients", systemImage: "list.clipboard")
                },
                description: {
                    Text("Ingredients you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Ingredient", value: IngredientForm.Mode.add)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else if ingredients.isEmpty && !searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Text("Couldn't find \"\(searchText)\"")
                }
            )
        } else {
            List(ingredients, id: \.persistentModelID) { ingredient in
                Group {
                    if let selection {
                        Button(ingredient.name) {
                            selection(ingredient)
                            dismiss()
                        }
                    } else {
                        NavigationLink(value: IngredientForm.Mode.edit(ingredient)) {
                            Text(ingredient.name)
                        }
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(ingredient)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
