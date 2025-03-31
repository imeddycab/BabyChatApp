//
//  MonitorConfigView.swift
//  BabyChat
//
//  Created by eduardo caballero on 20/03/25.
//

import SwiftUI

struct MonitorConfigView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isEncendido = true
    @State private var isDesvincular = false
    @State private var isRestaurar = false
    
    var body: some View {
        VStack(spacing: 0){
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.green)
                        Text("Monitor de Ethan")
                            .padding(.horizontal, 10)
                            .foregroundColor(.black)
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
            
            ScrollView{
                // Contenido principal
                VStack(alignment: .leading, spacing: 10) {
                    // Sección del BabyMonitor
                    VStack(alignment: .leading, spacing: 8) {
                        // Título del monitor
                        Text("Cuna - BabyMonitor")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        // Opción Encendido
                        HStack {
                            Text("Encendido")
                                .fontWeight(.medium)
                            Toggle("", isOn: $isEncendido)
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        }
                        .padding(.horizontal, 20)
                        
                        // Opción Desvincular
                        HStack {
                            Text("Desvincular")
                                .fontWeight(.medium)
                            Toggle("", isOn: $isDesvincular)
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        }
                        .padding(.horizontal, 20)

                        // Opción Restaurar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Restaurar")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                Toggle("", isOn: $isRestaurar)
                                    .toggleStyle(SwitchToggleStyle(tint: Color.red))
                            }
                            
                            Text("Esta acción apagará el BabyMonitor y se iniciará con sus valores de fábrica, lo cual significa que para seguir utilizando el dispositivo deberá volver a vincularlo.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                        
                        // Sección de información
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Acerca del monitor")
                                .fontWeight(.medium)
                            
                            Text("Versión de firmware: 0.012")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("No. de serie: BM-0001")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Actualizar")
                                    .foregroundColor(.green)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("Versión actualizada")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(radius: 2)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // Botón conectar
                HStack {
                    Button(action: {
                        // Acción para conectar
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 28, height: 28)
                                .cornerRadius(20)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Text("Conectar BabyMonitor")
                        .foregroundColor(.gray)
                        .font(.callout)
                }
                .padding(.horizontal, 0)
                .padding(.top, 8)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
}

struct MonitorConfigView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorConfigView()
    }
}
