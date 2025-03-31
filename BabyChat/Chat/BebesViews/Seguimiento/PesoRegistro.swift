//
//  PesoRegistro.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct PesoRegistro: Identifiable {
    var id = UUID()
    var fecha: String
    var peso: String
    var pesoValue: Double
}

struct PesoTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var pesoActual: String = "10"
    @State private var registros: [PesoRegistro] = [
        PesoRegistro(fecha: "12/04/24", peso: "11.7", pesoValue: 11.7),
        PesoRegistro(fecha: "03/02/24", peso: "10.5", pesoValue: 10.5),
        PesoRegistro(fecha: "20/12/23", peso: "9.30", pesoValue: 9.3),
        PesoRegistro(fecha: "11/11/23", peso: "8.05", pesoValue: 8.05)
    ]
    
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var registroParaEditar: PesoRegistro?
    
    var body: some View {
        VStack(spacing: 0) {
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Peso de Ethan")
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
                
                Button(action: {
                    showAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            

            VStack(spacing: 10) {
                // Sección de peso actual
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("El peso de Ethan esta en\nun rango aproximado a:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(pesoActual +  "kg")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding()
                }
                .background(Color.blue.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: Color.white.opacity(0.05), radius: 2)
                
                // Sección de registros
                ScrollView {
                    VStack() {
                        Text("Registros")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                            .padding(.bottom, 10)
                        
                        // Encabezado de la tabla
                        HStack {
                            Text("Fecha")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 70, alignment: .leading)
                            
                            Divider().frame(height: 30)
                            
                            Text("Peso")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 55, alignment: .leading)
                            
                            Divider().frame(height: 30)
                            
                            Text("Editar")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 45, alignment: .center)
                            
                            Divider().frame(height: 30)
                            
                            Text("Borrar")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 45, alignment: .center)
                        }
                        .padding(.horizontal, 15)
                        .background(Color.white)
                        
                        Divider()
                        
                        // Filas de datos
                        ForEach(registros) { registro in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(registro.fecha)
                                        .font(.system(size: 14))
                                        .frame(width: 70, alignment: .leading)
                                    
                                    Divider().frame(height: 60)
                                    
                                    Text(registro.peso + " kg")
                                        .font(.system(size: 14))
                                        .frame(width: 55, alignment: .leading)
                                    
                                    Divider().frame(height: 60)
                                    
                                    Button(action: {
                                        registroParaEditar = registro
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 45, alignment: .center)
                                    
                                    Divider().frame(height: 60)
                                    
                                    Button(action: {
                                        registros.removeAll { $0.id == registro.id }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                    }
                                    .frame(width: 45, alignment: .center)
                                }
                                .padding(.horizontal, 15)
                                .frame(height: 50)
                                
                                if registros.last?.id != registro.id {
                                    Divider()
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.05), radius: 2)
                }
            }
            .padding(13)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.05), radius: 2)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddSheet) {
            AddPesoSheet(registros: $registros)
                .background(Color(.blue).opacity(0.3).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .sheet(item: $registroParaEditar) { registro in
            EditPesoSheet(registros: $registros, registro: registro)
                .background(Color(.orange).opacity(0.3).blur(radius: 100))
                .presentationCornerRadius(30)
        }
    }
}

struct AddPesoSheet: View {
    @Binding var registros: [PesoRegistro]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fecha = Date()
    @State private var peso: String = ""
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Agregar Nuevo Registro")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
            
            HStack {
                TextField("Peso", text: $peso)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                Button("Guardar") {
                    if let pesoValue = Double(peso) {
                        let formattedDate = dateFormatter.string(from: fecha)
                        registros.append(PesoRegistro(fecha: formattedDate, peso: "\(peso)", pesoValue: pesoValue))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(25)
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(10)
        .cornerRadius(20)
        .padding(20)
    }
}

struct EditPesoSheet: View {
    @Binding var registros: [PesoRegistro]
    var registro: PesoRegistro
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fecha: Date
    @State private var peso: String
    
    init(registros: Binding<[PesoRegistro]>, registro: PesoRegistro) {
        self._registros = registros
        self.registro = registro
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let date = formatter.date(from: registro.fecha) ?? Date()
        
        _fecha = State(initialValue: date)
        
        let pesoString = registro.peso
            .trimmingCharacters(in: .whitespaces)
        
        _peso = State(initialValue: pesoString)
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Editar Registro")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            HStack {
                TextField("Peso", text: $peso)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                Button("Guardar") {
                    if let index = registros.firstIndex(where: { $0.id == registro.id }) {
                        let formattedDate = dateFormatter.string(from: fecha)
                        registros[index] = PesoRegistro(
                            id: registro.id,
                            fecha: formattedDate,
                            peso: "\(peso)",
                            pesoValue: Double(peso) ?? 0.0
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(25)
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(10)
        .cornerRadius(20)
        .padding(20)
    }
}

struct PesoTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        PesoTrackerView()
    }
}
