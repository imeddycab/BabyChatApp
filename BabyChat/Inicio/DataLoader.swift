//
//  DataLoader.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import Foundation

class DataLoader {
    static func loadJSON() -> [Card] {
        guard let url = Bundle.main.url(forResource: "datos", withExtension: "json") else {
            print("ERROR: Archivo data.json no encontrado en el bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Decodificar ignorando el campo 'id' del JSON
            let cards = try decoder.decode([Card].self, from: data)
            print("✅ JSON cargado correctamente. \(cards.count) tarjetas.")
            return cards
        } catch {
            print("🚨 ERROR decodificando JSON: \(error.localizedDescription)")
            return []
        }
    }
}
