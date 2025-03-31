//
//  CambiarMonitorView.swift
//  BabyChat
//
//  Created by eduardo caballero on 20/03/25.
//

import SwiftUI

struct CambiarMonitorView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedBaby = "Ethan" // Bebé seleccionado por defecto
    @State private var babies = ["Ethan", "Liam", "Emma", "Sophia"] // Lista de bebés
    
    // Datos de los bebés y sus monitores
    @State private var babyMonitors: [String: (isEncendido: Bool, isDesvincular: Bool, isRestaurar: Bool, cantidadMonitores: Int)] = [
        "Ethan": (true, false, false, 1),
        "Liam": (false, false, false, 2),
        "Emma": (true, true, false, 1),
        "Sophia": (false, false, true, 3)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Cabecera con selector y botón de cerrar
                HStack {
                    Menu {
                        ForEach(babies, id: \.self) { baby in
                            Button(action: {
                                selectedBaby = baby // Cambiar bebé seleccionado
                            }) {
                                Text(baby)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedBaby) // Muestra el bebé seleccionado
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Capsule().fill(Color(.systemGray6)))
                    }
                    
                    Spacer()
                    
                    // Botón de añadir
                    Button(action: {
                        // Acción de añadir
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Botón para cerrar la vista
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Contenido principal
                if let monitor = babyMonitors[selectedBaby] {
                    // Sección del BabyMonitor
                    VStack(alignment: .leading, spacing: 8) {
                        // Título del monitor
                        Text("BabyMonitor")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        // Opción Encendido
                        HStack {
                            Text("Encendido")
                                .fontWeight(.medium)
                            Toggle("", isOn: Binding(
                                get: { monitor.isEncendido },
                                set: { newValue in
                                    babyMonitors[selectedBaby]?.isEncendido = newValue
                                }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        }
                        .padding(.horizontal, 20)
                        
                        // Opción Desvincular
                        HStack {
                            Text("Desvincular")
                                .fontWeight(.medium)
                            Toggle("", isOn: Binding(
                                get: { monitor.isDesvincular },
                                set: { newValue in
                                    babyMonitors[selectedBaby]?.isDesvincular = newValue
                                }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        }
                        .padding(.horizontal, 20)
                        
                        // Opción Restaurar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Restaurar")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                Toggle("", isOn: Binding(
                                    get: { monitor.isRestaurar },
                                    set: { newValue in
                                        babyMonitors[selectedBaby]?.isRestaurar = newValue
                                    }
                                ))
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
                        
                        Divider()
                        
                        // Cantidad de monitores
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cantidad de monitores")
                                .fontWeight(.medium)
                            
                            Text("Este bebé tiene \(monitor.cantidadMonitores) monitor(es) asociado(s).")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CambiarMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        CambiarMonitorView()
    }
}
