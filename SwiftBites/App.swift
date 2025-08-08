import SwiftUI
import SwiftData

@main
struct SwiftBitesApp: App {
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Category.self, Ingredient.self, Recipe.self, RecipeIngredient.self])
    }
}
