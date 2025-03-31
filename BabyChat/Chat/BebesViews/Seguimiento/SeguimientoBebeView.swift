//
//  SeguimientoBebeView.swift
//  BabyChat
//
//  Created by eduardo caballero on 20/03/25.
//

import SwiftUI

struct SeguimientoBebeView: View {
    @Environment(\.presentationMode) var presentationMode
    var babyName: String
    var babyProfile: (peso: String, estatura: String, imc: String)
    var babyImage: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tarjeta de perfil del bebé
                    VStack(alignment: .leading, spacing: 15) {
                        Text("\(babyName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                InfoRowView(label: "Peso", value: babyProfile.peso)
                                InfoRowView(label: "Estatura", value: babyProfile.estatura)
                                InfoRowView(label: "IMC", value: babyProfile.imc)
                            }
                            
                            Spacer()
                            
                            Image("\(babyImage)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    
                    // Sección de seguimiento
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Seguimiento")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Gráficos de seguimiento
                        VStack(spacing: 15) {
                            TrackingCard(title: "Peso", value: babyProfile.peso, icon: "scalemass.fill", color: .blue)
                            
                            TrackingCard(title: "Estatura", value: babyProfile.estatura, icon: "ruler.fill", color: .green)
                            
                            TrackingCard(title: "IMC", value: babyProfile.imc, icon: "chart.bar.fill", color: .orange)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Seguimiento de \(babyName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct TrackingCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Gráfico circular simple sin SVG
            ZStack {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SeguimientoBebeView_Previews: PreviewProvider {
    static var previews: some View {
        SeguimientoBebeView(
            babyName: "Ethan",
            babyProfile: ("1.6 kg", "41 cm", "10"), babyImage: "baby1"
        )
    }
}
