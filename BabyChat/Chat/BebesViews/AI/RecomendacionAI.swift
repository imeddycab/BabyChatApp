//
//  RecomendacionAI.swift
//  BabyChat
//
//  Created by eduardo caballero on 24/03/25.
//

import SwiftUI

struct RecomendacionAIView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Análisis de")
                            .padding(.horizontal, 10)
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Text("Ethan")
                            .padding(.horizontal, -13)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    // Título principal
                    Text("Resultado del análisis:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Descripción
                    Text("He análizado la información registrada de Ethan y he detectado que tiene un desarrollo considerablemente deficiente ya que su estatura está por debajo de lo normal para su edad. Esto se ve afectado por su peso registrado, que está por debajo de lo normal para su estatura.\n\n")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Datos usados
                    Text("Se utlizaron los siguientes datos para el análisis: estatura (cm), peso (kg) y edad.\n\n")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                        .background(Color.white)
                    
                    // Fuente
                    Text("Recuerda que este análisis es una recomendación general generada por un modelo de IA y no un diagnóstico médico. Visita a tu médico para un diagnóstico preciso.")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(20)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8), Color.blue, Color.blue.opacity(0.6), Color.blue.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing).blur(radius: 20))
                .cornerRadius(25)
                .padding(20)
            }
        }
        .navigationBarHidden(true) // Oculta la barra de navegación
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    RecomendacionAIView()
}
