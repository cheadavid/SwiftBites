import SwiftUI
import PhotosUI
import Foundation
import SwiftData

struct RecipeForm: View {
    enum Mode: Hashable {
        case add
        case edit(Recipe)
    }
    
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            title = "Add Recipe"
            _name = .init(initialValue: "")
            _summary = .init(initialValue: "")
            _serving = .init(initialValue: 1)
            _time = .init(initialValue: 5)
            _instructions = .init(initialValue: "")
            _ingredients = .init(initialValue: [])
        case .edit(let recipe):
            title = "Edit \(recipe.name)"
            _name = .init(initialValue: recipe.name)
            _summary = .init(initialValue: recipe.summary)
            _serving = .init(initialValue: recipe.serving)
            _time = .init(initialValue: recipe.time)
            _instructions = .init(initialValue: recipe.instructions)
            _ingredients = .init(initialValue: recipe.ingredients)
            _selectedCategory = .init(initialValue: recipe.category)
            _imageData = .init(initialValue: recipe.imageData)
        }
    }
    
    private let title: String
    @State private var name: String
    @State private var summary: String
    @State private var serving: Int
    @State private var time: Int
    @State private var instructions: String
    @State private var selectedCategory: Category?
    @State private var ingredients: [RecipeIngredient]
    @State private var imageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isIngredientsPickerPresented = false
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            Form {
                imageSection(width: geometry.size.width)
                nameSection
                summarySection
                categorySection
                servingAndTimeSection
                ingredientsSection
                instructionsSection
                deleteButton
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding<Bool>(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty || instructions.isEmpty)
            }
        }
        .onChange(of: imageItem) { _, _ in
            Task {
                self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
            }
        }
        .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
    }
    
    // MARK: - Views
    
    private func ingredientPicker() -> some View {
        IngredientsView { selectedIngredient in
            let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
            ingredients.append(recipeIngredient)
        }
    }
    
    @ViewBuilder
    private func imageSection(width: CGFloat) -> some View {
        Section {
            imagePicker(width: width)
            removeImage
        }
    }
    
    @ViewBuilder
    private func imagePicker(width: CGFloat) -> some View {
        PhotosPicker(selection: $imageItem, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
            } else {
                Label("Select Image", systemImage: "photo")
            }
        }
    }
    
    @ViewBuilder
    private var removeImage: some View {
        if imageData != nil {
            Button(
                role: .destructive,
                action: {
                    imageData = nil
                },
                label: {
                    Text("Remove Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    @ViewBuilder
    private var nameSection: some View {
        Section("Name") {
            TextField("Margherita Pizza", text: $name)
        }
    }
    
    @ViewBuilder
    private var summarySection: some View {
        Section("Summary") {
            TextField(
                "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
                text: $summary,
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }
    
    @ViewBuilder
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(categories, id: \.persistentModelID) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
        }
    }
    
    @ViewBuilder
    private var servingAndTimeSection: some View {
        Section {
            Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
            Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
        }
        .monospacedDigit()
    }
    
    @ViewBuilder
    private var ingredientsSection: some View {
        Section("Ingredients") {
            if ingredients.isEmpty {
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
                    }
                )
            } else {
                ForEach(ingredients, id: \.persistentModelID) { ingredient in
                    HStack(alignment: .center) {
                        Text(ingredient.ingredient.name)
                            .bold()
                            .layoutPriority(2)
                        Spacer()
                        TextField("Quantity", text: Binding(
                            get: {
                                ingredient.quantity
                            },
                            set: { quantity in
                                ingredient.quantity = quantity
                            }
                        ))
                        .layoutPriority(1)
                    }
                }
                .onDelete(perform: deleteIngredients)
                
                Button("Add Ingredient") {
                    isIngredientsPickerPresented = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField(
                """
                1. Preheat the oven to 475°F (245°C).
                2. Roll out the dough on a floured surface.
                3. ...
                """,
                text: $instructions,
                axis: .vertical
            )
            .lineLimit(8...12)
        }
    }
    
    @ViewBuilder
    private var deleteButton: some View {
        if case .edit(let recipe) = mode {
            Button(
                role: .destructive,
                action: {
                    delete(recipe: recipe)
                },
                label: {
                    Text("Delete Recipe")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    // MARK: - Data
    
    func delete(recipe: Recipe) {
        guard case .edit(let recipe) = mode else {
            fatalError("Delete unavailable in add mode")
        }
        modelContext.delete(recipe)
        do {
            try modelContext.save()
        } catch {
            self.error = error
            return
        }
        dismiss()
    }
    
    func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            let ingredientsToDelete = offsets.map { ingredients[$0] }
            for ingredient in ingredientsToDelete {
                if let index = ingredients.firstIndex(of: ingredient) {
                    ingredients.remove(at: index)
                }
                modelContext.delete(ingredient)
            }
        }
    }
    
    // Replace the problematic section in your save() method (around line 320-330)
    // with this corrected version:
    
    func save() {
        do {
            switch mode {
            case .add:
                let recipe = Recipe(
                    name: name,
                    imageData: imageData,
                    category: selectedCategory,
                    summary: summary,
                    instructions: instructions,
                    serving: serving,
                    time: time
                )
                modelContext.insert(recipe)
                
                // Add ingredients to the recipe
                for ingredient in ingredients {
                    ingredient.recipe = recipe
                    modelContext.insert(ingredient)
                }
                
            case .edit(let recipe):
                recipe.name = name
                recipe.summary = summary
                recipe.serving = serving
                recipe.time = time
                recipe.instructions = instructions
                recipe.imageData = imageData
                recipe.category = selectedCategory
                
                // Update ingredients - remove old ones and add new ones
                for oldIngredient in recipe.ingredients {
                    modelContext.delete(oldIngredient)
                }
                
                for ingredient in ingredients {
                    ingredient.recipe = recipe
                    // Simply insert all ingredients since we deleted the old ones
                    modelContext.insert(ingredient)
                }
            }
            
            try modelContext.save()
            dismiss()
        } catch {
            self.error = error
        }
    }
}
