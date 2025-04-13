// 
//  DataBackup.swift
//  gasrecord
//
//  Created by AI on 2025/4/13.
//

import Foundation

// 数据备份模型，包含所有需要备份的数据
struct DataBackup: Codable {
    var records: [GasRecord]
    var vehicles: [Vehicle]
    var selectedVehicleId: UUID?
    var backupDate: Date
    var appVersion: String
    
    // 当前版本号，未来版本更新时用于兼容性检查
    static let currentVersion = "1.0"
    
    init(records: [GasRecord], vehicles: [Vehicle], selectedVehicleId: UUID?) {
        self.records = records
        self.vehicles = vehicles
        self.selectedVehicleId = selectedVehicleId
        self.backupDate = Date()
        self.appVersion = DataBackup.currentVersion
    }
    
    // 返回格式化的备份日期字符串
    var formattedBackupDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: backupDate)
    }
    
    // 返回备份文件的默认名称，格式为：FuelBackup_YYYY-MM-DD.json
    static func defaultBackupFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return "FuelBackup_\(dateString).json"
    }
}