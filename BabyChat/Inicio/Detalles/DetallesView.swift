//
//  DetallesView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

struct DetallesView: View {
    @Environment(\.presentationMode) var presentationMode
    var category: String
    var title: String
    var description: String
    var content: String
    var source: String
    
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
                            
                            Text(category)
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
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)

                    // Fuente
                    Text(source)
                        .font(.caption)
                        .foregroundColor(.gray)

                    // Descripción
                    Text(description)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Divider()
                        .background(Color.gray) // Opcional para cambiar el color de la línea
                    
                    // Imagen ilustrativa (placeholder)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.pink)
                        .frame(height: 200)
                        .overlay(
                            Text("Imagen ilustrativa de pañalera abierta.")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(8),
                            alignment: .bottomTrailing
                        )

                    // Contenido principal
                    VStack(alignment: .leading, spacing: 20) {
                        FormatText(text: content)
                    }

                    // Segunda imagen (carga visual, otra imagen ilustrativa)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.pink)
                        .frame(height: 120)

                    // Espacio adicional al final
                    Spacer(minLength: 10)
                    
                    Divider()
                        .background(Color.gray)
                    
                    // Fuente
                    Text("Artículo revisado y proporcionado por Dr. Juan Pérez Cazares, Pediatrics Specialist.")
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
            .navigationBarHidden(true) // Oculta la barra de navegación
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    DetallesView(
        category: "Técnicas de maternidad",
        title: "Instructivo",
        description: "Principios del cuidado y preparación del parto, muda y pañalera.",
        content: "Antes de dar el gran paso a la maternidad es importante que conozcas los cuidados que son adecuados antes y después del parto, que deberías usar, pero igual qué deberías preparar antes de entrar en labor.\n\n1. Usar ropa cómoda y elástica.\nLa ropa que tú elijas puede influir en tu comodidad día a día, no solo el día de parto, elegir una muda que no afecte tu comodidad puede disminuir el ...",
        source: "IMSS, 2025."
    )
}
