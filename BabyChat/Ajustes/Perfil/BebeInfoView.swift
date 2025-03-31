//
//  BebeInfoView.swift
//  BabyChat
//

import SwiftUI

struct BebeInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showClearBabyChatsConfirmation = false
    @State private var showDeleteTheBabyConfirmation = false
    @State private var showEditProfileSheet = false
    @State private var selectedImage: UIImage?
    
    // Datos editables
    @State private var babyName = "Ethan"
    @State private var lastName = "Islas"
    @State private var secondLastName = "-"
    @State private var birthDate = Date()
    @State private var gender: Gender = .male
    @State private var disabilityNotes = ""
    @State private var allergyNotes = ""
    @State private var diseaseNotes = ""
    
    // Valores originales para restaurar al cancelar
    @State private var originalImage: UIImage?
    @State private var originalName = "Ethan"
    @State private var originalLastName = "Islas"
    @State private var originalSecondLastName = "-"
    @State private var originalBirthDate = Date()
    @State private var originalGender: Gender = .male
    @State private var originalDisabilityNotes = ""
    @State private var originalAllergyNotes = ""
    @State private var originalDiseaseNotes = ""
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: birthDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Encabezado
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.purple)
                        Text("Perfil de \(babyName)")
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
                
                // Botón de edición
                Button(action: {
                    // Guardar valores actuales antes de editar
                    originalImage = selectedImage
                    originalName = babyName
                    originalLastName = lastName
                    originalSecondLastName = secondLastName
                    originalBirthDate = birthDate
                    originalGender = gender
                    originalDisabilityNotes = disabilityNotes
                    originalAllergyNotes = allergyNotes
                    originalDiseaseNotes = diseaseNotes
                    
                    showEditProfileSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showEditProfileSheet) {
                    EditBabyProfileView(
                        isPresented: $showEditProfileSheet,
                        selectedImage: $selectedImage,
                        babyName: $babyName,
                        lastName: $lastName,
                        secondLastName: $secondLastName,
                        birthDate: $birthDate,
                        gender: $gender,
                        disabilityNotes: $disabilityNotes,
                        allergyNotes: $allergyNotes,
                        diseaseNotes: $diseaseNotes,
                        originalImage: $originalImage,
                        originalName: $originalName,
                        originalLastName: $originalLastName,
                        originalSecondLastName: $originalSecondLastName,
                        originalBirthDate: $originalBirthDate,
                        originalGender: $originalGender,
                        originalDisabilityNotes: $originalDisabilityNotes,
                        originalAllergyNotes: $originalAllergyNotes,
                        originalDiseaseNotes: $originalDiseaseNotes
                    )
                }
                
                // Foto de perfil del bebé
                Image(systemName: selectedImage == nil ? "person.fill" : "")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .overlay(
                        selectedImage.map { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        }
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Sección Personal
                    Group {
                        Text("Personal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        InfoRow(label: "Nombres", value: babyName)
                        Divider()
                        
                        InfoRow(label: "Primer apellido", value: lastName)
                        Divider()
                        
                        InfoRow(label: "Segundo apellido", value: secondLastName)
                        Divider()
                        
                        InfoRow(label: "Fecha de nacimiento", value: formattedBirthDate)
                        Divider()
                        
                        InfoRow(label: "Género", value: gender.rawValue)
                        Divider()
                    }
                    
                    // Sección Adicionales opcionales (solo lectura)
                    Text("Adicionales opcionales")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                    
                    Group {
                        Text("Discapacidad")
                            .font(.caption)
                            .foregroundStyle(.primary)
                        
                        Text(disabilityNotes.isEmpty ? "No especificado" : disabilityNotes)
                            .foregroundColor(disabilityNotes.isEmpty ? .gray : .primary)
                        Divider()
                    }
                    
                    // Sección Alergias (solo lectura)
                    Group {
                        Text("Alergias")
                            .font(.caption)
                            .foregroundStyle(.primary)
                        
                        Text(allergyNotes.isEmpty ? "No especificado" : allergyNotes)
                            .foregroundColor(allergyNotes.isEmpty ? .gray : .primary)
                        Divider()
                    }
                    
                    // Sección Enfermedades (solo lectura)
                    Group {
                        Text("Enfermedades")
                            .font(.caption)
                            .foregroundStyle(.primary)
                        
                        Text(diseaseNotes.isEmpty ? "No especificado" : diseaseNotes)
                            .foregroundColor(diseaseNotes.isEmpty ? .gray : .primary)
                        Divider()
                    }
                    
                    // Sección Preferencias
                    Group {
                        Text("Preferencias")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            showClearBabyChatsConfirmation = true
                        }) {
                            HStack {
                                Text("Vaciar chats del perfil")
                                    .foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        Text("Esta acción no puede deshacerse, usted eliminará los chats relacionados al bebé.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        Button(action: {
                            showDeleteTheBabyConfirmation = true
                        }) {
                            HStack {
                                Text("Eliminar bebé")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        Text("Esta acción no puede deshacerse, usted eliminará el bebé registrado y todos los datos relacionados (peso, imc, chats, etc.).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                }
                .padding(20)
                .background(Color.gray.opacity(0.09))
                .cornerRadius(25)
                .padding(20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showClearBabyChatsConfirmation) {
            ClearBabyChatsConfirmationView(isPresented: $showClearBabyChatsConfirmation)
                .presentationDetents([.medium])
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .background(Color(.orange).opacity(0.1).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showDeleteTheBabyConfirmation) {
            DeleteTheBabieConfirmationView(isPresented: $showDeleteTheBabyConfirmation)
                .presentationDetents([.medium])
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .background(Color(.red).opacity(0.1).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .onAppear {
            // Inicializar la fecha con la fecha original
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            if let date = formatter.date(from: "18-10-2024") {
                birthDate = date
                originalBirthDate = date
            }
        }
    }
}

struct ClearBabyChatsConfirmationView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿En serio quieres hacerlo?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Recuerda que esta acción no se puede deshacer.")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Eliminará los chats relacionados con este bebé, presiona Vaciar para eliminar tu historial de chats.")
                .font(.body)
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Vaciar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(25)
                }
                
                Text("O cancela esta acción.")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancelar")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(25)
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 25)
    }
}

struct DeleteTheBabieConfirmationView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿En serio quieres hacerlo?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Recuerda que esta acción no se puede deshacer.")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Se eliminará a este bebé de BabyChat, presiona Borrar para continuar y eliminar su perfil.")
                .font(.body)
                .foregroundColor(.black)
            
            VStack(spacing: 10) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Borrar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(25)
                }
                
                Text("O cancela esta acción.")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancelar")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(25)
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 25)
    }
}

// Vista de edición del perfil del bebé
struct EditBabyProfileView: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var babyName: String
    @Binding var lastName: String
    @Binding var secondLastName: String
    @Binding var birthDate: Date
    @Binding var gender: Gender
    @Binding var disabilityNotes: String
    @Binding var allergyNotes: String
    @Binding var diseaseNotes: String
    
    // Valores originales para restaurar
    @Binding var originalImage: UIImage?
    @Binding var originalName: String
    @Binding var originalLastName: String
    @Binding var originalSecondLastName: String
    @Binding var originalBirthDate: Date
    @Binding var originalGender: Gender
    @Binding var originalDisabilityNotes: String
    @Binding var originalAllergyNotes: String
    @Binding var originalDiseaseNotes: String
    
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Foto de Perfil")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Spacer()
                            VStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                    Text("Cambiar foto")
                                        .foregroundColor(.purple)
                                } else {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.purple)
                                    Text("Agregar foto")
                                        .foregroundColor(.purple)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Datos Personales")) {
                    TextField("Nombres", text: $babyName)
                    TextField("Primer Apellido", text: $lastName)
                    TextField("Segundo Apellido", text: $secondLastName)
                    
                    DatePicker("Fecha de Nacimiento", selection: $birthDate, displayedComponents: .date)
                    
                    Picker("Género", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            Text(genderOption.rawValue).tag(genderOption)
                        }
                    }
                }
                
                Section(header: Text("Discapacidades")) {
                    TextField("Notas sobre discapacidad", text: $disabilityNotes)
                }
                
                Section(header: Text("Alergias")) {
                    TextField("Notas sobre alergias", text: $allergyNotes)
                }
                
                Section(header: Text("Enfermedades")) {
                    TextField("Notas sobre enfermedades", text: $diseaseNotes)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    // Restaurar valores originales
                    selectedImage = originalImage
                    babyName = originalName
                    lastName = originalLastName
                    secondLastName = originalSecondLastName
                    birthDate = originalBirthDate
                    gender = originalGender
                    disabilityNotes = originalDisabilityNotes
                    allergyNotes = originalAllergyNotes
                    diseaseNotes = originalDiseaseNotes
                    
                    isPresented = false
                }
                .foregroundColor(.gray),
                trailing: Button("Guardar") {
                    isPresented = false
                }
                .foregroundColor(.purple)
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

// Componente para mostrar información en filas
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.purple)
        }
    }
}

struct BebeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BebeInfoView()
    }
}
