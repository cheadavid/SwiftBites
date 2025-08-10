import SwiftUI

struct CategoriesView: View {
    
    // MARK: - Enums
    
    enum Destination: Hashable {
        case categoryForm(CategoryForm.Mode)
        case recipeForm(RecipeForm.Mode)
    }
    
    // MARK: - States
    
    @State private var searchText = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            CategoriesList(searchText: searchText)
                .navigationTitle("Categories")
                .toolbar {
                    NavigationLink(value: Destination.categoryForm(.add)) {
                        Label("Add", systemImage: "plus")
                    }
                }
                .searchable(text: $searchText)
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .categoryForm(let mode):
                        CategoryForm(mode: mode)
                    case .recipeForm(let mode):
                        RecipeForm(mode: mode)
                    }
                }
        }
    }
}
