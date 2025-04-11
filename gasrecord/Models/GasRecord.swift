//
//  GasRecord.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import Foundation

struct GasRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var gallons: Double
    var pricePerGallon: Double
    var totalCost: Double
    var odometer: Int
    var notes: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedTotalCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: totalCost)) ?? "$\(totalCost)"
    }
    
    var formattedPricePerGallon: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: pricePerGallon)) ?? "$\(pricePerGallon)"
    }
    
    static var sampleRecords: [GasRecord] = [
        GasRecord(date: Date().addingTimeInterval(-86400 * 7), gallons: 12.5, pricePerGallon: 3.599, totalCost: 44.99, odometer: 12500, notes: "Regular unleaded"),
        GasRecord(date: Date().addingTimeInterval(-86400 * 14), gallons: 10.2, pricePerGallon: 3.499, totalCost: 35.69, odometer: 12200, notes: "Filled up at Costco"),
        GasRecord(date: Date().addingTimeInterval(-86400 * 21), gallons: 11.8, pricePerGallon: 3.649, totalCost: 43.06, odometer: 11900, notes: "Premium grade")
    ]
}