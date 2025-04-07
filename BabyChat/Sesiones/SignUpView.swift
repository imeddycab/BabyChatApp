//
//  SignUpView.swift
//  BabyChat
//
//  Created by eduardo caballero on 25/03/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var onSignUpSuccess: () -> Void
    var onNavigateToLogin: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("¡Únete a BabyChat! 🎉")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Crea tu cuenta en minutos")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
                
                // Campos del formulario
                HStack(spacing: 15) {
                    TextField("Nombres", text: $firstName)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    TextField("Apellidos", text: $lastName)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 25)
                
                VStack(spacing: 15) {
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
                    
                    SecureField("Contraseña", text: $password)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 25)
                
                // Botón de registro
                if isLoading {
                    ProgressView()
                        .padding(.top, 20)
                } else {
                    Button(action: {
                        validateRegistration()
                    }) {
                        Text("Registrarse")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(30)
                            .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
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
                .padding(.vertical, 10)
                .padding(.horizontal, 25)
                
                // Botones de redes sociales
                HStack(spacing: 20) {
                    Button(action: {
                        // Registro con Apple
                        simulateSocialSignUp()
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
                        // Registro con Google
                        simulateSocialSignUp()
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
                
                // Enlace a login
                HStack {
                    Text("¿Ya tienes una cuenta?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        onNavigateToLogin()
                    }) {
                        Text("¡Inicia sesión!")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 20)
                
                // Términos y condiciones
                VStack(spacing: 5) {
                    Text("Al crear una cuenta en BabyChat aceptas los")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            showingTerms = true
                        }) {
                            Text("Términos y Condiciones")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        Text(" y ")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Button(action: {
                            showingPrivacy = true
                        }) {
                            Text("Política de Privacidad")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 10)
                .sheet(isPresented: $showingTerms) {
                    WebView(url: URL(string: "https://ejemplo.com/terminos")!)
                }
                .sheet(isPresented: $showingPrivacy) {
                    WebView(url: URL(string: "https://ejemplo.com/privacidad")!)
                }
            }
            .padding(.vertical)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func validateRegistration() {
        guard !firstName.isEmpty else {
            alertMessage = "Por favor ingresa tu nombre"
            showingAlert = true
            return
        }
        
        guard !lastName.isEmpty else {
            alertMessage = "Por favor ingresa tu apellido"
            showingAlert = true
            return
        }
        
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
            alertMessage = "Por favor ingresa una contraseña"
            showingAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "La contraseña debe tener al menos 6 caracteres"
            showingAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Las contraseñas no coinciden"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        AuthManager.shared.register(
            nombres: firstName,
            primerApellido: lastName,
            email: email,
            password: password
        ) { success, errorMessage in
            isLoading = false
            if success {
                onSignUpSuccess()
            } else {
                alertMessage = errorMessage ?? "Error al registrar el usuario"
                showingAlert = true
            }
        }
    }

    private func simulateSocialSignUp() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onSignUpSuccess()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(onSignUpSuccess: {}, onNavigateToLogin: {})
    }
}
