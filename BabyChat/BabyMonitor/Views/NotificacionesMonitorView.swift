//
//  NotificacionesMonitorView.swift
//  BabyChat
//
//  Created by eduardo caballero on 20/03/25.
//


import SwiftUI

struct NotificacionesMonitorView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var humedadNotificaciones = false
    @State private var temperaturaNotificaciones = true
    @State private var gasesNotificaciones = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Botón de regreso
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                            Text("Notificaciones")
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    // Título
                    Text("Ethan - Cuna")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Las notificaciones nos permiten alertarte sobre alteraciones que podrían afectar la comodidad de tu bebé. Puedes desactivar las opciones que no quieres que te notifiquemos.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    // Opciones de notificación
                    NotificacionToggleView(nombre: "Humedad", descripcion: "No recibirás alertas de cambios en la humedad que afecten la comodidad de tu bebé.", isOn: $humedadNotificaciones)
                    NotificacionToggleView(nombre: "Temperatura", descripcion: "Recibirás alertas de cambios en la temperatura que afecten la comodidad de tu bebé.", isOn: $temperaturaNotificaciones)
                    NotificacionToggleView(nombre: "Gases", descripcion: "Recibirás alertas de la presencia de gases que afecten la salud de tu bebé.", isOn: $gasesNotificaciones)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
        }
    }
}

struct NotificacionToggleView: View {
    var nombre: String
    var descripcion: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(nombre)
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            Text(descripcion)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 10)
    }
}

struct NotificacionesMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        NotificacionesMonitorView()
    }
}
