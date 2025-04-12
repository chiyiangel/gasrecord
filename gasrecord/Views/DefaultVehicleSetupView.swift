//
//  DefaultVehicleSetupView.swift
//  gasrecord
//
//  Created by AI on 2025/4/11.
//

import SwiftUI

struct DefaultVehicleSetupView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var vehicleName: String = ""
    @State private var showError: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 头部图标和说明
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color("FuelBlue").opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("FuelBlue"))
                    }
                    .padding(.bottom, 10)
                    
                    Text(String(localized: "Welcome_To_App"))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(String(localized: "First_Time_Setup"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                // 车辆名称输入框
                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: "Vehicle_Name"))
                        .font(.headline)
                    
                    TextField(String(localized: "Vehicle_Name"), text: $vehicleName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 确认按钮
                Button(action: addDefaultVehicle) {
                    Text(String(localized: "Start_Using"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vehicleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color("FuelBlue"))
                        .cornerRadius(10)
                }
                .disabled(vehicleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding()
            .alert(String(localized: "Vehicle_Name"), isPresented: $showError) {
                Button(String(localized: "OK"), role: .cancel) {}
            }
            .interactiveDismissDisabled() // 禁止手势关闭
        }
    }
    
    private func addDefaultVehicle() {
        let trimmedName = vehicleName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            showError = true
            return
        }
        
        let newVehicle = Vehicle(name: trimmedName)
        viewModel.addVehicle(newVehicle)
        viewModel.selectVehicle(newVehicle.id)
        viewModel.isFirstLaunch = false
        dismiss()
    }
}

#Preview {
    DefaultVehicleSetupView(viewModel: GasRecordViewModel())
}