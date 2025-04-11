//
//  VehicleManagementView.swift
//  gasrecord
//
//  Created by AI on 2025/4/11.
//

import SwiftUI

struct VehicleManagementView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var newVehicleName: String = ""
    @State private var showAlert = false
    @State private var showAddAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("添加车辆")) {
                    HStack {
                        TextField(String(localized: "Vehicle_Name"), text: $newVehicleName)
                        Button(action: addVehicle) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newVehicleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                Section(header: Text("已有车辆")) {
                    ForEach(viewModel.vehicles) { vehicle in
                        HStack {
                            Text(vehicle.name)
                            Spacer()
                            if viewModel.selectedVehicleId == vehicle.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 直接选中该车辆
                            viewModel.selectVehicle(vehicle.id)
                        }
                    }
                    .onDelete(perform: confirmDeletion)
                }
            }
            .navigationTitle("车辆管理")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("确认删除"),
                    message: Text("删除车辆将同时删除该车辆的所有加油记录，确定要删除吗？"),
                    primaryButton: .destructive(Text("删除")) {
                        if let indexSet = pendingDeletionIndexSet {
                            // 如果只有一辆车，不允许删除
                            if viewModel.vehicles.count <= 1 {
                                showAddAlert = true
                                return
                            }
                            
                            // 如果要删除的是当前选中的车辆，先选中另一辆车
                            let idsToDelete = indexSet.map { viewModel.vehicles[$0].id }
                            if let selectedId = viewModel.selectedVehicleId, idsToDelete.contains(selectedId) {
                                let remainingVehicles = viewModel.vehicles.filter { !idsToDelete.contains($0.id) }
                                if let firstRemaining = remainingVehicles.first {
                                    viewModel.selectVehicle(firstRemaining.id)
                                }
                            }
                            
                            viewModel.deleteVehicle(at: indexSet)
                            pendingDeletionIndexSet = nil
                        }
                    },
                    secondaryButton: .cancel {
                        pendingDeletionIndexSet = nil
                    }
                )
            }
            .alert("无法删除", isPresented: $showAddAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text("必须至少保留一辆车。如需更换，请先添加新车辆。")
            }
            .sheet(isPresented: $viewModel.isFirstLaunch) {
                DefaultVehicleSetupView(viewModel: viewModel)
            }
        }
    }
    
    @State private var pendingDeletionIndexSet: IndexSet?
    
    private func addVehicle() {
        let trimmedName = newVehicleName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newVehicle = Vehicle(name: trimmedName)
        viewModel.addVehicle(newVehicle)
        viewModel.selectVehicle(newVehicle.id)  // 自动选择新添加的车辆
        newVehicleName = ""
    }
    
    private func confirmDeletion(at indexSet: IndexSet) {
        pendingDeletionIndexSet = indexSet
        showAlert = true
    }
}

#Preview {
    VehicleManagementView(viewModel: GasRecordViewModel())
}