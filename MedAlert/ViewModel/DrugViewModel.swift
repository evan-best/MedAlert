//
//  DrugViewModel.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import Foundation

class DrugViewModel: ObservableObject {
    @Published var jsonString: String?
    @Published var strengths: [[String]] = []
    @Published var name: String?
    @Published var errorMessage: String?
    @Published var suggestions: [String] = []

    // Function to perform API call for suggestions
    func fetchSuggestions(term: String) async {
        do {
            // Construct URL for API call
            let urlString = "https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search?terms=\(term)&ef=NONE"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            // Fetch data from URL
            let (data, _) = try await URLSession.shared.data(from: url)
            // Convert data to JSON string for debugging
            self.jsonString = String(data: data, encoding: .utf8)
            print("JSON STRING: \(jsonString!)")
            
            // Convert JSON string to data
            guard let jsonData = jsonString?.data(using: .utf8) else {
                print("Failed to convert JSON string to data")
                return
            }
            
            // Parse JSON data
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any]
            
            if let count = jsonArray?[0] as? Int, count > 0, let nameArray = jsonArray?[1] as? [String] {
                self.suggestions = nameArray
            } else {
                self.suggestions = []
            }
            
        } catch {
            self.errorMessage = "Error fetching suggestions: \(error)"
            print(errorMessage ?? "Unknown error")
        }
    }

    // Function to perform API call for drug details
    func performAPICall(term: String) async {
        do {
            // Construct URL for API call
            let urlString = "https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search?terms=\(term)&ef=STRENGTHS_AND_FORMS"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            // Fetch data from URL
            let (data, _) = try await URLSession.shared.data(from: url)
            // Convert data to JSON string for debugging
            self.jsonString = String(data: data, encoding: .utf8)
            print("JSON STRING: \(jsonString!)")
            
            // Convert JSON string to data
            guard let jsonData = jsonString?.data(using: .utf8) else {
                print("Failed to convert JSON string to data")
                return
            }
            
            // Parse JSON data
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any]
            
            if let parsedData = parseDrugData(jsonData: jsonArray) {
                self.strengths = parsedData["STRENGTHS_AND_FORMS"] as? [[String]] ?? []
                self.name = parsedData["name"] as? String
            } else {
                self.errorMessage = "Failed to parse JSON data"
            }
            
        } catch {
            self.errorMessage = "Error performing API call: \(error)"
            print(errorMessage ?? "Unknown error")
        }
    }

    // Function to parse JSON data
    private func parseDrugData(jsonData: [Any]?) -> [String: Any]? {
        guard let jsonData = jsonData,
              jsonData.count > 3,
              let count = jsonData[0] as? Int,
              let nameArray = jsonData[1] as? [String],
              let details = jsonData[2] as? [String: [[String]]] else {
            return nil
        }
        
        guard let strengthsAndForms = details["STRENGTHS_AND_FORMS"] else {
            return nil
        }
        
        let drugData: [String: Any] = [
            "count": count,
            "name": nameArray.first ?? "",
            "STRENGTHS_AND_FORMS": strengthsAndForms
        ]
        
        return drugData
    }
}

