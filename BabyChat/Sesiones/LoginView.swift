//
//  LoginView.swift
//  BabyChat
//
//  Created by eduardo caballero on 25/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var onLoginSuccess: () -> Void
    var onNavigateToSignUp: () -> Void
    
    var body: some View {
        VStack {
            // Header
            VStack(spacing: 10) {
                Text("¡Bienvenido a BabyChat!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("👋")
                    .font(.system(size: 40))
                    .padding(.bottom, 5)
            }
            .padding(.bottom, 20)
            
            // Formulario
            VStack(spacing: 15) {
                Text("Inicia sesión para continuar:")
                    .foregroundColor(.gray)
                
                TextField("Correo electrónico", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                SecureField("Ingresa tu contraseña", text: $password)
                    .autocapitalization(.none)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 25)
            
            // Botón de inicio de sesión
            if isLoading {
                ProgressView()
                    .padding(.top, 20)
            } else {
                Button(action: {
                    validateCredentials()
                }) {
                    Text("Iniciar sesión")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
            }
            
            // Divisor
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                
                Text("Ó")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 25)
            
            // Botones de redes sociales
            HStack(spacing: 20) {
                Button(action: {
                    // Login con Apple
                    simulateSocialLogin()
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color.black)
                        .cornerRadius(30)
                }
                
                Button(action: {
                    // Login con Google
                    simulateSocialLogin()
                }) {
                    Image("google-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(Color.black)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Enlace a registro
            HStack {
                Text("¿No tienes una cuenta?")
                    .foregroundColor(.gray)
                
                Button(action: {
                    onNavigateToSignUp()
                }) {
                    Text("¡Regístrate!")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func validateCredentials() {
        guard !email.isEmpty else {
            alertMessage = "Por favor ingresa tu correo electrónico"
            showingAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            alertMessage = "Por favor ingresa un correo electrónico válido"
            showingAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertMessage = "Por favor ingresa tu contraseña"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        AuthManager.shared.login(email: email, password: password) { success, errorMessage in
            isLoading = false
            if success {
                onLoginSuccess()
            } else {
                alertMessage = errorMessage ?? "Credenciales incorrectas. Por favor intenta nuevamente."
                showingAlert = true
            }
        }
    }

    private func simulateSocialLogin() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onLoginSuccess()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onLoginSuccess: {}, onNavigateToSignUp: {})
    }
}
