import SwiftUI
import SwiftData

struct CategoriesView: View {
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    
    
    @State private var query = ""
    
    // Use #Predicate for search as required
    private var searchPredicate: Predicate<Category> {
        if query.isEmpty {
            return #Predicate<Category> { _ in true }
        } else {
            let searchQuery = query
            return #Predicate<Category> { category in
                category.name.localizedStandardContains(searchQuery)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            CategoriesListView(searchPredicate: searchPredicate, query: query)
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
        .searchable(text: $query)
    }
}

struct CategoriesListView: View {
    let searchPredicate: Predicate<Category>
    let query: String
    
    @Query private var categories: [Category]
    
    init(searchPredicate: Predicate<Category>, query: String) {
        self.searchPredicate = searchPredicate
        self.query = query
        _categories = Query(filter: searchPredicate, sort: \Category.name)
    }
    
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if categories.isEmpty && query.isEmpty {
            empty
        } else if categories.isEmpty && !query.isEmpty {
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
                NavigationLink("Add Category", value: CategoryForm.Mode.add)
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
            }
        )
    }
    
    private var noResults: some View {
        ContentUnavailableView(
            label: {
                Text("Couldn't find \"\(query)\"")
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
