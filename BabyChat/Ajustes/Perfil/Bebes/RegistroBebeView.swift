//
//  RegistroBebeView.swift
//  BabyChat
//
//  Created by eduardo caballero on 07/04/25.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct RegistroBebeView: View {
    @Environment(\.presentationMode) var bbPresentationMode
    @State private var bbSelectedImage: UIImage?
    @State private var bbBabyName = ""
    @State private var bbLastName = ""
    @State private var bbSecondLastName = ""
    @State private var bbNickname = ""
    @State private var bbBirthDate = Date()
    @State private var bbGender: Gender = .male
    @State private var bbDisabilityNotes = ""
    @State private var bbAllergyNotes = ""
    @State private var bbDiseaseNotes = ""
    @State private var bbShowImagePicker = false
    @State private var bbIsSaving = false
    @State private var bbShowAlert = false
    @State private var bbAlertMessage = ""
    
    var bbOnSaveComplete: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    Button(action: {
                        bbShowImagePicker = true
                    }) {
                        HStack {
                            Spacer()
                            VStack {
                                if let image = bbSelectedImage {
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
                }, header: {
                    Text("Foto de Perfil")
                })
                
                Section(content: {
                    TextField("Nombres", text: $bbBabyName)
                    TextField("Primer Apellido", text: $bbLastName)
                    TextField("Segundo Apellido (opcional)", text: $bbSecondLastName)
                    TextField("Apodo (opcional)", text: $bbNickname)
                    
                    DatePicker("Fecha de Nacimiento", selection: $bbBirthDate, displayedComponents: .date)
                    
                    Picker("Género", selection: $bbGender) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            Text(genderOption.rawValue).tag(genderOption)
                        }
                    }
                }, header: {
                    Text("Datos Personales")
                })
                
                Section(content: {
                    TextField("Discapacidades (opcional)", text: $bbDisabilityNotes)
                    TextField("Alergias (opcional)", text: $bbAllergyNotes)
                    TextField("Enfermedades (opcional)", text: $bbDiseaseNotes)
                }, header: {
                    Text("Información Adicional")
                })
            }
            .navigationTitle("Registrar Nuevo Bebé")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    bbPresentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.gray),
                trailing: Button("Guardar") {
                    saveBabyToFirebase()
                }
                .foregroundColor(.purple)
                .disabled(bbBabyName.isEmpty || bbLastName.isEmpty || bbIsSaving)
            )
            .sheet(isPresented: $bbShowImagePicker) {
                ImagePicker(selectedImage: $bbSelectedImage)
            }
            .alert(isPresented: $bbShowAlert) {
                Alert(title: Text("Registro de bebé"), message: Text(bbAlertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveBabyToFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            bbAlertMessage = "No se pudo identificar al usuario"
            bbShowAlert = true
            return
        }
        
        bbIsSaving = true
        
        // Formatear la fecha de nacimiento
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let birthDateString = dateFormatter.string(from: bbBirthDate)
        
        // Convertir imagen a base64 si existe
        var photoBase64 = ""
        if let image = bbSelectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            photoBase64 = imageData.base64EncodedString()
        }
        
        // Crear diccionario con los datos del bebé
        let babyData: [String: Any] = [
            "nombres": bbBabyName,
            "primer_apellido": bbLastName,
            "segundo_apellido": bbSecondLastName,
            "apodo": bbNickname,
            "nacimiento": birthDateString,
            "genero": bbGender == .male ? "M" : "F",
            "discapacidad": bbDisabilityNotes,
            "alergias": bbAllergyNotes,
            "enfermedades": bbDiseaseNotes,
            "fotoperfil": photoBase64,
            "babymonitor": [
                "sn_monitor": "",
                "firmware_version": 1,
                "seguimiento": [
                    "tiemporeal_sensores": [
                        "temperatura": ["fechahora": "", "registro": 0],
                        "humedad": ["fechahora": "", "registro": 0],
                        "gases": ["fechahora": "", "registro": 0]
                    ],
                    "historial_sensores": [
                        "temperatura": [:],
                        "humedad": [:],
                        "gases": [:]
                    ]
                ]
            ]
        ]
        
        // Referencia a la base de datos
        let ref = Database.database().reference()
        let babyRef = ref.child("usuarios").child(userId).child("bebes").childByAutoId()
        
        // Guardar datos
        babyRef.setValue(babyData) { error, _ in
            bbIsSaving = false
            if let error = error {
                bbAlertMessage = "Error al guardar: \(error.localizedDescription)"
                bbShowAlert = true
            } else {
                bbAlertMessage = "Bebé registrado exitosamente"
                bbShowAlert = true
                bbOnSaveComplete()
                bbPresentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct RegistroBebeView_Previews: PreviewProvider {
    static var previews: some View {
        RegistroBebeView(bbOnSaveComplete: {})
    }
}
