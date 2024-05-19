//
//  User.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let componenents = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: componenents)
        }
        
        return ""
    }
}
