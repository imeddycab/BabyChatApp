//
//  ReadingsManager.swift
//  BabyChat
//
//  Created by eduardo caballero on 01/04/25.
//

import Foundation
import FirebaseFirestore

class ReadingsManager: ObservableObject {
    static let shared = ReadingsManager()
    private var db = Firestore.firestore()
    
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var uploadError: String?
    
    private init() {
        checkAndUploadInitialData()
    }
    
    func fetchReadings() {
        isLoading = true
        db.collection("lecturas").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching readings: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No documents found, uploading initial data")
                self.uploadInitialData()
                return
            }
            
            var uniqueCards = [Card]()
            
            for document in documents {
                let data = document.data()
                
                // Mapeo manual para evitar problemas de decodificación
                let card = Card(
                    id: document.documentID,
                    documentId: document.documentID,
                    originalId: data["originalId"] as? Int ?? (data["id"] as? Int ?? 0),
                    category: data["category"] as? String ?? "",
                    title: data["title"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    content: data["content"] as? String ?? "",
                    source: data["source"] as? String ?? "",
                    icon: data["icon"] as? String ?? "book" // Icono por defecto válido
                )
                
                // Evitar duplicados
                if !uniqueCards.contains(where: { $0.documentId == card.documentId }) {
                    uniqueCards.append(card)
                    print("Loaded card - ID: \(card.documentId ?? "nil"), Title: \(card.title)")
                }
            }
            
            self.cards = uniqueCards.sorted { $0.originalId < $1.originalId }
        }
    }
    
    func uploadInitialDataIfNeeded() {
        // Verificar si ya hay datos antes de subir
        db.collection("lecturas").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking for existing data: \(error.localizedDescription)")
                return
            }
            
            // Si no hay documentos, subir los datos iniciales
            if snapshot?.documents.isEmpty == true {
                self.uploadInitialData()
            }
        }
    }
    
    func uploadInitialData() {
        let localCards = DataLoader.loadJSON()
        guard !localCards.isEmpty else {
            print("ERROR: No hay tarjetas locales para subir")
            return
        }
        
        print("Iniciando subida de \(localCards.count) tarjetas...")
        
        let batch = db.batch()
        
        for card in localCards {
            let docRef = db.collection("lecturas").document("card_\(card.originalId)")
            
            do {
                let data = try Firestore.Encoder().encode(card)
                batch.setData(data, forDocument: docRef)
                print("Preparada tarjeta \(card.originalId) para subir")
            } catch {
                print("ERROR al codificar tarjeta \(card.originalId): \(error)")
            }
        }
        
        batch.commit { error in
            if let error = error {
                print("ERROR al subir datos: \(error.localizedDescription)")
            } else {
                print("Éxito: \(localCards.count) tarjetas subidas a Firestore")
                self.verifyUpload(count: localCards.count)
            }
        }
    }

    func verifyUpload(count expectedCount: Int) {
        db.collection("lecturas").getDocuments { snapshot, error in
            if let error = error {
                print("Verification failed: \(error.localizedDescription)")
                return
            }
            
            let actualCount = snapshot?.documents.count ?? 0
            print("Verification result: \(actualCount)/\(expectedCount) documents found")
            
            if actualCount != expectedCount {
                print("Mismatch in document count. Retrying upload...")
                self.uploadInitialData()
            } else {
                print("Upload verification successful")
                self.fetchReadings() // Refrescar los datos en la app
            }
        }
    }
    
    private func checkAndUploadInitialData() {
        db.collection("lecturas").limit(to: 1).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Initial check failed: \(error.localizedDescription)")
                return
            }
            
            if snapshot?.isEmpty == true {
                print("No data found in Firestore. Uploading initial data...")
                self.uploadInitialData()
            } else {
                print("Data exists in Firestore. Fetching...")
                self.fetchReadings()
            }
        }
    }
    
    func forceLoadAndUpload() {
        // 1. Borrar colección existente
        deleteAllCards { [weak self] in
            guard let self = self else { return }
            
            // 2. Cargar JSON local
            let cards = DataLoader.loadJSON()
            
            // 3. Subir datos
            self.uploadCards(cards: cards)
        }
    }

    private func deleteAllCards(completion: @escaping () -> Void) {
        db.collection("lecturas").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
            let batch = self.db.batch()
            documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { _ in
                print("Colección limpiada")
                completion()
            }
        }
    }

    private func uploadCards(cards: [Card]) {
        cards.forEach { card in
            db.collection("lecturas").document("card_\(card.originalId)").setData([
                "originalId": card.originalId,
                "category": card.category,
                "title": card.title,
                "description": card.description,
                "content": card.content,
                "source": card.source,
                "icon": card.icon
            ]) { error in
                if let error = error {
                    print("Error subiendo card \(card.originalId): \(error)")
                } else {
                    print("Card \(card.originalId) subida correctamente")
                }
            }
        }
    }
    
    func emergencyRestore() {
        let defaultCards = [
            Card(id: "card_1", documentId: "card_1", originalId: 1,
                 category: "Técnicas de maternidad", title: "Instructivo",
                 description: "Principios del cuidado...", content: "Antes de dar el gran paso...",
                 source: "IMSS, 2025.", icon: "figure.dress"),
            // Agrega las demás tarjetas manualmente aquí
        ]
        
        uploadCards(cards: defaultCards)
    }
}
