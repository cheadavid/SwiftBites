import SwiftUI

typealias Selection = (Ingredient) -> Void

struct IngredientsView: View {
    
    // MARK: - States
    
    @State private var searchText = ""
    
    // MARK: - Properties
    
    let selection: Selection?
    
    // MARK: - Initializers
    
    init(selection: Selection? = nil) {
        self.selection = selection
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            IngredientsListView(searchText: searchText, selection: selection)
                .toolbar {
                    NavigationLink(value: IngredientForm.Mode.add) {
                        Label("Add", systemImage: "plus")
                    }
                }
                .navigationTitle("Ingredients")
                .searchable(text: $searchText)
                .navigationDestination(for: IngredientForm.Mode.self) { mode in
                    IngredientForm(mode: mode)
                }
        }
    }
}
