//
//  EstaturaRegistro.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct EstaturaRegistro: Identifiable {
    var id = UUID()
    var fecha: String
    var estatura: String
    var estaturaValue: Double
}

struct EstaturaTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var estaturaActual: String = "100"
    @State private var registros: [EstaturaRegistro] = [
        EstaturaRegistro(fecha: "12/04/24", estatura: "189", estaturaValue: 11.7),
        EstaturaRegistro(fecha: "03/02/24", estatura: "70", estaturaValue: 10.5),
        EstaturaRegistro(fecha: "20/12/23", estatura: "63", estaturaValue: 9.3),
        EstaturaRegistro(fecha: "11/11/23", estatura: "40", estaturaValue: 8.05)
    ]
    
    @State private var showAddSheet = false
    @State private var showEditSheet = false
    @State private var registroParaEditar: EstaturaRegistro?
    
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
                        Text("Estatura de Ethan")
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
                // Sección de estatura actual
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("La estatura de Ethan esta en un rango de:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(estaturaActual + " cm")
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
                                    
                                    Text(registro.estatura + " cm")
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
            AddEstaturaSheet(registros: $registros)
                .background(Color(.blue).opacity(0.3).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .sheet(item: $registroParaEditar) { registro in
            EditEstaturaSheet(registros: $registros, registro: registro)
                .background(Color(.orange).opacity(0.3).blur(radius: 100))
                .presentationCornerRadius(30)
        }
    }
}

struct AddEstaturaSheet: View {
    @Binding var registros: [EstaturaRegistro]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fecha = Date()
    @State private var estatura: String = ""
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        Text("Agregar Nuevo Registro")
            .font(.title2)
            .fontWeight(.bold)
        
        VStack(spacing: 20) {
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
            
            TextField("Estatura, solo números", text: $estatura)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .cornerRadius(20)
                .padding(.horizontal)
            
            Button("Guardar") {
                if let estaturaValue = Double(estatura) {
                    let formattedDate = dateFormatter.string(from: fecha)
                    registros.append(EstaturaRegistro(fecha: formattedDate, estatura: estatura, estaturaValue: estaturaValue))
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(25)
        }
        .padding(10)
        .cornerRadius(20)
        .padding(20)
    }
}

struct EditEstaturaSheet: View {
    @Binding var registros: [EstaturaRegistro]
    var registro: EstaturaRegistro
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fecha: Date
    @State private var estatura: String
    
    init(registros: Binding<[EstaturaRegistro]>, registro: EstaturaRegistro) {
        self._registros = registros
        self.registro = registro
        _fecha = State(initialValue: Date())
        _estatura = State(initialValue: registro.estatura)
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        Text("Editar Registro")
            .font(.title2)
            .fontWeight(.bold)
        
        VStack(spacing: 20) {
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
            
            TextField("Estatura, solo números", text: $estatura)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .cornerRadius(20)
                .padding(.horizontal)
            
            Button("Guardar Cambios") {
                if let index = registros.firstIndex(where: { $0.id == registro.id }) {
                    let formattedDate = dateFormatter.string(from: fecha)
                    registros[index] = EstaturaRegistro(id: registro.id, fecha: formattedDate, estatura: estatura, estaturaValue: Double(estatura) ?? 0.0)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(25)
        }
        .padding(10)
        .cornerRadius(20)
        .padding(20)
    }
}


struct EstaturaTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        EstaturaTrackerView()
    }
}
