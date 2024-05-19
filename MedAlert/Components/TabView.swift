//
//  TabView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case pill
    case home
    case user
    
    var symbolName: String {
        switch self {
        case .pill:
            return "pill.circle"
        case .home:
            return "house"
        case .user:
            return "person"
        }
    }
}


struct TabView: View {
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? tab.symbolName + ".fill" : tab.symbolName)
                        .scaleEffect(selectedTab == tab ? 1.5 : 1.25)
                        .foregroundStyle(Color.white)
                        .font(.system(size:22))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: 320, height: 60)
            .background(Color(.systemBlue).opacity(0.9))
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding()
        }
    }
}
    
#Preview {
    TabView()
}

