//
//  AjustesView.swift
//  BabyChat
//
//  Created by eduardo caballero on 19/03/25.
//

import SwiftUI

struct AjustesView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedBaby: String? = nil
    @State private var viewBaby = false
    @State private var bbShowAddBabySheet = false
    @State private var showNotifications = false
    @State private var showExportData = false
    @State private var showAppInfo = false
    var onLogout: () -> Void
    
    // URLs para las secciones
    private let helpURL = URL(string: "https://babychat.com/ayuda")!
    private let privacyURL = URL(string: "https://babychat.com/privacidad")!
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Encabezado
                Text("¡Hola, \(authManager.currentUser?.nombres ?? "Usuario")!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.purple)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                VStack(spacing: 20) {
                    // Sección de perfil
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cuenta")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        HStack {
                            Text("Ver perfil")
                                .padding()
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            NavigationLink(destination: PerfilInfoView().environmentObject(AuthManager.shared)) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(.purple)
                                    .padding(.horizontal)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        .padding(.horizontal, 20)
                    }
                    
                    // Sección de bebés
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bebés")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(authManager.babies, id: \.id) { baby in
                                BabyItem(
                                    baby: baby, // Pasar el objeto Baby completo
                                    isSelected: selectedBaby == baby.id,
                                    action: {
                                        selectedBaby = baby.id
                                    }
                                )
                            }
                            
                            Button(action: {
                                bbShowAddBabySheet = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Agregar bebé")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.purple))
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            .sheet(isPresented: $bbShowAddBabySheet) {
                                RegistroBebeView(bbOnSaveComplete: {
                                    // Actualizar la lista de bebés después de agregar uno nuevo
                                    if let uid = authManager.currentUser?.uid {
                                        authManager.fetchUserBabies(uid: uid)
                                    }
                                })
                                .presentationCornerRadius(30)
                            }
                        }
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        .padding(.horizontal, 20)
                    }
                    
                    // Sección de preferencias
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferencias")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Notificaciones
                            Button(action: {
                                showNotifications = true
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text("Notificaciones")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("→")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.purple))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                            }
                            .sheet(isPresented: $showNotifications) {
                                NotificationsView()
                                    .presentationCornerRadius(30)
                                    .padding(.vertical)
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Exportar datos
                            Button(action: {
                                showExportData = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text("Exportar datos")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("→")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.purple))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                            }
                            .sheet(isPresented: $showExportData) {
                                ExportDataView()
                                    .presentationCornerRadius(30)
                                    .padding(.vertical)
                                    .ignoresSafeArea(.all)
                            }
                        }
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        .padding(.horizontal, 20)
                    }
                    
                    // Sección Acerca de BabyChat
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Acerca de BabyChat")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Ayuda y comentarios
                            Button(action: {
                                UIApplication.shared.open(helpURL)
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text("Ayuda y comentarios")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("→")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.purple))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Privacidad y legal
                            Button(action: {
                                UIApplication.shared.open(privacyURL)
                            }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text("Privacidad y legal")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("→")
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.purple))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Información de la app
                            Button(action: {
                                showAppInfo = true
                            }) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 20)
                                    
                                    Text("Información de la app")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Circle().fill(Color.purple))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                            }
                            .sheet(isPresented: $showAppInfo) {
                                AppInfoView()
                                    .presentationCornerRadius(30)
                                    .presentationDetents([.medium])
                                    .clipShape(RoundedRectangle(cornerRadius: 35))
                                    .background(Color(.purple).opacity(0.1).blur(radius: 100))
                            }
                        }
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        .padding(.horizontal, 20)
                    }
                    
                    // Botón de cerrar sesión
                    Button(action: {
                        onLogout()
                    }) {
                        Text("Cerrar sesión")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 150)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                    .padding(.top, 10)
                    
                    // Footer
                    HStack {
                        Text("Made by")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("The BabyChat Team")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top, 20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .padding(.bottom, 90)
        }
    }
}

// Vista de información de la app
struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            // Icono de la app (cuadro gris)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .overlay(
                    Image("AppIconAll")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.purple)
                )
                .padding(.top, 30)
            
            Text("BabyChat")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Versión app: 1.0")
                .font(.headline)
                .padding(.top, 10)
            
            Text("2025 BabyChat")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("Cerrar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

// Componente para elemento de bebé
struct BabyItem: View {
    var baby: AuthManager.Baby // Cambiar para recibir el objeto Baby completo
    var isSelected: Bool
    var action: () -> Void
    @State private var viewBaby = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(baby.nombres) // Mostrar el nombre del bebé
                    .font(.subheadline)
                
                Spacer()
                
                HStack(spacing: 15) {
                    // Botón para ver el perfil del bebé
                    Button(action: {
                        viewBaby = true
                    }) {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(isSelected ? Color.purple.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $viewBaby) {
            BebeInfoView(baby: baby) // Pasar el objeto Baby a BebeInfoView
                .presentationCornerRadius(30)
        }
    }
}

// Preview
struct AjustesView_Previews: PreviewProvider {
    static var previews: some View {
        AjustesView(onLogout: {})
    }
}
