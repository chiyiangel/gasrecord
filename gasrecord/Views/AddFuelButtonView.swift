//
//  AddFuelButtonView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct AddFuelButtonView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var showVehiclePicker = false
    
    var body: some View {
        VStack {
            // 车辆选择器
            VStack(spacing: 8) {
                Text("当前记录的车辆")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VehiclePickerView(viewModel: viewModel)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
            
            Button {
                // 确保有车辆被选中
                if viewModel.selectedVehicleId != nil {
                    viewModel.showAddRecordSheet = true
                } else {
                    showVehiclePicker = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color("FuelBlue").opacity(0.15))
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .stroke(Color("FuelBlue"), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "fuelpump.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color("FuelBlue"))
                        
                        Text(String(localized: "Tap_To_Add_Fuel"))
                            .font(.headline)
                            .foregroundColor(Color("FuelBlue"))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
            .sheet(isPresented: $viewModel.showAddRecordSheet) {
                AddGasRecordView(viewModel: viewModel)
            }
            
            Spacer()
        }
        .navigationTitle(String(localized: "Fuel_Records"))
        .sheet(isPresented: $viewModel.isFirstLaunch) {
            DefaultVehicleSetupView(viewModel: viewModel)
        }
    }
}

// 车辆选择器组件
struct VehiclePickerView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var showVehicleSheet = false
    
    var body: some View {
        Button(action: {
            if viewModel.vehicles.isEmpty {
                viewModel.isFirstLaunch = true
            } else {
                showVehicleSheet = true
            }
        }) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(Color("FuelBlue"))
                
                Text(viewModel.selectedVehicleName)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("FuelBlue").opacity(0.1))
            .cornerRadius(10)
        }
        .sheet(isPresented: $showVehicleSheet) {
            VehicleSelectionSheet(viewModel: viewModel, isPresented: $showVehicleSheet)
        }
    }
}

// 车辆选择弹出表单
struct VehicleSelectionSheet: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @Binding var isPresented: Bool
    @State private var newVehicleName = ""
    @State private var showAddVehicle = false
    
    var body: some View {
        NavigationStack {
            List {
                if showAddVehicle {
                    Section {
                        HStack {
                            TextField("请输入新车辆名称", text: $newVehicleName)
                            
                            Button(action: addNewVehicle) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("FuelBlue"))
                            }
                            .disabled(newVehicleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Button(action: { showAddVehicle = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("选择车辆")) {
                    ForEach(viewModel.vehicles) { vehicle in
                        Button(action: {
                            viewModel.selectVehicle(vehicle.id)
                            isPresented = false
                        }) {
                            HStack {
                                Text(vehicle.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if viewModel.selectedVehicleId == vehicle.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("FuelBlue"))
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteVehicle)
                }
            }
            .navigationTitle("车辆选择")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddVehicle.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addNewVehicle() {
        let trimmedName = newVehicleName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newVehicle = Vehicle(name: trimmedName)
        viewModel.addVehicle(newVehicle)
        viewModel.selectVehicle(newVehicle.id)
        newVehicleName = ""
        showAddVehicle = false
        isPresented = false
    }
    
    private func deleteVehicle(at indexSet: IndexSet) {
        // 如果只有一辆车，不允许删除
        if viewModel.vehicles.count <= 1 {
            return
        }
        
        // 获取要删除的车辆ID
        let idsToDelete = indexSet.map { viewModel.vehicles[$0].id }
        
        // 如果要删除的是当前选中的车辆，先选中另一辆车
        if let selectedId = viewModel.selectedVehicleId, idsToDelete.contains(selectedId) {
            if let firstOther = viewModel.vehicles.first(where: { !idsToDelete.contains($0.id) }) {
                viewModel.selectVehicle(firstOther.id)
            }
        }
        
        viewModel.deleteVehicle(at: indexSet)
    }
}

#Preview {
    AddFuelButtonView(viewModel: GasRecordViewModel())
}
