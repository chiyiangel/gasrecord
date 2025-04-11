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
        Vehicle(name: "我的车"),
        Vehicle(name: "家用车")
    ]
}