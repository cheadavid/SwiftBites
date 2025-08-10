import SwiftUI
import SwiftData

struct RecipesView: View {
    @State private var query = ""
    @State private var sortOrder = SortDescriptor(\Recipe.name)
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            RecipesList(searchText: query, sortOrder: sortOrder)
                .navigationTitle("Recipes")
                .toolbar {
                    sortOptions
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: RecipeForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .searchable(text: $query)
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                    RecipeForm(mode: mode)
                }
        }
    }
    
    // MARK: - Views
    
    @ToolbarContentBuilder
    var sortOptions: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $sortOrder) {
                    Text("Name")
                        .tag(SortDescriptor(\Recipe.name))
                    
                    Text("Serving (low to high)")
                        .tag(SortDescriptor(\Recipe.serving, order: .forward))
                    
                    Text("Serving (high to low)")
                        .tag(SortDescriptor(\Recipe.serving, order: .reverse))
                    
                    Text("Time (short to long)")
                        .tag(SortDescriptor(\Recipe.time, order: .forward))
                    
                    Text("Time (long to short)")
                        .tag(SortDescriptor(\Recipe.time, order: .reverse))
                }
            }
            .pickerStyle(.inline)
        }
    }
}
