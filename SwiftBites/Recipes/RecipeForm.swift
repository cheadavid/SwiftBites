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
                                set: { quantity in ingredient.quantity = quantity }
                            ))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                if let index = recipe.ingredients.firstIndex(of: ingredient) {
                                    recipe.ingredients.remove(at: index)
                                }
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
            
            if case .edit(let originalRecipe) = mode {
                Button("Delete Recipe", role: .destructive) {
                    delete(recipe: originalRecipe)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onSubmit {
            save()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Save", action: save)
                .disabled(recipe.name.isEmpty || recipe.instructions.isEmpty)
        }
        .sheet(isPresented: $isIngredientsPickerPresented) {
            IngredientsView { selectedIngredient in
                let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
                recipe.ingredients.append(recipeIngredient)
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var imageSection: some View {
        Section {
            PhotosPicker(
                selection: Binding(
                    get: { nil },
                    set: { newItem in
                        Task {
                            recipe.imageData = try? await newItem?.loadTransferable(type: Data.self)
                        }
                    }
                ),
                matching: .images
            ) {
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                        .clipped()
                        .listRowInsets(EdgeInsets())
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
    
    private func delete(recipe: Recipe) {
        modelContext.delete(recipe)
        dismiss()
    }
    
    private func save() {
        switch mode {
        case .add:
            // Pour un nouvel ajout, on insert la recette qui contient déjà ses ingrédients
            modelContext.insert(recipe)
            
            // Les ingrédients sont automatiquement reliés via la relation
            for ingredient in recipe.ingredients {
                ingredient.recipe = recipe
                modelContext.insert(ingredient)
            }
            
        case .edit(let originalRecipe):
            // Pour une édition, on met à jour directement l'objet original
            originalRecipe.name = recipe.name
            originalRecipe.summary = recipe.summary
            originalRecipe.serving = recipe.serving
            originalRecipe.time = recipe.time
            originalRecipe.instructions = recipe.instructions
            originalRecipe.imageData = recipe.imageData
            originalRecipe.category = recipe.category
            
            // Gestion des ingrédients : supprimer les anciens et ajouter les nouveaux
            for oldIngredient in originalRecipe.ingredients {
                modelContext.delete(oldIngredient)
            }
            
            for ingredient in recipe.ingredients {
                ingredient.recipe = originalRecipe
                modelContext.insert(ingredient)
            }
        }
        
        dismiss()
    }
}
