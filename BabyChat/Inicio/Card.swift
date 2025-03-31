//
//  Card.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//


import Foundation

struct Card: Identifiable, Codable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let content: String
    let source: String
    let icon: String
}