//
//  CategoriesList.swift
//  SwiftBites
//
//  Created by David Chea on 09/08/2025.
//

import SwiftUI
import SwiftData

struct CategoriesList: View {
    
    // MARK: - Queries
    
    @Query private var categories: [Category]
    
    // MARK: - Properties
    
    private let searchText: String
    
    // MARK: - Initializers
    
    init(searchText: String) {
        self.searchText = searchText
        
        _categories = Query(
            filter: searchText.isEmpty
            ? #Predicate<Category> { _ in true }
            : #Predicate<Category> { $0.name.localizedStandardContains(searchText) },
            sort: \Category.name
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        if categories.isEmpty && searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Categories", systemImage: "list.clipboard")
                },
                description: {
                    Text("Categories you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Category", value: CategoriesView.Destination.categoryForm(.add))
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else if categories.isEmpty && !searchText.isEmpty {
            ContentUnavailableView(
                label: {
                    Text("Couldn't find \"\(searchText)\"")
                }
            )
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 10) {
                    ForEach(categories, id: \.persistentModelID, content: CategorySection.init)
                }
            }
        }
    }
}
