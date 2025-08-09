//
//  CategoriesListView.swift
//  SwiftBites
//
//  Created by David Chea on 09/08/2025.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    
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
            : #Predicate<Category> { category in
                category.name.localizedStandardContains(searchText)
            },
            sort: \Category.name
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if categories.isEmpty && searchText.isEmpty {
            empty
        } else if categories.isEmpty && !searchText.isEmpty {
            noResults
        } else {
            list
        }
    }
    
    private var empty: some View {
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
    }
    
    private var noResults: some View {
        ContentUnavailableView(
            label: {
                Text("Couldn't find \"\(searchText)\"")
            }
        )
    }
    
    private var list: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 10) {
                ForEach(categories, id: \.persistentModelID, content: CategorySection.init)
            }
        }
    }
}
