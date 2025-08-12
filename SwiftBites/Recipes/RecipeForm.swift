import SwiftUI
import SwiftData
import PhotosUI

struct RecipeForm: View {
    
    // MARK: - Enums
    
    enum Mode: Hashable {
        case add
        case edit(Recipe)
    }
    
    // MARK: - Environments
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Queries
    
    @Query private var categories: [Category]
    
    // MARK: - States
    
    @State private var recipe = Recipe()
    @State private var isIngredientsPickerPresented = false
    
    // MARK: - Properties
    
    private let mode: Mode
    private var title = "Add Recipe"
    
    // MARK: - Initializers
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .edit(let recipe) = mode {
            _recipe = .init(initialValue: recipe)
            title = "Edit \(recipe.name)"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            imageSection
            
            Section("Recipe Details") {
                TextField("Name", text: $recipe.name)
                TextField("Summary", text: $recipe.summary)
                Picker("Category", selection: $recipe.category) {
                    Text("None")
                        .tag(nil as Category?)
                    ForEach(categories, id: \.persistentModelID) { category in
                        Text(category.name)
                            .tag(category as Category?)
                    }
                }
            }
            
            Section("Time & Serving") {
                Stepper("Time: \(recipe.time) m", value: $recipe.time, in: 5...300, step: 5)
                Stepper("Servings: \(recipe.serving) p", value: $recipe.serving, in: 1...10)
            }
            .monospacedDigit()
            
            Section("Ingredients") {
                if recipe.ingredients.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Ingredients", systemImage: "list.clipboard")
                        },
                        description: {
                            Text("Recipe ingredients will appear here.")
                        },
                        actions: {
                            Button("Add Ingredient") {
                                isIngredientsPickerPresented = true
                            }
                            .buttonBorderShape(.roundedRectangle)
                            .buttonStyle(.borderedProminent)
                        }
                    )
                } else {
                    ForEach(recipe.ingredients, id: \.persistentModelID) { ingredient in
                        HStack {
                            Text(ingredient.ingredient.name)
                                .bold()
                            Spacer()
                            TextField("Quantity", text: Binding(
                                get: { ingredient.quantity },
                                set: { ingredient.quantity = $0 }
                            ))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 20)
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                recipe.ingredients.removeAll { $0 == ingredient }
                            }
                        }
                    }
                    
                    Button("Add Ingredient") {
                        isIngredientsPickerPresented = true
                    }
                }
            }
            
            Section("Instructions") {
                TextField(
                    "Enter cooking instructions...",
                    text: $recipe.instructions,
                    axis: .vertical
                )
                .lineLimit(6...10)
            }
            
            if case .edit(let recipe) = mode {
                Button("Delete Recipe", role: .destructive) {
                    modelContext.delete(recipe)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Save", action: save)
                .disabled(recipe.name.isEmpty || recipe.summary.isEmpty)
        }
        .sheet(isPresented: $isIngredientsPickerPresented) {
            IngredientsView { selectedIngredient in
                let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, recipe: recipe)
                recipe.ingredients.append(recipeIngredient)
            }
        }
    }
    
    // MARK: - Views
    
    private var imageSection: some View {
        Section {
            PhotosPicker(
                selection: Binding(
                    get: { nil },
                    set: { photo in
                        Task {
                            recipe.imageData = try? await photo?.loadTransferable(type: Data.self)
                        }
                    }
                ),
                matching: .images
            ) {
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                } else {
                    Label("Select Image", systemImage: "photo")
                        .frame(maxWidth: .infinity, minHeight: 200)
                }
            }
            
            if recipe.imageData != nil {
                Button("Remove Image", role: .destructive) {
                    recipe.imageData = nil
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Methods
    
    private func save() {
        switch mode {
        case .add:
            modelContext.insert(recipe)
        case .edit(let originalRecipe):
            originalRecipe.name = recipe.name
            originalRecipe.imageData = recipe.imageData
            originalRecipe.category = recipe.category
            originalRecipe.summary = recipe.summary
            originalRecipe.instructions = recipe.instructions
            originalRecipe.time = recipe.time
            originalRecipe.serving = recipe.serving
        }
        
        dismiss()
    }
}
