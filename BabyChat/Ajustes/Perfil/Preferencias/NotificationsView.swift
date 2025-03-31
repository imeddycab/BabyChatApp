//
//  NotificationsView.swift
//  BabyChat
//
//  Created by eduardo caballero on 25/03/25.
//


import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var vacunasNotification = false
    @State private var pediatraSuggestions = true
    @State private var newReadings = true
    
    var body: some View {
        VStack(spacing: 10) {
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Notificaciones")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Las notificaciones nos permiten alertarte sobre sugerencias o avisos que podrían interesarte sobre el desarrollo de tu bebé. Puedes desactivar las opciones que no quieres que te notifiquemos.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding()
                    
                    // Notification Toggles
                    NotificationToggle(
                        title: "Sugerencias del pediatra", 
                        description: "Recibirás alertas de sugerencias de lectura que tu pediatra haya recomendado.",
                        isOn: $pediatraSuggestions
                    )
                    
                    NotificationToggle(
                        title: "Nuevas lecturas", 
                        description: "Recibirás alertas de articulos, notas o lecturas promovidas por la comunidad de pediatras.",
                        isOn: $newReadings
                    )
                    
                    // Footer Note
                    Text("Para desactivar las notificaciones generales de BabyChat deberá hacerlo desde la configuración de su dispositivo.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct NotificationToggle: View {
    var title: String
    var description: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
            }
            .padding()
            
            Divider()
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
