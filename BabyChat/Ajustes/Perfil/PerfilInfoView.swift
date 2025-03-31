//
//  PerfilInfoView.swift
//  BabyChat
//
//  Created by eduardo caballero on 24/03/25.
//

import SwiftUI

enum Gender: String, CaseIterable {
    case female = "Femenino"
    case male = "Masculino"
    case unspecified = "No especificado"
}

struct PerfilInfoView: View {
    @Environment(\.presentationMode) var presentationMode
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
    
    var accountDetails: [(String, String)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return [
            ("Nombres", editedName),
            ("Primer apellido", editedLastName),
            ("Segundo apellido", editedSecondLastName),
            ("Fecha de nacimiento", dateFormatter.string(from: editedBirthDate)),
            ("Género", editedGender.rawValue),
            ("Email", "e***@***.com")
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
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .background(Color(.orange).opacity(0.1).blur(radius: 100))
                    .presentationCornerRadius(30)
                }
                
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
                                    HStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                        Text("Así se verá tu foto de perfil.")
                                            .foregroundColor(.gray)
                                    }
                                    Text("¿Otra foto?")
                                        .foregroundColor(.purple)
                                } else {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.purple)
                                        Text("Seleccionar Foto")
                                            .foregroundColor(.purple)
                                    }
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PerfilInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilInfoView()
    }
}
