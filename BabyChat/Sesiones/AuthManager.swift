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
            
            let userData: [String: Any] = [
                "nombres": nombres,
                "primer_apellido": primerApellido,
                "segundo_apellido": segundoApellido,
                "email": email,
                "rol": "padre",
                "creacion": ServerValue.timestamp(),
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
    
    private func fetchUserData(uid: String) {
        // Eliminar cualquier observador previo
        if let handle = userDataHandle {
            dbRef.child("usuarios").child(uid).removeObserver(withHandle: handle)
        }
        
        // Observar cambios en tiempo real
        userDataHandle = dbRef.child("usuarios").child(uid).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            // Verificar si el snapshot existe y tiene datos
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                // Si no existe, creamos un registro básico
                self.createBasicUserRecord(uid: uid)
                return
            }
            
            let timestamp = value["creacion"] as? TimeInterval ?? 0
            let fechaCreacion = Date(timeIntervalSince1970: timestamp / 1000)
            
            // Extraer los campos
            let segundoApellido = value["segundo_apellido"] as? String ?? ""
            let genero = value["genero"] as? String ?? "No especificado"
            let fechaNacimientoTimestamp = value["nacimiento"] as? TimeInterval ?? 0
            let fechaNacimiento = fechaNacimientoTimestamp > 0 ? Date(timeIntervalSince1970: fechaNacimientoTimestamp) : nil
            
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
                    fechaCreacion: fechaCreacion
                )
                
                self.isAuthenticated = true
            }
        }
    }
    
    private func createBasicUserRecord(uid: String) {
        guard let currentAuthUser = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "nombres": "",
            "primer_apellido": "",
            "segundo_apellido": "",
            "email": currentAuthUser.email ?? "",
            "rol": "padre",
            "genero": "No especificado",
            "nacimiento": 0,
            "creacion": ServerValue.timestamp()
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
