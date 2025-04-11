//
//  GasRecordViewModel.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import Foundation
import SwiftUI

class GasRecordViewModel: ObservableObject {
    @Published var gasRecords: [GasRecord] = []
    @Published var showAddRecordSheet: Bool = false
    
    private let saveKey = "GasRecords"
    
    // 油耗统计和加油汇总信息
    var totalGallons: Double {
        gasRecords.reduce(0) { $0 + $1.gallons }
    }
    
    var totalCost: Double {
        gasRecords.reduce(0) { $0 + $1.totalCost }
    }
    
    var averagePricePerGallon: Double {
        guard totalGallons > 0 else { return 0 }
        return totalCost / totalGallons
    }
    
    var averageFuelEfficiency: Double? {
        // 需要至少两条记录来计算油耗
        guard gasRecords.count >= 2 else { return nil }
        
        // 按日期排序（从早到晚）
        let sortedRecords = gasRecords.sorted { $0.date < $1.date }
        guard let firstRecord = sortedRecords.first, let lastRecord = sortedRecords.last else { return nil }
        
        // 计算总里程差
        let totalDistance = lastRecord.odometer - firstRecord.odometer
        
        // 计算总加油量（除了最后一次加油，因为我们不知道这次加油后行驶了多少距离）
        let gallonsUsed = sortedRecords.dropLast().reduce(0) { $0 + $1.gallons }
        
        guard gallonsUsed > 0 else { return nil }
        
        // 返回平均每升/加仑行驶里程数
        return Double(totalDistance) / gallonsUsed
    }
    
    var formattedAverageFuelEfficiency: String {
        if let efficiency = averageFuelEfficiency {
            return String(format: "%.1f km/L", efficiency)
        } else {
            return "暂无数据"
        }
    }
    
    var formattedTotalGallons: String {
        return String(format: "%.1f L", totalGallons)
    }
    
    var formattedTotalCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: totalCost)) ?? "$\(totalCost)"
    }
    
    var formattedAveragePricePerGallon: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: averagePricePerGallon)) ?? "$\(averagePricePerGallon)"
    }
    
    init() {
        loadRecords()
        
        // If no records are loaded, use sample data
        if gasRecords.isEmpty {
            gasRecords = GasRecord.sampleRecords
        }
    }
    
    func addRecord(_ record: GasRecord) {
        gasRecords.insert(record, at: 0)
        saveRecords()
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        gasRecords.remove(atOffsets: indexSet)
        saveRecords()
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(gasRecords) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GasRecord].self, from: data) {
            gasRecords = decoded
        }
    }
}