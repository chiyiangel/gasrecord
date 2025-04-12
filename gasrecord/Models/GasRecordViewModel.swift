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
    @Published var vehicles: [Vehicle] = []
    @Published var selectedVehicleId: UUID?
    @Published var showAddRecordSheet: Bool = false
    @Published var showAddVehicleSheet: Bool = false
    @Published var isFirstLaunch: Bool = false
    
    private let saveKey = "GasRecords"
    private let vehiclesSaveKey = "Vehicles"
    private let firstLaunchKey = "FirstLaunch"
    private let selectedVehicleKey = "SelectedVehicle"
    
    // 获取当前选中车辆的记录
    var filteredRecords: [GasRecord] {
        if let vehicleId = selectedVehicleId {
            // 按照加油日期倒序排列（日期新的在前面）
            return gasRecords.filter { $0.vehicleId == vehicleId }
                .sorted { $0.date > $1.date }
        } else {
            // 如果没有选择车辆，返回空列表而不是所有记录
            return []
        }
    }
    
    // 获取选中车辆的名称
    var selectedVehicleName: String {
        if let vehicleId = selectedVehicleId,
           let vehicle = vehicles.first(where: { $0.id == vehicleId }) {
            return vehicle.name
        } else {
            return "选择车辆"
        }
    }
    
    // 油耗统计和加油汇总信息
    var totalGallons: Double {
        filteredRecords.reduce(0) { $0 + $1.gallons }
    }
    
    var totalCost: Double {
        filteredRecords.reduce(0) { $0 + $1.totalCost }
    }
    
    var averagePricePerGallon: Double {
        guard totalGallons > 0 else { return 0 }
        return totalCost / totalGallons
    }
    
    var averageFuelEfficiency: Double? {
        // 需要至少两条记录来计算油耗
        guard filteredRecords.count >= 2 else { return nil }
        
        // 按日期排序（从早到晚）
        let sortedRecords = filteredRecords.sorted { $0.date < $1.date }
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
        loadFirstLaunchState()
        loadVehicles()
        loadSelectedVehicle()
        loadRecords()
        
        // 如果是首次启动，显示添加默认车辆的提示
        if UserDefaults.standard.bool(forKey: firstLaunchKey) == false {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
        
        // 如果没有车辆，也视为首次启动
        if vehicles.isEmpty {
            isFirstLaunch = true
        }
    }
    
    func addRecord(_ record: GasRecord) {
        // 确保记录关联到当前选中的车辆
        var newRecord = record
        newRecord.vehicleId = selectedVehicleId
        
        gasRecords.insert(newRecord, at: 0)
        saveRecords()
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        gasRecords.remove(atOffsets: indexSet)
        saveRecords()
    }
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        
        // 如果是第一辆车，自动选中它
        if vehicles.count == 1 {
            selectedVehicleId = vehicle.id
            saveSelectedVehicle()
        }
        
        saveVehicles()
    }
    
    func deleteVehicle(at indexSet: IndexSet) {
        // 获取要删除的车辆ID
        let idsToDelete = indexSet.map { vehicles[$0].id }
        
        // 删除关联的记录
        gasRecords.removeAll { record in
            if let vehicleId = record.vehicleId {
                return idsToDelete.contains(vehicleId)
            }
            return false
        }
        
        // 删除车辆
        vehicles.remove(atOffsets: indexSet)
        
        // 如果删除的是当前选中的车辆，重置选择
        if let selectedId = selectedVehicleId, idsToDelete.contains(selectedId) {
            selectedVehicleId = nil
        }
        
        saveVehicles()
        saveRecords()
    }
    
    func selectVehicle(_ id: UUID?) {
        // 只允许选择存在的车辆
        if let id = id, vehicles.contains(where: { $0.id == id }) {
            selectedVehicleId = id
            saveSelectedVehicle()
        }
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
    
    private func saveVehicles() {
        if let encoded = try? JSONEncoder().encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: vehiclesSaveKey)
        }
    }
    
    private func loadVehicles() {
        if let data = UserDefaults.standard.data(forKey: vehiclesSaveKey),
           let decoded = try? JSONDecoder().decode([Vehicle].self, from: data) {
            vehicles = decoded
        }
    }
    
    private func loadFirstLaunchState() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }
    
    private func loadSelectedVehicle() {
        if let uuidString = UserDefaults.standard.string(forKey: selectedVehicleKey),
           let uuid = UUID(uuidString: uuidString) {
            selectedVehicleId = uuid
        }
    }
    
    private func saveSelectedVehicle() {
        if let vehicleId = selectedVehicleId {
            UserDefaults.standard.set(vehicleId.uuidString, forKey: selectedVehicleKey)
        }
    }
}