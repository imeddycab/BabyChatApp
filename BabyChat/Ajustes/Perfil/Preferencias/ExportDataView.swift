//
//  ExportDataView.swift
//  BabyChat
//
//  Created by eduardo caballero on 25/03/25.
//


import SwiftUI

struct ExportDataView: View {
    @State private var selectedBaby = "Ethan"
    @State private var babies = ["Ethan", "Sofia", "Lucas"]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 10) {
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Exportar datos")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Descriptive Text
                    Text("Puede exportar los datos de los bebés que agregó a su cuenta para compartirlos con sus contactos de confianza.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Baby Selection Dropdown
                    VStack(alignment: .leading) {
                        Text("Elija el perfil del bebé que quiera exportar:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(babies, id: \.self) { baby in
                                Button(baby) {
                                    selectedBaby = baby
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedBaby)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Text("Exportará el perfil completo del bebé que haya seleccionado")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Export Details
                    VStack(alignment: .leading, spacing: 10) {
                        Text("La exportación incluye:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ExportDetailRow(text: "Información personal del bebé")
                            ExportDetailRow(text: "Información personal del tutor que registró el perfil")
                            ExportDetailRow(text: "Estadísticas de datos de seguimiento (peso, estatura, etc.)")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Share Button
                    Button(action: {
                        // Handle data export
                    }) {
                        Text("Compartir datos")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ExportDetailRow: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.purple)
                .frame(width: 8, height: 8)
                .offset(y: 6)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ExportDataView_Previews: PreviewProvider {
    static var previews: some View {
        ExportDataView()
    }
}
