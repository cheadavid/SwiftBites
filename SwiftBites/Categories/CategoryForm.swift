import SwiftUI

struct CategoryForm: View {
    
    // MARK: - Enums
    
    enum Mode: Hashable {
        case add
        case edit(Category)
    }
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - States
    
    @State private var name = ""
    @FocusState private var isNameFocused
    
    // MARK: - Properties
    
    private let mode: Mode
    private let title: String
    
    // MARK: - Initializers
    
    init(mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .add:
            title = "Add Category"
        case .edit(let category):
            _name = .init(initialValue: category.name)
            title = "Edit \(category.name)"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            
            if case .edit(let category) = mode {
                Button("Delete Category", role: .destructive) {
                    modelContext.delete(category)
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
            let category = Category(name: name)
            modelContext.insert(category)
        case .edit(let category):
            category.name = name
        }
        
        dismiss()
    }
}
