//
//  ContentView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

// Estructura para los ítems de la TabBar
struct TabItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let activeColor: Color
}

// Vista principal que contiene la TabBar
struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab = 0
    @State private var showAuthView = false
    
    let tabItems = [
        TabItem(name: "Inicio", icon: "house.fill", activeColor: .pink),
        TabItem(name: "BabyMonitor", icon: "tv.fill", activeColor: .green),
        TabItem(name: "Chat", icon: "message.fill", activeColor: .blue),
        TabItem(name: "Ajustes", icon: "person.fill", activeColor: .purple)
    ]
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                mainContentView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading))
                    )
                    .zIndex(1)
            }
            
            if !authManager.isAuthenticated {
                AuthTransitionView(showAuthView: $showAuthView)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authManager.isAuthenticated)
    }
    
    private var mainContentView: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    InicioView()
                        .tag(0)
                    
                    MonitorView()
                        .tag(1)
                    
                    ChatView()
                        .tag(2)
                    
                    AjustesView(onLogout: {
                        withAnimation {
                            authManager.logout()
                            showAuthView = true
                        }
                    })
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 50)
                    .blur(radius:5)
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.bottom, -10)
                
                CustomTabBar(selectedTab: $selectedTab, tabItems: tabItems)
            }
        }
    }
}

struct AuthTransitionView: View {
    @Binding var showAuthView: Bool
    
    var body: some View {
        Group {
            if showAuthView {
                LoginView(onLoginSuccess: {
                    withAnimation {
                        showAuthView = false
                    }
                }, onNavigateToSignUp: {
                    withAnimation {
                        showAuthView = false
                    }
                })
                .transition(.move(edge: .trailing))
            } else {
                SignUpView(onSignUpSuccess: {
                    withAnimation {
                        showAuthView = true
                    }
                }, onNavigateToLogin: {
                    withAnimation {
                        showAuthView = true
                    }
                })
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showAuthView)
    }
}

// Vista de la TabBar personalizada
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabItems: [TabItem]
    
    var body: some View {
        HStack {
            ForEach(0..<tabItems.count, id: \.self) { index in
                Spacer()
                TabButton(
                    item: tabItems[index],
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
                Spacer()
            }
        }
        .padding(.vertical, 10) // Margen vertical interno
        .padding(.horizontal, 20) // Margen horizontal externo
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 0)
        )
        .padding(.horizontal, 20) // Margen externo adicional para toda la barra
        .padding(.vertical, 10)
    }
    
}

// Botón individual de la TabBar
struct TabButton: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(isSelected ? item.activeColor : .gray)
                Text(item.name)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? item.activeColor : .gray)
            }
        }
        .frame(height: 44)
    }
}

// Vista previa para SwiftUI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
