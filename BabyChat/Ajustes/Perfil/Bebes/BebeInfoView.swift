//
//  BebeInfoView.swift
//  BabyChat
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct BebeInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    let baby: AuthManager.Baby // Recibir el objeto Baby
    
    @State private var showClearBabyChatsConfirmation = false
    @State private var showDeleteTheBabyConfirmation = false
    @State private var showEditProfileSheet = false
    @State private var selectedImage: UIImage?
    
    // Datos editables (inicializados con los datos del bebé)
    @State private var babyName: String
    @State private var lastName: String
    @State private var secondLastName: String
    @State private var birthDate: Date
    @State private var gender: Gender
    @State private var disabilityNotes: String
    @State private var allergyNotes: String
    @State private var diseaseNotes: String
    
    // Valores originales para restaurar al cancelar
    @State private var originalImage: UIImage?
    @State private var originalName: String
    @State private var originalLastName: String
    @State private var originalSecondLastName: String
    @State private var originalBirthDate: Date
    @State private var originalGender: Gender
    @State private var originalDisabilityNotes: String
    @State private var originalAllergyNotes: String
    @State private var originalDiseaseNotes: String
    
    // Inicializador para recibir el bebé
    init(baby: AuthManager.Baby) {
        self.baby = baby
        
        // Convertir la fecha de nacimiento de String a Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: baby.nacimiento) ?? Date()
        
        // Convertir el género de String a enum Gender
        let babyGender: Gender = baby.genero == "F" ? .female : .male
        
        // Inicializar los estados con los datos del bebé
        _babyName = State(initialValue: baby.nombres)
        _lastName = State(initialValue: baby.primerApellido)
        _secondLastName = State(initialValue: baby.segundoApellido)
        _birthDate = State(initialValue: date)
        _gender = State(initialValue: babyGender)
        _disabilityNotes = State(initialValue: baby.discapacidad)
        _allergyNotes = State(initialValue: baby.alergias)
        _diseaseNotes = State(initialValue: baby.enfermedades)
        
        // Inicializar los valores originales
        _originalName = State(initialValue: baby.nombres)
        _originalLastName = State(initialValue: baby.primerApellido)
        _originalSecondLastName = State(initialValue: baby.segundoApellido)
        _originalBirthDate = State(initialValue: date)
        _originalGender = State(initialValue: babyGender)
        _originalDisabilityNotes = State(initialValue: baby.discapacidad)
        _originalAllergyNotes = State(initialValue: baby.alergias)
        _originalDiseaseNotes = State(initialValue: baby.enfermedades)
    }
    
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
                        originalDiseaseNotes: $originalDiseaseNotes,
                        babyId: baby.id,
                        userId: Auth.auth().currentUser?.uid ?? ""
                    )
                }
                
                // Foto de perfil del bebé
                if let fotoBase64 = baby.fotoperfil,
                   let imageData = Data(base64Encoded: fotoBase64),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
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
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let babyId: String
    let userId: String
    
    init(
        isPresented: Binding<Bool>,
        selectedImage: Binding<UIImage?>,
        babyName: Binding<String>,
        lastName: Binding<String>,
        secondLastName: Binding<String>,
        birthDate: Binding<Date>,
        gender: Binding<Gender>,
        disabilityNotes: Binding<String>,
        allergyNotes: Binding<String>,
        diseaseNotes: Binding<String>,
        originalImage: Binding<UIImage?>,
        originalName: Binding<String>,
        originalLastName: Binding<String>,
        originalSecondLastName: Binding<String>,
        originalBirthDate: Binding<Date>,
        originalGender: Binding<Gender>,
        originalDisabilityNotes: Binding<String>,
        originalAllergyNotes: Binding<String>,
        originalDiseaseNotes: Binding<String>,
        babyId: String,
        userId: String
    ) {
        self._isPresented = isPresented
        self._selectedImage = selectedImage
        self._babyName = babyName
        self._lastName = lastName
        self._secondLastName = secondLastName
        self._birthDate = birthDate
        self._gender = gender
        self._disabilityNotes = disabilityNotes
        self._allergyNotes = allergyNotes
        self._diseaseNotes = diseaseNotes
        self._originalImage = originalImage
        self._originalName = originalName
        self._originalLastName = originalLastName
        self._originalSecondLastName = originalSecondLastName
        self._originalBirthDate = originalBirthDate
        self._originalGender = originalGender
        self._originalDisabilityNotes = originalDisabilityNotes
        self._originalAllergyNotes = originalAllergyNotes
        self._originalDiseaseNotes = originalDiseaseNotes
        self.babyId = babyId
        self.userId = userId
    }
    
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
                trailing: Group {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") {
                            saveBabyProfileChanges()
                        }
                        .foregroundColor(.purple)
                    }
                }
                .foregroundColor(.purple)
                .disabled(isSaving)
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Edición de perfil"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveBabyProfileChanges() {
        isSaving = true
        
        // Convertir imagen a base64 si existe
        var photoBase64 = ""
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            photoBase64 = imageData.base64EncodedString()
        }
        
        // Formatear fecha de nacimiento como "dd-MM-yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let birthDateString = dateFormatter.string(from: birthDate)
        
        // Formatear género como "M" o "F"
        let genero = gender == .female ? "F" : "M"
        
        // Crear diccionario con los datos actualizados
        let updatedData: [String: Any] = [
            "nombres": babyName,
            "primer_apellido": lastName,
            "segundo_apellido": secondLastName,
            "genero": genero,
            "nacimiento": birthDateString,
            "discapacidad": disabilityNotes,
            "alergias": allergyNotes,
            "enfermedades": diseaseNotes,
            "fotoperfil": photoBase64
        ]
        
        // Referencia a la base de datos
        let ref = Database.database().reference()
        let babyRef = ref.child("usuarios").child(userId).child("bebes").child(babyId)
        
        // Guardar datos
        babyRef.updateChildValues(updatedData) { error, _ in
            isSaving = false
            if let error = error {
                alertMessage = "Error al guardar: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Perfil del bebé actualizado exitosamente"
                showAlert = true
                isPresented = false
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
        let sampleBaby = AuthManager.Baby(
            id: "1",
            nombres: "Ethan",
            primerApellido: "Islas",
            segundoApellido: "Gómez",
            apodo: "Ethy",
            genero: "M",
            nacimiento: "18-10-2024",
            discapacidad: "",
            alergias: "Alergia a la penicilina",
            enfermedades: "",
            fotoperfil: nil
        )
        BebeInfoView(baby: sampleBaby)
    }
}
