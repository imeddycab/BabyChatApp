//
//  AuthManager.swift
//  BabyChat
//
//  Created by eduardo caballero on 28/03/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // Propiedad para bebés
    @Published var babies: [Baby] = []
    
    // Estructura para padres
    struct User {
        let uid: String
        let email: String?
        let nombres: String?
        let primerApellido: String?
        let segundoApellido: String?
        let fechaNacimiento: Date?
        let genero: String?
        let rol: String
        let fechaCreacion: Date?
        let fotoPerfil: String?
    }
    
    // Estructura para bebés
    struct Baby {
        let id: String
        let nombres: String
        let primerApellido: String
        let segundoApellido: String
        let apodo: String?
        let genero: String
        let nacimiento: String
        let discapacidad: String
        let alergias: String
        let enfermedades: String
        let fotoperfil: String?
        var seguimiento: (peso: [(date: String, value: String)], estatura: [(date: String, value: String)], imc: [(date: String, value: String)])?
    }
    
    private var dbRef: DatabaseReference
    private var userDataHandle: DatabaseHandle?
    
    init() {
        self.dbRef = Database.database().reference()
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if let user = user {
                self?.fetchUserData(uid: user.uid)
            } else {
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                completion(false, "No se pudo obtener información del usuario")
                return
            }
            
            self?.fetchUserData(uid: user.uid)
            completion(true, nil)
        }
    }
    
    func register(nombres: String, primerApellido: String, segundoApellido: String = "", email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                completion(false, "Error al crear el usuario en Authentication")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let fechaCreacionString = dateFormatter.string(from: Date())
            
            let userData: [String: Any] = [
                "nombres": nombres,
                "primer_apellido": primerApellido,
                "segundo_apellido": segundoApellido,
                "email": email,
                "rol": "padre",
                "creacion": fechaCreacionString,
                "genero": "",
                "nacimiento": "",
                "fotoperfil": ""
            ]
            
            self?.dbRef.child("usuarios").child(user.uid).setValue(userData) { error, _ in
                if let error = error {
                    user.delete { _ in }
                    completion(false, "Error al guardar en Realtime Database: \(error.localizedDescription)")
                } else {
                    self?.fetchUserData(uid: user.uid)
                    completion(true, nil)
                }
            }
        }
    }
    
    func fetchUserData(uid: String) {
        // Eliminar cualquier observador previo
        if let handle = userDataHandle {
            dbRef.child("usuarios").child(uid).removeObserver(withHandle: handle)
        }
        
        // Observar cambios en tiempo real
        userDataHandle = dbRef.child("usuarios").child(uid).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                self.createBasicUserRecord(uid: uid)
                return
            }
            
            // Cambiar el manejo de fecha de creación
            let fechaCreacionString = value["creacion"] as? String ?? ""
            let fechaCreacion = self.dateFromString(fechaCreacionString) ?? Date()
            
            // Extraer los campos con nuevo formato
            let segundoApellido = value["segundo_apellido"] as? String ?? ""
            
            // Manejar género como "M" o "F"
            let genero = value["genero"] as? String ?? ""
            
            // Manejar fecha de nacimiento como string "dd-MM-yyyy"
            let fechaNacimientoString = value["nacimiento"] as? String ?? ""
            let fechaNacimiento = self.dateFromString(fechaNacimientoString)
            
            let fotoPerfil = value["fotoperfil"] as? String
            
            DispatchQueue.main.async {
                self.currentUser = User(
                    uid: uid,
                    email: value["email"] as? String,
                    nombres: value["nombres"] as? String,
                    primerApellido: value["primer_apellido"] as? String,
                    segundoApellido: segundoApellido,
                    fechaNacimiento: fechaNacimiento,
                    genero: genero,
                    rol: value["rol"] as? String ?? "padre",
                    fechaCreacion: fechaCreacion,
                    fotoPerfil: fotoPerfil
                )
                
                self.isAuthenticated = true
                self.fetchUserBabies(uid: uid)
            }
        }
    }
    
    func fetchUserBabies(uid: String) {
        dbRef.child("usuarios").child(uid).child("bebes").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var fetchedBabies: [Baby] = []
            let group = DispatchGroup() // Para manejar múltiples llamadas asíncronas
            
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let value = snapshot.value as? [String: Any] else {
                    continue
                }
                
                var baby = Baby(
                    id: snapshot.key,
                    nombres: value["nombres"] as? String ?? "",
                    primerApellido: value["primer_apellido"] as? String ?? "",
                    segundoApellido: value["segundo_apellido"] as? String ?? "",
                    apodo: value["apodo"] as? String,
                    genero: value["genero"] as? String ?? "",
                    nacimiento: value["nacimiento"] as? String ?? "",
                    discapacidad: value["discapacidad"] as? String ?? "",
                    alergias: value["alergias"] as? String ?? "",
                    enfermedades: value["enfermedades"] as? String ?? "",
                    fotoperfil: value["fotoperfil"] as? String,
                    seguimiento: nil // Inicialmente nil
                )
                
                group.enter()
                self.loadSeguimiento(for: baby) { updatedBaby in
                    baby = updatedBaby
                    fetchedBabies.append(baby)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.babies = fetchedBabies
                NotificationCenter.default.post(name: .babiesUpdated, object: nil)
            }
        }
    }

    private func loadSeguimiento(for baby: Baby, completion: @escaping (Baby) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(baby)
            return
        }
        
        dbRef.child("usuarios").child(uid).child("bebes").child(baby.id).child("seguimiento")
            .observeSingleEvent(of: .value) { snapshot in
                var updatedBaby = baby
                
                if snapshot.exists(), let seguimientoDict = snapshot.value as? [String: Any] {
                    let pesoData = self.processFirebaseData(seguimientoDict["peso"] as? [String: String])
                    let estaturaData = self.processFirebaseData(seguimientoDict["estatura"] as? [String: String])
                    let imcData = self.processFirebaseData(seguimientoDict["imc"] as? [String: String])
                    
                    updatedBaby.seguimiento = (
                        peso: pesoData,
                        estatura: estaturaData,
                        imc: imcData
                    )
                }
                
                completion(updatedBaby)
            }
    }

    private func processFirebaseData(_ data: [String: String]?) -> [(date: String, value: String)] {
        guard let data = data else { return [] }
        return data.map { (date: $0.key, value: $0.value) }.sorted { $0.date > $1.date }
    }
    
    // Método auxiliar para convertir string a Date
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    private func createBasicUserRecord(uid: String) {
        guard let currentAuthUser = Auth.auth().currentUser else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let fechaCreacionString = dateFormatter.string(from: Date())
        
        let userData: [String: Any] = [
            "nombres": "",
            "primer_apellido": "",
            "segundo_apellido": "",
            "email": currentAuthUser.email ?? "",
            "rol": "padre",
            "genero": "",
            "nacimiento": "",
            "creacion": fechaCreacionString,
            "fotoperfil": ""
        ]
        
        dbRef.child("usuarios").child(uid).setValue(userData) { [weak self] error, _ in
            if error == nil {
                self?.fetchUserData(uid: uid)
            }
        }
    }
    
    func cleanupObservers() {
        if let handle = userDataHandle, let uid = currentUser?.uid {
            dbRef.child("usuarios").child(uid).removeObserver(withHandle: handle)
            userDataHandle = nil
        }
    }
    
    func logout() {
        cleanupObservers()
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    deinit {
        cleanupObservers()
        print("AuthManager se está liberando de memoria")
    }
}

extension Notification.Name {
    static let babiesUpdated = Notification.Name("BabiesUpdatedNotification")
}
