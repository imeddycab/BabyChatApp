//
//  Card.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import Foundation
import FirebaseFirestore

struct Card: Identifiable, Codable, Hashable {
    // Cambiar a var para permitir asignación posterior
    var id: String?          // ID de Firestore (String)
    var documentId: String?  // ID del documento
    let originalId: Int      // ID numérico del JSON
    
    let category: String
    let title: String
    let description: String
    let content: String
    let source: String
    let icon: String         // Usar solo iconos válidos
    
    // Mapeo manual de claves para evitar conflictos
    enum CodingKeys: String, CodingKey {
        case originalId = "id"  // Mapear el campo "id" del JSON a originalId
        case category
        case title
        case description
        case content
        case source
        case icon
    }
    
    // Para Identifiable
    var uid: String {
        return id ?? documentId ?? String(originalId)
    }
}
