//
//  ContentView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if viewModel.userSession != nil && viewModel.currentUser != nil {
                ZStack {
                    switch selectedTab {
                    case .pill:
                        PillView()
                    case .home:
                        HomeView()
                    case .user:
                        ProfileView()
                    }
                    TabView()
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
