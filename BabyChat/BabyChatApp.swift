//
//  BabyChatApp.swift
//  BabyChat
//
//  Created by eduardo caballero on 18/03/25.
//

import SwiftUI
import Firebase

@main
struct BabyChatApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var readingsManager = ReadingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(readingsManager)
        }
    }
}
