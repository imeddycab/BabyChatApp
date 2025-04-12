//
//  CambiarBebeView.swift
//  BabyChat
//
//  Created by eduardo caballero on 24/03/25.
//

import SwiftUI
import FirebaseAuth

struct CambiarBebeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedBabyImage: String
    @Binding var selectedBabyName: String
    var onBabyChanged: (() -> Void)?
    
    @StateObject private var authManager = AuthManager.shared
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
                    
                    if authManager.babies.isEmpty {
                        Text("No tienes bebés registrados")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(authManager.babies.indices, id: \.self) { index in
                            let baby = authManager.babies[index]
                            let babyImageName = baby.fotoperfil != nil ? "babyphoto" : "babyphoto"
                            
                            Button(action: {
                                selectedBabyImage = babyImageName
                                selectedBabyName = baby.nombres
                                onBabyChanged?()
                            }) {
                                HStack {
                                    if let fotoBase64 = baby.fotoperfil,
                                       let imageData = Data(base64Encoded: fotoBase64),
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedBabyName == baby.nombres ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                    } else {
                                        Image(babyImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedBabyName == baby.nombres ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(baby.nombres)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            if let seguimiento = baby.seguimiento {
                                                Text("Peso: \(seguimiento.peso.last?.value ?? "N/A") kg")
                                                Text("Estatura: \(seguimiento.estatura.last?.value ?? "N/A") cm")
                                                Text("IMC: \(seguimiento.imc.last?.value ?? "N/A")")
                                            } else {
                                                Text("Sin datos de seguimiento")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedBabyName == baby.nombres {
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
                    
                    if let baby = authManager.babies.first(where: { $0.nombres == selectedBabyName }) {
                        let seguimiento = baby.seguimiento
                        
                        VStack(spacing: 15) {
                            Text("Perfil de \(baby.nombres)")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    if let seguimiento = seguimiento {
                                        Text("Peso: \(seguimiento.peso.last?.value ?? "N/A") kg")
                                        Text("Estatura: \(seguimiento.estatura.last?.value ?? "N/A") cm")
                                        Text("IMC: \(seguimiento.imc.last?.value ?? "N/A")")
                                    } else {
                                        Text("Sin datos de seguimiento")
                                    }
                                }
                                .font(.subheadline)
                                
                                Spacer()
                                
                                if let fotoBase64 = baby.fotoperfil,
                                   let imageData = Data(base64Encoded: fotoBase64),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                } else {
                                    Image("baby_profile")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                }
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
                    if let baby = authManager.babies.first(where: { $0.nombres == selectedBabyName }) {
                        let seguimiento = baby.seguimiento
                        SeguimientoBebeView(
                            babyName: baby.nombres,
                            babyProfile: (
                                seguimiento?.peso.last?.value ?? "N/A",
                                seguimiento?.estatura.last?.value ?? "N/A",
                                seguimiento?.imc.last?.value ?? "N/A"
                            ),
                            babyImage: baby.fotoperfil != nil ? "baby_profile" : "baby1"
                        )
                    }
                default:
                    EmptyView()
                }
            }
            .onAppear {
                if let uid = Auth.auth().currentUser?.uid {
                    authManager.fetchUserBabies(uid: uid)
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
