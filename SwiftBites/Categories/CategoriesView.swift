import SwiftUI

struct CategoriesView: View {
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - States
    
    @State private var searchText = ""
    
    // Use #Predicate for search as required
    private var searchPredicate: Predicate<Category> {
        if searchText.isEmpty {
            return #Predicate<Category> { _ in true }
        } else {
            let searchQuery = searchText
            return #Predicate<Category> { category in
                category.name.localizedStandardContains(searchQuery)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            CategoriesListView(searchPredicate: searchPredicate, searchText: searchText)
                .navigationTitle("Categories")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: CategoryForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: CategoryForm.Mode.self) { mode in
                    CategoryForm(mode: mode)
                }
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                    RecipeForm(mode: mode)
                }
        }
        .searchable(text: $searchText)
    }
}

