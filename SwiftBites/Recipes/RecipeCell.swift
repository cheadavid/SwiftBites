//
//  RecipeCell.swift
//  SwiftBites
//
//  Created by David Chea on 10/08/2025.
//

import SwiftUI

struct RecipeCell: View {
    
    // MARK: - Properties
    
    let recipe: Recipe
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(value: RecipeForm.Mode.edit(recipe)) {
            content
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Views
    
    var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            backgroundImage
            labels
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    private var backgroundImage: some View {
        let image = {
            if let data = recipe.imageData, let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            } else {
                return Image("recipePlaceholder")
            }
        }()
        
        return image
            .resizable()
            .scaledToFill()
            .frame(maxHeight: 150)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var labels: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(recipe.name)
                .font(.headline)
            Text(recipe.summary)
                .font(.subheadline)
            HStack(spacing: 5) {
                if let category = recipe.category {
                    tag(category.name, icon: "tag")
                }
                tag("\(recipe.time) m", icon: "clock")
                tag("\(recipe.serving) p", icon: "person")
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helpers
    
    private func tag(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption2)
            .bold()
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(.accent.opacity(0.1))
            .foregroundStyle(.accent)
            .clipShape(Capsule())
    }
}
