//
//  PesoRegistro.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct PesoRegistro: Identifiable, Codable {
    var id = UUID()
    var fecha: String
    var peso: String
    var pesoValue: Double
}

struct PesoTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    var babyName: String
    
    @State private var pesoActual: String = "10"
    @State private var registros: [PesoRegistro] = []
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var registroParaEditar: PesoRegistro?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Peso de \(babyName)")
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
            
            // Contenido principal
            VStack(spacing: 10) {
                // Tarjeta de peso actual
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("El peso de \(babyName) está en:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text("\(pesoActual) kg")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding()
                }
                .background(Color.blue.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: Color.white.opacity(0.05), radius: 2)
                
                // Lista de registros
                ScrollView {
                    VStack {
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
                                    
                                    Text("\(registro.peso) kg")
                                        .font(.system(size: 14))
                                        .frame(width: 55, alignment: .leading)
                                    
                                    Divider().frame(height: 60)
                                    
                                    Button(action: {
                                        registroParaEditar = registro
                                        showEditSheet = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 45, alignment: .center)
                                    
                                    Divider().frame(height: 60)
                                    
                                    Button(action: {
                                        withAnimation {
                                            registros.removeAll { $0.id == registro.id }
                                            saveRegistros()
                                        }
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
        .onAppear {
            loadRegistros()
            updateCurrentWeight()
        }
        .sheet(isPresented: $showAddSheet) {
            AddPesoSheet(registros: $registros, onSave: {
                saveRegistros()
                updateCurrentWeight()
            })
        }
        .sheet(item: $registroParaEditar) { registro in
            EditPesoSheet(registro: registro, onSave: { updatedRegistro in
                if let index = registros.firstIndex(where: { $0.id == updatedRegistro.id }) {
                    registros[index] = updatedRegistro
                    saveRegistros()
                    updateCurrentWeight()
                }
            })
        }
    }
    
    private func updateCurrentWeight() {
        pesoActual = registros.first?.peso ?? "0"
    }
    
    private func saveRegistros() {
        if let encoded = try? JSONEncoder().encode(registros) {
            UserDefaults.standard.set(encoded, forKey: "pesoRegistros_\(babyName)")
        }
    }
    
    private func loadRegistros() {
        if let data = UserDefaults.standard.data(forKey: "pesoRegistros_\(babyName)"),
           let decoded = try? JSONDecoder().decode([PesoRegistro].self, from: data) {
            registros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            // Datos de ejemplo si no hay registros
            registros = [
                PesoRegistro(fecha: "12/04/24", peso: "11.7", pesoValue: 11.7),
                PesoRegistro(fecha: "03/02/24", peso: "10.5", pesoValue: 10.5)
            ]
        }
    }
}

// Vista para añadir nuevo registro
struct AddPesoSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var registros: [PesoRegistro]
    var onSave: () -> Void
    
    @State private var fecha = Date()
    @State private var peso: String = ""
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Agregar Registro de Peso")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
            
            TextField("Peso (kg)", text: $peso)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Guardar") {
                if !peso.isEmpty, let value = Double(peso) {
                    let newRegistro = PesoRegistro(
                        fecha: dateFormatter.string(from: fecha),
                        peso: peso,
                        pesoValue: value
                    )
                    registros.append(newRegistro)
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

// Vista para editar registro
struct EditPesoSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var registro: PesoRegistro
    var onSave: (PesoRegistro) -> Void
    
    @State private var fecha: Date
    @State private var peso: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    init(registro: PesoRegistro, onSave: @escaping (PesoRegistro) -> Void) {
        self.registro = registro
        self.onSave = onSave
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        _fecha = State(initialValue: formatter.date(from: registro.fecha) ?? Date())
        _peso = State(initialValue: registro.peso)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Editar Registro")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
            
            TextField("Peso (kg)", text: $peso)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Guardar Cambios") {
                if !peso.isEmpty, let value = Double(peso) {
                    let updatedRegistro = PesoRegistro(
                        id: registro.id,
                        fecha: dateFormatter.string(from: fecha),
                        peso: peso,
                        pesoValue: value
                    )
                    onSave(updatedRegistro)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

struct PesoTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        PesoTrackerView( babyName: "Ethan")
    }
}
