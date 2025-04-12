//
//  DetallesView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

struct DetallesView: View {
    @Environment(\.presentationMode) var presentationMode
    var card: Card // Cambiamos a recibir el Card completo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Botón de regreso
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                            
                            Text(card.category)
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 10) {
                    // Título principal
                    Text(card.title)
                        .font(.title)
                        .fontWeight(.bold)

                    // Fuente
                    Text(card.source)
                        .font(.caption)
                        .foregroundColor(.gray)

                    // Descripción
                    Text(card.description)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Divider()
                    
                    // Contenido estructurado
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(card.contentBlocks.sorted { $0.order < $1.order }, id: \.self) { block in
                            ContentBlockView(block: block)
                        }
                    }
                    
                    Divider()
                    
                    // Fuente
                    Text("Artículo revisado y proporcionado por especialistas.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ContentBlockView: View {
    let block: ContentBlock
    @State private var imageLoadingError = false
    
    var body: some View {
        Group {
            if block.type == "text" {
                Text(block.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 12)
            } else if block.type == "image" {
                if imageLoadingError {
                    placeholderImage
                } else {
                    if let imageData = Data(base64Encoded: block.content.split(separator: ",").last?.description ?? ""),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                            .onAppear {
                                imageLoadingError = false
                            }
                    } else {
                        placeholderImage
                            .onAppear {
                                imageLoadingError = true
                            }
                    }
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
        .frame(height: 200)
        .cornerRadius(12)
    }
}

#Preview {
    let sampleCard = Card(
        id: "1",
        documentId: "card_1",
        originalId: 1,
        category: "Técnicas de maternidad",
        title: "Instructivo",
        description: "Principios del cuidado y preparación del parto, muda y pañalera.",
        source: "IMSS, 2025.",
        icon: "book",
        contentBlocks: [
            ContentBlock(type: "text", content: "1. Usar ropa cómoda y elástica.", order: 0),
            ContentBlock(type: "text", content: "La ropa que tú elijas puede influir en tu comodidad día a día...", order: 1)
        ]
    )
    DetallesView(card: sampleCard)
}
