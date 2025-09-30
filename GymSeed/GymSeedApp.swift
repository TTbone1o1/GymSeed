//
//  GymSeedApp.swift
//  GymSeed
//
//  Created by Abraham may on 7/13/25.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct GymSeedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()  // ✅ Add this

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("BackGroundColor"))
                .ignoresSafeArea()
        }

    }
}
