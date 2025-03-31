//
//  FormatText.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//


import SwiftUI

struct FormatText: View {
    var text: String

    var body: some View {
        let lines = text.components(separatedBy: "\n")

        VStack(alignment: .leading, spacing: 12) {
            ForEach(lines.indices, id: \.self) { index in
                let line = lines[index]

                if line.hasPrefix("1.") || line.hasPrefix("2.") || line.hasPrefix("3.") {
                    Text(line)
                        .font(.headline)
                        .foregroundColor(.black)
                } else if !line.isEmpty {
                    Text(line)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    FormatText(text: "1. Usar ropa cómoda y elástica.\nLa ropa que tú elijas puede influir en tu comodidad día a día, no solo el día de parto, elegir una muda que no afecte tu comodidad puede disminuir el ...")
}