//
//  FirebaseApp.swift
//  BabyChat
//
//  Created by eduardo caballero on 01/04/25.
//

import Foundation
import FirebaseCore
import UIKit
import FirebaseFirestore

class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configuración de Firestore
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        // Opcional: Subir datos iniciales (ejecutar solo una vez)
        //ReadingsManager.shared.uploadInitialData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let manager = ReadingsManager.shared
//            manager.forceLoadAndUpload()
//
//            // Si falla después de 5 segundos
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                if manager.cards.isEmpty {
//                    manager.emergencyRestore()
//                }
//            }
//        }
        
        return true
    }
}
