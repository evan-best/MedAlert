//
//  Drug.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import Foundation

struct Drug {
    let name: String
    let amount: Int
    let dose: String
    let frequency: [PillView.Day]
    let reminders: [String]
}

