//
//  ReadingsManager.swift
//  BabyChat
//
//  Created by eduardo caballero on 01/04/25.
//

import Foundation
import FirebaseDatabase

class ReadingsManager: ObservableObject {
    static let shared = ReadingsManager()
    private var dbRef: DatabaseReference!
    
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var uploadError: String?
    
    private init() {
        dbRef = Database.database().reference()
        fetchReadings()
    }
    
    func fetchReadings() {
        isLoading = true
        dbRef.child("lecturas").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            
            guard snapshot.exists() else {
                print("No se encontraron lecturas en la base de datos")
                return
            }
            
            var newCards: [Card] = []
            
            // Iterar sobre todos los hijos del nodo lecturas
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let readingDict = snapshot.value as? [String: Any] else {
                    continue
                }
                
                if let card = self.parseReadingData(id: snapshot.key, data: readingDict) {
                    newCards.append(card)
                    print("Cargada tarjeta: \(card.title)") // Debug
                }
            }
            
            // Ordenar por originalId (o createdAt si lo prefieres)
            self.cards = newCards.sorted { $0.originalId > $1.originalId }
            self.printLoadedCards() // Debug
        }
    }
    
    private func parseReadingData(id: String, data: [String: Any]) -> Card? {
        guard let category = data["category"] as? String,
              let title = data["title"] as? String,
              let source = data["source"] as? String,
              let originalId = data["originalId"] as? Int else {
            print("Datos esenciales faltantes para la lectura \(id)")
            return nil
        }
        
        print("Procesando lectura ID: \(id)") // Debug
        
        guard let category = data["category"] as? String else {
            print("Error: Falta categoría en lectura \(id)")
            return nil
        }
        guard let title = data["title"] as? String else {
            print("Error: Falta título en lectura \(id)")
            return nil
        }
        guard let source = data["source"] as? String else {
            print("Error: Falta fuente en lectura \(id)")
            return nil
        }
        guard let originalId = data["originalId"] as? Int else {
            print("Error: Falta originalId en lectura \(id)")
            return nil
        }
        
        let description = data["description"] as? String ?? ""
        let icon = data["icon"] as? String ?? "book"
        
        // Procesar bloques de contenido
        var contentBlocks: [ContentBlock] = []
        
        if let contentArray = data["content"] as? [[String: Any]] {
            for blockDict in contentArray {
                if let type = blockDict["type"] as? String,
                   let content = blockDict["content"] as? String,
                   let order = blockDict["order"] as? Int {
                    
                    let block = ContentBlock(type: type, content: content, order: order)
                    contentBlocks.append(block)
                }
            }
        }
        
        // Ordenar los bloques por su orden
        contentBlocks.sort { $0.order < $1.order }
        
        print("Lectura \(id) procesada correctamente") // Debug
        return Card(
            id: id,
            documentId: id,
            originalId: originalId,
            category: category,
            title: title,
            description: description,
            source: source,
            icon: icon,
            contentBlocks: contentBlocks
        )
    }
    
    // Función para subir nuevas lecturas (opcional)
    func uploadReading(card: Card, completion: @escaping (Bool) -> Void) {
        let readingData: [String: Any] = [
            "category": card.category,
            "title": card.title,
            "description": card.description,
            "source": card.source,
            "content": [ // Esto es un ejemplo básico, adapta según tu estructura
                [
                    "type": "text",
                    "content": card.content,
                    "order": 0
                ]
            ],
            "createdAt": ServerValue.timestamp(),
            "originalId": Int(Date().timeIntervalSince1970 * 1000)
        ]
        
        dbRef.child("lecturas").childByAutoId().setValue(readingData) { error, _ in
            if let error = error {
                print("Error al subir lectura: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Lectura subida con éxito")
                self.fetchReadings() // Actualizar la lista
                completion(true)
            }
        }
    }
    
    // Método para imprimir todas las tarjetas cargadas (debug)
    func printLoadedCards() {
        print("\n=== TARJETAS CARGADAS ===")
        cards.forEach { card in
            print("""
            ID: \(card.id ?? "nil")
            Título: \(card.title)
            Bloques de contenido: \(card.contentBlocks.count)
            """)
        }
        print("========================\n")
    }
}
