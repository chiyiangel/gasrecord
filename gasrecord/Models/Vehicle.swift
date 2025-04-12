//
//  Vehicle.swift
//  gasrecord
//
//  Created by AI on 2025/4/11.
//

import Foundation

struct Vehicle: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    
    static var sampleVehicles: [Vehicle] = [
        Vehicle(name: String(localized: "Default_Vehicle_1")),
        Vehicle(name: String(localized: "Default_Vehicle_2"))
    ]
}