//
//  CategoryCard.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//


import SwiftUI

struct CategoryCard: View {
    var title: String
    var description: String
    var iconContent: () -> AnyView
    var isSmall: Bool = false

    init(title: String, description: String, @ViewBuilder iconContent: @escaping () -> some View, isSmall: Bool = false) {
        self.title = title
        self.description = description
        self.iconContent = { AnyView(iconContent()) }
        self.isSmall = isSmall
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .fontWeight(.bold)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            Spacer()

            HStack {
                Spacer()
                iconContent()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    CategoryCard(
        title: "Técnicas de maternidad",
        description: "Principios del cuidado y preparación del parto...",
        iconContent: {
            Image(systemName: "figure.dress")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 30)
                .foregroundColor(.pink)
        }
    )
}
