//
//  ChatView.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isUser: Bool)] = [
        ("¡Hola! ¿Cómo puedo ayudarte?", false)
    ]
    @State private var isTyping = false
    @State private var typingAnimation = ["...", "·..", ".·.", "..·"]
    @State private var typingIndex = 0
    @State private var changeBaby = false
    @State private var currentBabyImage: String = "baby1" // Imagen por defecto
    @State private var currentBabyName: String = "Ethan" // Nombre por defecto
    
    let apiKey = "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"
    let apiURL = "https://api.groq.com/openai/v1/chat/completions"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Botón de Cambio de Bebé con imagen
                Button(action: {
                    changeBaby = true
                }) {
                    Image(currentBabyImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 5))
                        .padding(.top, 10)
                }
                
                Text("Chat de \(currentBabyName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                // Botón para Nuevo chat
                Button(action: {
                    // Acción para nuevo chat
                    messages = [("¡Hola! ¿En qué puedo ayudarte hoy? 😊", false)]
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageBubble(text: messages[index].text, isUser: messages[index].isUser)
                    }
                    if isTyping {
                        MessageBubble(text: typingAnimation[typingIndex], isUser: false)
                            .onAppear {
                                startTypingAnimation()
                            }
                    }
                }
                .padding()
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(30)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .shadow(radius: 5)
            
            HStack {
                TextField("Escribe tu pregunta...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                Button(action: sendMessage) {
                    Text("Enviar")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
            .padding(.bottom, 85)
            .shadow(radius: 5)
        }
        .sheet(isPresented: $changeBaby) {
            CambiarBebeView(selectedBabyImage: $currentBabyImage, selectedBabyName: $currentBabyName) {
                // Resetear el chat cuando se cambia de bebé
                messages = [
                    ("¡Hola! ¿En qué puedo ayudarte hoy con \(currentBabyName)? 😊", false)
                ]
            }
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .padding(10)
            .background(Color(.blue).opacity(0.9).blur(radius: 100))
            .presentationCornerRadius(30)
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let userMessage = messageText
        messages.append((text: userMessage, isUser: true))
        messageText = ""
        isTyping = true
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "temperature": 0.6,
            "max_completion_tokens": 1024,
            "top_p": 1,
            "messages": messages.map { ["role": $0.isUser ? "user" : "Car assistant", "content": $0.text] }
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isTyping = false
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                DispatchQueue.main.async {
                    messages.append((text: content, isUser: false))
                }
            }
        }.resume()
    }
    
    func startTypingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            typingIndex = (typingIndex + 1) % typingAnimation.count
            if !isTyping {
                timer.invalidate()
            }
        }
    }
}

struct MessageBubble: View {
    var text: String
    var isUser: Bool

    var body: some View {
        HStack {
            if isUser { Spacer() }
            formatText(text)
                .padding()
                .background(isUser ? Color.blue : Color(.systemGray4))
                .foregroundColor(isUser ? .white : .black)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            if !isUser { Spacer() }
        }
    }
    
    func formatText(_ input: String) -> Text {
        let boldRegex = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*")
        let bulletRegex = try! NSRegularExpression(pattern: "\\*([^*]+)")
        let nsString = input as NSString
        
        var formattedText = Text("")
        var lastIndex = 0
        
        let boldMatches = boldRegex.matches(in: input, range: NSRange(location: 0, length: nsString.length))
        for match in boldMatches {
            let range = match.range(at: 1)
            let beforeText = nsString.substring(with: NSRange(location: lastIndex, length: range.location - lastIndex - 2))
            let boldText = nsString.substring(with: range)
            
            formattedText = formattedText + Text(beforeText) + Text(boldText).bold()
            lastIndex = range.location + range.length + 2
        }
        
        let remainingText = nsString.substring(from: lastIndex)
        formattedText = formattedText + Text(remainingText)
        
        let bulletMatches = bulletRegex.matches(in: input, range: NSRange(location: 0, length: nsString.length))
        if !bulletMatches.isEmpty {
            formattedText = Text("• ") + formattedText
        }
        
        return formattedText
    }
}

#Preview {
    ChatView()
}
