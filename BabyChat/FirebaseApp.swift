//
//  FirebaseApp.swift
//  BabyChat
//
//  Created by eduardo caballero on 01/04/25.
//

import Foundation
import FirebaseCore
import UIKit
import FirebaseDatabase

class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configuración de la base de datos
        Database.database().isPersistenceEnabled = true // Opcional: para persistencia offline
        
        return true
    }
}
