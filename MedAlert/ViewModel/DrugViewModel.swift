//
//  DrugViewModel.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import Foundation
import SwiftUI
import Combine

struct APIResponse: Decodable {
    let id: Int
    let terms: [String]
    let strengthsData: StrengthsData
    let additionalTerms: [[String]]

    enum CodingKeys: String, CodingKey {
        case id = "0"
        case terms = "1"
        case strengthsData = "2"
        case additionalTerms = "3"
    }
}

struct StrengthsData: Decodable {
    let strengthsAndForms: [[String]]

    enum CodingKeys: String, CodingKey {
        case strengthsAndForms = "STRENGTHS_AND_FORMS"
    }
}

class DrugViewModel: ObservableObject {
    @Published var drugName: String = ""
    @Published var strengths: [String] = []
    @Published var suggestions: [String] = []
    @Published var apiResult: [String] = []
    @Published var errorMessage: String? = nil
    @Published var jsonString: String? = ""

    init() {
        print("")
    }

    func performAPICall(term: String) async {
        do {
            let url = URL(string: "https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search?terms=\(term)&ef=STRENGTHS_AND_FORMS")
            let (data, _) = try await URLSession.shared.data(from: url!)
            self.jsonString = String(data: data, encoding: .utf8)
            print("JSON STRING: \(jsonString!)")
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            DispatchQueue.main.async {
                self.apiResult = response.terms
                self.strengths = response.strengthsData.strengthsAndForms.flatMap { $0 }
                print("API Result: \(self.apiResult)")
                print("Strengths: \(self.strengths)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Error: \(self.errorMessage ?? "Unknown error")")
            }
        }
    }
}
