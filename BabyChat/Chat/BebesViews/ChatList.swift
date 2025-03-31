//
//  ChatListView.swift
//  BabyChat
//
//  Created by eduardo caballero on 22/03/25.
//

import SwiftUI

struct ChatQuestion: Identifiable {
    var id = UUID()
    var question: String
}

struct ChatListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Lista de preguntas frecuentes
    @State private var chatQuestions: [ChatQuestion] = [
        ChatQuestion(question: "¿por qué mi hijo tiene el ojo amarillo?"),
        ChatQuestion(question: "¿qué vacuna es necesaria si mi hijo tiene 6 meses?"),
        ChatQuestion(question: "¿qué puedo preparar como desayuno para mi bebé?"),
        ChatQuestion(question: "¿es correcto darle un chupón cuando llora?"),
        ChatQuestion(question: "¿por qué la piel de mi bebé tiene una mancha roja?")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Botón de regreso
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Chats")
                            .padding(.horizontal, 10)
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Contenido principal
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    // Sección de Chats
                    Text("Historial de chats")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    // Lista de preguntas
                    ForEach(chatQuestions) { question in
                        HStack {
                            Text(question.question)
                                .foregroundColor(.black)
                                .font(.callout)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                // Acción para ver respuesta o continuar chat
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if chatQuestions.last?.id != question.id {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 20)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(radius: 2)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
