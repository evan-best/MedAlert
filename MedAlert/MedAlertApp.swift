//
//  MedAlertApp.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI
import FirebaseCore

@main
struct MedAlertApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
