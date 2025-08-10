import SwiftUI

struct IngredientForm: View {
    
    // MARK: - Enums
    
    enum Mode: Hashable {
        case add
        case edit(Ingredient)
    }
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - States
    
    @State private var name = ""
    @FocusState private var isNameFocused
    
    // MARK: - Properties
    
    private let mode: Mode
    private var title = "Add Ingredient"
    
    // MARK: - Initializers
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .edit(let ingredient) = mode {
            _name = .init(initialValue: ingredient.name)
            title = "Edit \(ingredient.name)"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            
            if case .edit(let ingredient) = mode {
                Button("Delete Ingredient", role: .destructive) {
                    modelContext.delete(ingredient)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            isNameFocused = true
        }
        .onSubmit {
            save()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Save", action: save)
                .disabled(name.isEmpty)
        }
    }
    
    // MARK: - Methods
    
    private func save() {
        switch mode {
        case .add:
            let ingredient = Ingredient(name: name)
            modelContext.insert(ingredient)
        case .edit(let ingredient):
            ingredient.name = name
        }
        
        dismiss()
    }
}
