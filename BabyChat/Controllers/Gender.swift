//
//  Gender.swift
//  BabyChat
//
//  Created by eduardo caballero on 07/04/25.
//


import Foundation

enum Gender: String, CaseIterable {
    case male = "Masculino"
    case female = "Femenino"
    case other = "Otro"
    case unspecified = "No especificado"
    
    // Método para convertir de String ("M"/"F") a Gender
    static func from(string: String) -> Gender {
        return string == "F" ? .female : .male
    }
    
    // Método para convertir a String para la base de datos
    func toDatabaseValue() -> String {
        return self == .female ? "F" : "M"
    }
}
