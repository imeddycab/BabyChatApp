//
//  InicioView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

struct InicioView: View {
    @StateObject private var readingsManager = ReadingsManager.shared
    
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

                if readingsManager.isLoading {
                    ProgressView()
                } else if readingsManager.cards.isEmpty {
                    Text("No hay tarjetas disponibles")
                        .foregroundColor(.gray)
                } else {
                    ForEach(readingsManager.cards, id: \.uid) { card in
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
//                ScrollView {
//                    AdminView()
//                }
            }
            .padding(.bottom, 90)
        }
        .navigationBarHidden(true)
        .onAppear {
            readingsManager.fetchReadings()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

//struct AdminView: View {
//    @ObservedObject var manager = ReadingsManager.shared
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("Forzar Carga y Subida") {
//                manager.forceLoadAndUpload()
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            Button("Verificar Datos") {
//                manager.fetchReadings()
//                alertMessage = "\(manager.cards.count) tarjetas cargadas"
//                showAlert = true
//            }
//            .padding()
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            if manager.isLoading {
//                ProgressView()
//                    .padding()
//            }
//        }
//        .padding()
//        .alert("Estado", isPresented: $showAlert) {
//            Button("OK") {}
//        } message: {
//            Text(alertMessage)
//        }
//    }
//}


#Preview {
    InicioView()
}
