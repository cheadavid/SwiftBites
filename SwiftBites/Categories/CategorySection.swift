import SwiftUI

struct CategorySection: View {
    
    // MARK: - Properties
    
    let category: Category
    
    // MARK: - Body
    
    var body: some View {
        Section(
            content: {
                if category.recipes.isEmpty {
                    empty
                } else {
                    list
                }
            },
            header: {
                HStack {
                    Text(category.name)
                        .font(.title2)
                        .bold()
                    Spacer()
                    NavigationLink("Edit", value: CategoriesView.Destination.categoryForm(.edit(category)))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        )
    }
    
    // MARK: - Views
    
    private var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Recipes", systemImage: "list.clipboard")
            },
            description: {
                Text("Recipes you add will appear here.")
            },
            actions: {
                NavigationLink("Add Recipe", value: CategoriesView.Destination.recipeForm(.add))
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.bordered)
            }
        )
    }
    
    private var list: some View {
        ScrollView {
            LazyHStack {
                ForEach(category.recipes, id: \.persistentModelID) { recipe in
                    NavigationLink(value: CategoriesView.Destination.recipeForm(.edit(recipe))) {
                        RecipeCell(recipe: recipe).content
                    }
                }
            }
        }
    }
}
