//
//  DataLoader.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//


import Foundation

class DataLoader {
    static func loadJSON() -> [Card] {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cards = try? JSONDecoder().decode([Card].self, from: data) else {
            return []
        }
        return cards
    }
}