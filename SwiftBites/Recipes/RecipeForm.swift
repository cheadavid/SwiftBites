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
    
    @State private var name = ""
    @State private var summary = ""
    @State private var instructions = ""
    @State private var time = 10
    @State private var serving = 1
    @State private var imageData: Data?
    @State private var category: Category?
    @State private var recipeIngredients: [RecipeIngredient] = []
    
    @State private var isIngredientsPickerPresented = false
    
    // MARK: - Properties
    
    private let mode: Mode
    private var title = "Add Recipe"
    
    // MARK: - Initializers
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .edit(let recipe) = mode {
            _name = .init(initialValue: recipe.name)
            _summary = .init(initialValue: recipe.summary)
            _instructions = .init(initialValue: recipe.instructions)
            _time = .init(initialValue: recipe.time)
            _serving = .init(initialValue: recipe.serving)
            _imageData = .init(initialValue: recipe.imageData)
            _category = .init(initialValue: recipe.category)
            _recipeIngredients = .init(initialValue: recipe.recipeIngredients)
            
            title = "Edit \(recipe.name)"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            imageSection
            
            Section("Recipe Details") {
                TextField("Name", text: $name)
                TextField("Summary", text: $summary)
                Picker("Category", selection: $category) {
                    Text("None")
                        .tag(nil as Category?)
                    ForEach(categories, id: \.persistentModelID) {
                        Text($0.name)
                            .tag($0 as Category?)
                    }
                }
            }
            
            Section("Time & Serving") {
                Stepper("Time: \(time) m", value: $time, in: 5...300, step: 5)
                Stepper("Servings: \(serving) p", value: $serving, in: 1...10)
            }
            .monospacedDigit()
            
            Section("Ingredients") {
                if recipeIngredients.isEmpty {
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
                    ForEach(recipeIngredients.indices, id: \.self) { index in
                        if let ingredient = recipeIngredients[index].ingredient {
                            HStack {
                                Text(ingredient.name)
                                    .bold()
                                Spacer()
                                TextField("Quantity", text: $recipeIngredients[index].quantity)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 100)
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    recipeIngredients.remove(at: index)
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
                    text: $instructions,
                    axis: .vertical
                )
                .lineLimit(6...10)
            }
            
            if case .edit(let recipe) = mode {
                Button("Delete Recipe", role: .destructive) {
                    modelContext.delete(recipe)
                    try? modelContext.save()
                    
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Save", action: save)
                .disabled(name.isEmpty || summary.isEmpty)
        }
        .sheet(isPresented: $isIngredientsPickerPresented) {
            IngredientsView { selectedIngredient in
                let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient)
                recipeIngredients.append(recipeIngredient)
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
                            imageData = try? await photo?.loadTransferable(type: Data.self)
                        }
                    }
                ),
                matching: .images
            ) {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
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
            
            if imageData != nil {
                Button("Remove Image", role: .destructive) {
                    imageData = nil
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Methods
    
    private func save() {
        switch mode {
        case .add:
            let recipe = Recipe(
                name: name,
                imageData: imageData,
                category: category,
                recipeIngredients: recipeIngredients,
                summary: summary,
                instructions: instructions,
                time: time,
                serving: serving
            )
            
            modelContext.insert(recipe)
        case .edit(let recipe):
            recipe.name = name
            recipe.imageData = imageData
            recipe.category = category
            recipe.recipeIngredients = recipeIngredients
            recipe.summary = summary
            recipe.instructions = instructions
            recipe.time = time
            recipe.serving = serving
        }
        
        try? modelContext.save()
        dismiss()
    }
}
