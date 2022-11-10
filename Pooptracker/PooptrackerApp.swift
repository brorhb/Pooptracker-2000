//
//  PooptrackerApp.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PooptrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthWrapper()
                .environmentObject(AuthManager())
        }
    }
}

struct AuthWrapper: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        switch authManager.isLoggedIn {
        case true:
            ContentView()
                .environmentObject(ChildManager())
        case false:
            LoginScreen()
        default:
            ProgressView()
        }
    }
}
