//
//  HomeView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedTab") var selectedTab: Tab = .home
    @StateObject var drugViewModel = DrugViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var weekStore = WeekStore()
    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top, spacing: 10) {
                Text("Hi, \(viewModel.currentUser?.fullname ?? "Evan Best").")
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .font(.title)
                
                Image("image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .padding(.top, -28)
            }
            .padding(.top, 20)
            
            // Pass weekStore to update current date properly between views.
            WeekView(weekStore: weekStore)
            
            VStack (spacing: 20){
                Text(weekStore.formattedCurrentDate())
                    .font(.subheadline)
            }
        }
        Spacer()
    }
}



#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
