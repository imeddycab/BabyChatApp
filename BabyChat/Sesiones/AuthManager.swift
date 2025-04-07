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
        let rol: String
        let fechaCreacion: Date?
    }
    
    private var dbRef: DatabaseReference
    
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
    
    func register(nombres: String, primerApellido: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
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
                "email": email,
                "rol": "padre",
                "creacion": ServerValue.timestamp(),
                "genero": "", // Campos adicionales según tu estructura
                "nacimiento": "",
                "fotoperfil": ""
            ]
            
            // Guardar en Realtime Database
            self?.dbRef.child("usuarios").child(user.uid).setValue(userData) { error, _ in
                if let error = error {
                    // Si falla, eliminamos el usuario creado en Auth para mantener consistencia
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
        dbRef.child("usuarios").child(uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if !snapshot.exists() {
                // Si no existe, creamos un registro básico
                self.createBasicUserRecord(uid: uid)
                return
            }
            
            guard let value = snapshot.value as? [String: Any] else {
                self.isAuthenticated = false
                return
            }
            
            let timestamp = value["creacion"] as? TimeInterval ?? 0
            let fechaCreacion = Date(timeIntervalSince1970: timestamp / 1000)
            
            self.currentUser = User(
                uid: uid,
                email: value["email"] as? String,
                nombres: value["nombres"] as? String,
                primerApellido: value["primer_apellido"] as? String,
                rol: value["rol"] as? String ?? "padre",
                fechaCreacion: fechaCreacion
            )
            
            self.isAuthenticated = true
        }
    }
    
    private func createBasicUserRecord(uid: String) {
        guard let currentAuthUser = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "nombres": "",
            "primer_apellido": "",
            "email": currentAuthUser.email ?? "",
            "rol": "padre",
            "creacion": ServerValue.timestamp()
        ]
        
        dbRef.child("usuarios").child(uid).setValue(userData) { [weak self] error, _ in
            if error == nil {
                self?.fetchUserData(uid: uid)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
