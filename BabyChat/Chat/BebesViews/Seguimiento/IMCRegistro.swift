//
//  IMCRegistro.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct IMCRegistro: Identifiable, Codable {
    var id = UUID()
    var fecha: String
    var imc: String
    var imcValue: Double
}

struct IMCTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    var babyName: String
    
    @State private var imcActual: String = "15"
    @State private var registros: [IMCRegistro] = []
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var registroParaEditar: IMCRegistro?
    
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
                        Text("IMC de \(babyName)")
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
                // Tarjeta de IMC actual
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("El IMC de \(babyName) está en:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(imcActual)
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
                            
                            Text("IMC")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 50, alignment: .leading)
                            
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
                                    
                                    Text(registro.imc)
                                        .font(.system(size: 14))
                                        .frame(width: 50, alignment: .leading)
                                    
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
            updateCurrentIMC()
        }
        .sheet(isPresented: $showAddSheet) {
            AddIMCSheet(registros: $registros, onSave: {
                saveRegistros()
                updateCurrentIMC()
            })
            .background(Color(.blue).opacity(0.3).blur(radius: 100))
            .presentationCornerRadius(30)
            .presentationDetents([.fraction(0.3)])
        }
        .sheet(item: $registroParaEditar) { registro in
            EditIMCSheet(registro: registro, onSave: { updatedRegistro in
                if let index = registros.firstIndex(where: { $0.id == updatedRegistro.id }) {
                    registros[index] = updatedRegistro
                    saveRegistros()
                    updateCurrentIMC()
                }
            })
            .background(Color(.orange).opacity(0.3).blur(radius: 100))
            .presentationCornerRadius(30)
            .presentationDetents([.fraction(0.3)])
        }
    }
    
    private func updateCurrentIMC() {
        imcActual = registros.first?.imc ?? "0"
    }
    
    private func saveRegistros() {
        if let encoded = try? JSONEncoder().encode(registros) {
            UserDefaults.standard.set(encoded, forKey: "imcRegistros_\(babyName)")
        }
    }
    
    private func loadRegistros() {
        if let data = UserDefaults.standard.data(forKey: "imcRegistros_\(babyName)"),
           let decoded = try? JSONDecoder().decode([IMCRegistro].self, from: data) {
            registros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            // Datos de ejemplo si no hay registros
            registros = [
                IMCRegistro(fecha: "12/04/24", imc: "16.1", imcValue: 16.1),
                IMCRegistro(fecha: "03/02/24", imc: "14.9", imcValue: 14.9)
            ]
        }
    }
}

// Vista para añadir nuevo registro
struct AddIMCSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var registros: [IMCRegistro]
    var onSave: () -> Void
    
    @State private var fecha = Date()
    @State private var imc: String = ""
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Agregar Registro de IMC")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
            
            HStack {
                Text("IMC:")
                
                TextField("IMC", text: $imc)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(20)
                    .keyboardType(.decimalPad)
                
                Button("Guardar") {
                    if !imc.isEmpty, let value = Double(imc) {
                        let newRegistro = IMCRegistro(
                            fecha: dateFormatter.string(from: fecha),
                            imc: imc,
                            imcValue: value
                        )
                        registros.append(newRegistro)
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(25)
            }
        }
        .padding(.horizontal)
    }
}

// Vista para editar registro
struct EditIMCSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var registro: IMCRegistro
    var onSave: (IMCRegistro) -> Void
    
    @State private var fecha: Date
    @State private var imc: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    init(registro: IMCRegistro, onSave: @escaping (IMCRegistro) -> Void) {
        self.registro = registro
        self.onSave = onSave
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        _fecha = State(initialValue: formatter.date(from: registro.fecha) ?? Date())
        _imc = State(initialValue: registro.imc)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Editar Registro")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
            
            HStack {
                Text("IMC:")
                
                TextField("IMC", text: $imc)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(20)
                    .keyboardType(.decimalPad)
                
                Button("Actualizar") {
                    if !imc.isEmpty, let value = Double(imc) {
                        let updatedRegistro = IMCRegistro(
                            id: registro.id,
                            fecha: dateFormatter.string(from: fecha),
                            imc: imc,
                            imcValue: value
                        )
                        onSave(updatedRegistro)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(25)
            }
        }
        .padding(.horizontal)
    }
}

struct IMCTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        IMCTrackerView(babyName: "Ethan")
    }
}
