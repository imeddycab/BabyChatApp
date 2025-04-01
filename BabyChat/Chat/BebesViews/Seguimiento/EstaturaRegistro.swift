//
//  EstaturaRegistro.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct EstaturaRegistro: Identifiable, Codable {
    var id = UUID()
    var fecha: String
    var estatura: String
    var estaturaValue: Double
}

struct EstaturaTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    var babyName: String
    
    @State private var estaturaActual: String = "100"
    @State private var registros: [EstaturaRegistro] = []
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var registroParaEditar: EstaturaRegistro?
    
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
                        Text("Estatura de \(babyName)")
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
                // Tarjeta de estatura actual
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("La estatura de \(babyName) está en:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text("\(estaturaActual) cm")
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
                            
                            Text("Estatura")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 60, alignment: .leading)
                            
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
                                    
                                    Text("\(registro.estatura) cm")
                                        .font(.system(size: 14))
                                        .frame(width: 60, alignment: .leading)
                                    
                                    Divider().frame(height: 50)
                                    
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
            updateCurrentHeight()
        }
        .sheet(isPresented: $showAddSheet) {
            AddEstaturaSheet(registros: $registros, onSave: {
                saveRegistros()
                updateCurrentHeight()
            })
            .background(Color(.blue).opacity(0.3).blur(radius: 100))
            .presentationCornerRadius(30)
            .presentationDetents([.fraction(0.3)])
        }
        .sheet(item: $registroParaEditar) { registro in
            EditEstaturaSheet(registro: registro, onSave: { updatedRegistro in
                if let index = registros.firstIndex(where: { $0.id == updatedRegistro.id }) {
                    registros[index] = updatedRegistro
                    saveRegistros()
                    updateCurrentHeight()
                }
            })
            .background(Color(.orange).opacity(0.3).blur(radius: 100))
            .presentationCornerRadius(30)
            .presentationDetents([.fraction(0.3)])
        }
    }
    
    private func updateCurrentHeight() {
        estaturaActual = registros.first?.estatura ?? "0"
    }
    
    private func saveRegistros() {
        if let encoded = try? JSONEncoder().encode(registros) {
            UserDefaults.standard.set(encoded, forKey: "estaturaRegistros_\(babyName)")
        }
    }
    
    private func loadRegistros() {
        if let data = UserDefaults.standard.data(forKey: "estaturaRegistros_\(babyName)"),
           let decoded = try? JSONDecoder().decode([EstaturaRegistro].self, from: data) {
            registros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            // Datos de ejemplo si no hay registros
            registros = [
                EstaturaRegistro(fecha: "12/04/24", estatura: "189", estaturaValue: 189),
                EstaturaRegistro(fecha: "03/02/24", estatura: "70", estaturaValue: 70)
            ]
        }
    }
}

// Vista para añadir nuevo registro
struct AddEstaturaSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var registros: [EstaturaRegistro]
    var onSave: () -> Void
    
    @State private var fecha = Date()
    @State private var estatura: String = ""
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Agregar Registro de Estatura")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
            
            HStack {
                Text("Estatura:")

                TextField("cm", text: $estatura)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(20)
                    .keyboardType(.decimalPad)
                
                Button("Guardar") {
                    if !estatura.isEmpty, let value = Double(estatura) {
                        let newRegistro = EstaturaRegistro(
                            fecha: dateFormatter.string(from: fecha),
                            estatura: estatura,
                            estaturaValue: value
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
struct EditEstaturaSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var registro: EstaturaRegistro
    var onSave: (EstaturaRegistro) -> Void
    
    @State private var fecha: Date
    @State private var estatura: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    init(registro: EstaturaRegistro, onSave: @escaping (EstaturaRegistro) -> Void) {
        self.registro = registro
        self.onSave = onSave
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        _fecha = State(initialValue: formatter.date(from: registro.fecha) ?? Date())
        _estatura = State(initialValue: registro.estatura)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Editar Registro")
                .font(.title2)
                .fontWeight(.bold)
            
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                
            HStack {
                Text("Estatura:")
                
                TextField("cm", text: $estatura)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(20)
                    .keyboardType(.decimalPad)
                
                Button("Actualizar") {
                    if !estatura.isEmpty, let value = Double(estatura) {
                        let updatedRegistro = EstaturaRegistro(
                            id: registro.id,
                            fecha: dateFormatter.string(from: fecha),
                            estatura: estatura,
                            estaturaValue: value
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

struct EstaturaTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        EstaturaTrackerView( babyName: "Ethan")
    }
}
