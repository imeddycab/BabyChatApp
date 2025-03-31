//
//  InicioView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

struct InicioView: View {
    @State private var cards: [Card] = DataLoader.loadJSON()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Botón de Inicio
                Text("Inicio")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.pink)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                // Mostrar las tarjetas
                ForEach(cards) { card in
                    NavigationLink(destination: DetallesView(
                        category: card.category,
                        title: card.title,
                        description: card.description,
                        content: card.content,
                        source: card.source
                    )) {
                        CategoryCard(
                            title: card.title,
                            description: card.description,
                            iconContent: {
                                Image(systemName: card.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 30)
                                    .foregroundColor(.pink)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle()) // Evita el estilo predeterminado del botón
                }
            }
            .padding(.bottom, 90) // Espacio para el TabBar
        }
        .navigationBarHidden(true) // Oculta la barra de navegación
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    InicioView()
}
