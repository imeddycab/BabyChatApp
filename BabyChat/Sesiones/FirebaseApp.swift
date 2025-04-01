//
//  FirebaseApp.swift
//  BabyChat
//
//  Created by eduardo caballero on 01/04/25.
//

import Foundation
import FirebaseCore
import UIKit

class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
