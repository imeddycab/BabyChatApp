//
//  AuthManager.swift
//  BabyChat
//
//  Created by eduardo caballero on 28/03/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    struct User {
        let uid: String
        let email: String?
        let firstName: String?
        let lastName: String?
    }
    
    private var db = Firestore.firestore()
    
    init() {
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
            
            if let user = result?.user {
                self?.fetchUserData(uid: user.uid)
                completion(true, nil)
            }
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                completion(false, "Error al crear el usuario")
                return
            }
            
            let userData = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ] as [String : Any]
            
            self?.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error guardando datos del usuario: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    self?.fetchUserData(uid: user.uid)
                    completion(true, nil)
                }
            }
        }
    }
    
    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error obteniendo datos del usuario: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()
                let firstName = data?["firstName"] as? String
                let lastName = data?["lastName"] as? String
                let email = data?["email"] as? String
                
                self.currentUser = User(uid: uid, email: email, firstName: firstName, lastName: lastName)
                self.isAuthenticated = true
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
    
    // Métodos para autenticación con redes sociales (opcional)
    func signInWithGoogle(completion: @escaping (Bool, String?) -> Void) {
        // Implementar lógica para Google Sign-In
    }
    
    func signInWithApple(completion: @escaping (Bool, String?) -> Void) {
        // Implementar lógica para Apple Sign-In
    }
}
