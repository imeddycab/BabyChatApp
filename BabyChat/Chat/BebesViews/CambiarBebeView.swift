//
//  CambiarBebeView.swift
//  BabyChat
//
//  Created by eduardo caballero on 24/03/25.
//

import SwiftUI

struct BabyProfile: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let peso: String
    let estatura: String
    let imc: String
}

struct CambiarBebeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedBabyImage: String
    @Binding var selectedBabyName: String
    var onBabyChanged: (() -> Void)?
    
    @State private var babies: [BabyProfile] = [
        BabyProfile(name: "Ethan", imageName: "baby1", peso: "1.6 kg", estatura: "41 cm", imc: "10"),
        BabyProfile(name: "Liam", imageName: "baby2", peso: "2.1 kg", estatura: "45 cm", imc: "11"),
        BabyProfile(name: "Emma", imageName: "baby3", peso: "1.8 kg", estatura: "43 cm", imc: "9"),
        BabyProfile(name: "Sofia", imageName: "baby4", peso: "2.0 kg", estatura: "44 cm", imc: "10")
    ]
    
    @State private var navigationPath = NavigationPath()
    
    enum DestinoNavegacion: Hashable {
        case estatura
        case peso
        case imc
        case chatList
        case seguimiento
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Seleccionar Bebé")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        ForEach(babies) { baby in
                            Button(action: {
                                selectedBabyImage = baby.imageName
                                selectedBabyName = baby.name
                                onBabyChanged?()
                            }) {
                                HStack {
                                    Image(baby.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedBabyName == baby.name ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(baby.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            Text("Peso: \(baby.peso)")
                                            Text("Estatura: \(baby.estatura)")
                                            Text("IMC: \(baby.imc)")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedBabyName == baby.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(50)
                            }
                        }
                    }
                    
                    if let baby = babies.first(where: { $0.name == selectedBabyName }) {
                        VStack(spacing: 15) {
                            Text("Perfil de \(baby.name)")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Peso: \(baby.peso)")
                                    Text("Estatura: \(baby.estatura)")
                                    Text("IMC: \(baby.imc)")
                                }
                                .font(.subheadline)
                                
                                Spacer()
                                
                                Image(baby.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                            }
                            
                            NavigationLink(value: DestinoNavegacion.seguimiento) {
                                HStack {
                                    Text("Ver Seguimiento")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(30)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(30)
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(for: DestinoNavegacion.self) { destino in
                switch destino {
                case .seguimiento:
                    if let baby = babies.first(where: { $0.name == selectedBabyName }) {
                        SeguimientoBebeView(
                            babyName: baby.name,
                            babyProfile: (baby.peso, baby.estatura, baby.imc),
                            babyImage: baby.imageName
                        )
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

// Preview
struct CambiarBebeView_Previews: PreviewProvider {
    static var previews: some View {
        CambiarBebeView(
            selectedBabyImage: .constant("baby1"),
            selectedBabyName: .constant("Ethan")
        )
    }
}
