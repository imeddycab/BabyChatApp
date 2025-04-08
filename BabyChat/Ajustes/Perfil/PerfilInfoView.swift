//
//  PerfilInfoView.swift
//  BabyChat
//
//  Created by eduardo caballero on 24/03/25.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct PerfilInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @State private var showEditProfileSheet = false
    @State private var showClearChatsConfirmation = false
    @State private var showDeleteBabiesConfirmation = false
    @State private var showCloseAccountConfirmation = false
    @State private var selectedImage: UIImage?
    @State private var editedName = "Emily"
    @State private var editedLastName = "Islas"
    @State private var editedSecondLastName = "-"
    @State private var editedBirthDate = Date()
    @State private var editedGender: Gender = .female
    
    // Inicializador para establecer los valores iniciales
    init() {
        let authManager = AuthManager.shared
        _editedName = State(initialValue: authManager.currentUser?.nombres ?? "")
        _editedLastName = State(initialValue: authManager.currentUser?.primerApellido ?? "")
        _editedSecondLastName = State(initialValue: authManager.currentUser?.segundoApellido ?? "")
        
        // Manejar fecha de nacimiento
        if let fechaNacimiento = authManager.currentUser?.fechaNacimiento {
            _editedBirthDate = State(initialValue: fechaNacimiento)
        } else {
            _editedBirthDate = State(initialValue: Date())
        }
        
        // Manejar género (convertir "M" o "F" a enum Gender)
        if let genero = authManager.currentUser?.genero {
            _editedGender = State(initialValue: genero == "M" ? .male : .female)
        } else {
            _editedGender = State(initialValue: .unspecified)
        }
    }
    
    var accountDetails: [(String, String)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return [
            ("Nombres", editedName),
            ("Primer apellido", editedLastName),
            ("Segundo apellido", editedSecondLastName),
            ("Fecha de nacimiento", dateFormatter.string(from: editedBirthDate)),
            ("Género", editedGender.rawValue),
            ("Email", authManager.currentUser?.email?.maskedEmail() ?? "No disponible")
        ]
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
                        Text("Cuenta de \(editedName)")
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
                    EditProfileView(
                        isPresented: $showEditProfileSheet,
                        selectedImage: $selectedImage,
                        editedName: $editedName,
                        editedLastName: $editedLastName,
                        editedSecondLastName: $editedSecondLastName,
                        editedBirthDate: $editedBirthDate,
                        editedGender: $editedGender
                    )
                    .environmentObject(authManager)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .background(Color(.orange).opacity(0.1).blur(radius: 100))
                    .presentationCornerRadius(30)
                }
                
                if let fotoBase64 = authManager.currentUser?.fotoPerfil,
                   let imageData = Data(base64Encoded: fotoBase64),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // Lista dinámica
                    Text("Personal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(accountDetails, id: \.0) { (label, value) in
                        HStack {
                            Text(label)
                                .foregroundColor(.black)
                            Spacer()
                            Text(value)
                                .foregroundColor(.purple)
                        }
                        Divider()
                    }
                    
                    // Sección de acciones
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Preferencias")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button(action: {
                            showClearChatsConfirmation = true
                        }) {
                            HStack {
                                Text("Vaciar chats")
                                    .foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        Text("Esta acción no puede deshacerse, usted eliminará los chats almacenados en su cuenta.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        Button(action: {
                            showDeleteBabiesConfirmation = true
                        }) {
                            HStack {
                                Text("Eliminar bebés registrados")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        Text("Esta acción no puede deshacerse, usted eliminará los bebés registrados y todos los datos relacionados (peso, imc, vacunas, etc.).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        Button(action: {
                            showCloseAccountConfirmation = true
                        }) {
                            HStack {
                                Text("Cerrar cuenta")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        Text("Esta acción no puede deshacerse, ya que, eliminará los bebés registrados, todos los datos relacionados (peso, imc, vacunas, etc.), el historial de chats y su cuenta será dada de baja por lo que no tendrá acceso a ella.")
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
        // Hojas de confirmación
        .sheet(isPresented: $showClearChatsConfirmation) {
            ClearChatsConfirmationView(isPresented: $showClearChatsConfirmation)
                .presentationDetents([.medium])
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .background(Color(.orange).opacity(0.1).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showDeleteBabiesConfirmation) {
            DeleteBabiesConfirmationView(isPresented: $showDeleteBabiesConfirmation)
                .presentationDetents([.medium])
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .background(Color(.red).opacity(0.1).blur(radius: 100))
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showCloseAccountConfirmation) {
            CloseAccountConfirmationView(isPresented: $showCloseAccountConfirmation)
                .presentationDetents([.fraction(0.65)])
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .background(Color(.red).opacity(0.1).blur(radius: 50))
                .presentationCornerRadius(30)
        }
    }
}

// MARK: - Vistas de Confirmación

struct ClearChatsConfirmationView: View {
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
            
            Text("Eliminará todo rastro de los chats que haya tenido en BabyChat, presiona Vaciar para eliminar tu historial de chats.")
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

struct DeleteBabiesConfirmationView: View {
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
            
            Text("Se eliminarán todos los bebés que registraste en BabyChat, presiona Borrar para continuar y eliminar sus perfiles.")
                .font(.body)
                .foregroundColor(.gray)
            
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

struct CloseAccountConfirmationView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿En serio quieres hacerlo?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Recuerda que después de esta acción no podremos recuperar tus datos y no puedes cancelar el proceso.")
                .font(.caption)
                .foregroundColor(.red)
            
            Text("Necesitas tu cuenta para continuar utilizando BabyChat. Si presionas Cerrar, confirmas la eliminación de tu perfil y la información almacenada.")
                .font(.body)
                .foregroundColor(.black)
            
            VStack(spacing: 10) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cerrar")
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

struct EditProfileView: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var editedName: String
    @Binding var editedLastName: String
    @Binding var editedSecondLastName: String
    @Binding var editedBirthDate: Date
    @Binding var editedGender: Gender
    
    @State private var originalImage: UIImage?
    @State private var originalName: String
    @State private var originalLastName: String
    @State private var originalSecondLastName: String
    @State private var originalBirthDate: Date
    @State private var originalGender: Gender
    
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var authManager: AuthManager
    
    init(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, editedName: Binding<String>, editedLastName: Binding<String>, editedSecondLastName: Binding<String>, editedBirthDate: Binding<Date>, editedGender: Binding<Gender>) {
        self._isPresented = isPresented
        self._selectedImage = selectedImage
        self._editedName = editedName
        self._editedLastName = editedLastName
        self._editedSecondLastName = editedSecondLastName
        self._editedBirthDate = editedBirthDate
        self._editedGender = editedGender
        
        self._originalImage = State(initialValue: selectedImage.wrappedValue)
        self._originalName = State(initialValue: editedName.wrappedValue)
        self._originalLastName = State(initialValue: editedLastName.wrappedValue)
        self._originalSecondLastName = State(initialValue: editedSecondLastName.wrappedValue)
        self._originalBirthDate = State(initialValue: editedBirthDate.wrappedValue)
        self._originalGender = State(initialValue: editedGender.wrappedValue)
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
                                        .scaledToFill()
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
                    TextField("Nombres", text: $editedName)
                    TextField("Primer Apellido", text: $editedLastName)
                    TextField("Segundo Apellido", text: $editedSecondLastName)
                    DatePicker("Fecha de Nacimiento", selection: $editedBirthDate, displayedComponents: .date)
                    
                    Picker("Género", selection: $editedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Cambiar Contraseña")) {
                    SecureField("Nueva Contraseña", text: $newPassword)
                    SecureField("Confirmar Contraseña", text: $confirmPassword)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    selectedImage = originalImage
                    editedName = originalName
                    editedLastName = originalLastName
                    editedSecondLastName = originalSecondLastName
                    editedBirthDate = originalBirthDate
                    editedGender = originalGender
                    isPresented = false
                }
                .foregroundColor(.gray),
                trailing: Button("Guardar") {
                    saveProfileChanges()
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
    
    private func saveProfileChanges() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "No se pudo identificar al usuario"
            showAlert = true
            return
        }
        
        isSaving = true
        
        // Convertir imagen a base64 si existe
        var photoBase64 = ""
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            photoBase64 = imageData.base64EncodedString()
        }
        
        // Formatear fecha de nacimiento como "dd-MM-yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let birthDateString = dateFormatter.string(from: editedBirthDate)
        
        // Formatear género como "M" o "F"
        let genero = editedGender == .male ? "M" : "F"
        
        // Crear diccionario con los datos actualizados
        var updatedData: [String: Any] = [
            "nombres": editedName,
            "primer_apellido": editedLastName,
            "segundo_apellido": editedSecondLastName,
            "genero": genero,
            "nacimiento": birthDateString
        ]
        
        // Solo actualizar la foto si se seleccionó una nueva
        if !photoBase64.isEmpty {
            updatedData["fotoperfil"] = photoBase64
        }
        
        // Actualizar contraseña si se proporcionó y coincide
        if !newPassword.isEmpty {
            if newPassword == confirmPassword {
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        alertMessage = "Error al actualizar contraseña: \(error.localizedDescription)"
                        showAlert = true
                        isSaving = false
                        return
                    }
                }
            } else {
                alertMessage = "Las contraseñas no coinciden"
                showAlert = true
                isSaving = false
                return
            }
        }
        
        // Referencia a la base de datos
        let ref = Database.database().reference()
        let userRef = ref.child("usuarios").child(userId)
        
        // Guardar datos
        userRef.updateChildValues(updatedData) { error, _ in
            isSaving = false
            if let error = error {
                alertMessage = "Error al guardar: \(error.localizedDescription)"
                showAlert = true
            } else {
                // Actualizar el authManager para reflejar los cambios
                authManager.fetchUserData(uid: userId)
                alertMessage = "Perfil actualizado exitosamente"
                showAlert = true
                isPresented = false
            }
        }
    }
}

// Extensión para enmascarar el email
extension String {
    func maskedEmail() -> String {
        guard self.contains("@") else { return self }
        let components = self.components(separatedBy: "@")
        guard components.count == 2 else { return self }
        
        let username = components[0]
        let domainComponents = components[1].components(separatedBy: ".")
        
        guard !username.isEmpty, domainComponents.count >= 2 else { return self }
        
        let maskedUsername = String(username.prefix(1)) + "***" + (username.count > 1 ? String(username.suffix(1)) : "")
        let maskedDomain = String(domainComponents[0].prefix(1)) + "***" + "." + domainComponents[1]
        
        return maskedUsername + "@" + maskedDomain
    }
}

struct PerfilInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilInfoView()
    }
}
