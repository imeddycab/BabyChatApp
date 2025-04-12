//
//  Card.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import Foundation
import FirebaseDatabase

struct Card: Identifiable, Codable, Hashable {
    var id: String?
    var documentId: String?
    let originalId: Int
    let category: String
    let title: String
    let description: String
    let source: String
    let icon: String
    let contentBlocks: [ContentBlock]
    
    enum CodingKeys: String, CodingKey {
        case originalId = "id"
        case category
        case title
        case description
        case source
        case icon
        case contentBlocks = "content"
    }
    
    // Propiedad computada para compatibilidad
    var content: String {
        return contentBlocks
            .filter { $0.type == "text" }
            .sorted { $0.order < $1.order }
            .map { $0.content }
            .joined(separator: "\n\n")
    }
    
    // Para Identifiable
    var uid: String {
        return id ?? documentId ?? String(originalId)
    }
}

struct ContentBlock: Codable, Hashable {
    let type: String
    let content: String
    let order: Int
}
