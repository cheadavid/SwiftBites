import SwiftUI

struct RecipesView: View {
    
    // MARK: - States
    
    @State private var searchText = ""
    @State private var sortOrder = SortDescriptor(\Recipe.name)
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            RecipesList(searchText: searchText, sortOrder: sortOrder)
                .navigationTitle("Recipes")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $sortOrder) {
                                Text("Name")
                                    .tag(SortDescriptor(\Recipe.name))
                                Text("Time (Short to Long)")
                                    .tag(SortDescriptor(\Recipe.time, order: .forward))
                                Text("Time (Long to Short)")
                                    .tag(SortDescriptor(\Recipe.time, order: .reverse))
                                Text("Serving (Low to High)")
                                    .tag(SortDescriptor(\Recipe.serving, order: .forward))
                                Text("Serving (High to Low)")
                                    .tag(SortDescriptor(\Recipe.serving, order: .reverse))
                            }
                        }
                    }
                    ToolbarItem {
                        NavigationLink(value: RecipeForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .searchable(text: $searchText)
                .navigationDestination(for: RecipeForm.Mode.self) { RecipeForm(mode: $0) }
        }
    }
}
