//
//  TestView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

struct TestView: View {
    @StateObject var drugViewModel = DrugViewModel()

    var body: some View {
        VStack {
            //if let errorMessage = drugViewModel.errorMessage {
                //Text("Error: \(errorMessage)")
                    //.foregroundColor(.red)
            //} else {
            Text("Result: \(drugViewModel.jsonString!)")
                //List(drugViewModel.strengths, id: \.self) { strength in
                    //Text(strength)
                //}
            //}
        }
        .task {
            await drugViewModel.performAPICall(term: "synthroid")
        }
    }
}

#Preview {
    TestView()
}
