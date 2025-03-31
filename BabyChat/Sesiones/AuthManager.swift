//
//  AuthManager.swift
//  BabyChat
//
//  Created by eduardo caballero on 28/03/25.
//

import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // Credenciales de ejemplo y usuarios registrados
    private var registeredUsers: [User] = [
        User(email: "eddy@mail.com", password: "password123", firstName: "Eddy", lastName: "Caballero"),
        User(email: "emily@mail.com", password: "emily123", firstName: "Emily", lastName: "Smith")
    ]
    
    struct User {
        let email: String
        let password: String
        let firstName: String
        let lastName: String
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let user = self.registeredUsers.first(where: { $0.email == email && $0.password == password }) {
                self.currentUser = user
                self.isAuthenticated = true
                completion(true)
            } else {
                self.isAuthenticated = false
                completion(false)
            }
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard !self.registeredUsers.contains(where: { $0.email == email }) else {
                completion(false)
                return
            }
            
            let newUser = User(email: email, password: password, firstName: firstName, lastName: lastName)
            self.registeredUsers.append(newUser)
            self.currentUser = newUser
            self.isAuthenticated = true
            completion(true)
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
}
