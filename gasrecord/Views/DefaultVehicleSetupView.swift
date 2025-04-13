//
//  DefaultVehicleSetupView.swift
//  gasrecord
//
//  Created by AI on 2025/4/11.
//

import SwiftUI
import UniformTypeIdentifiers

struct DefaultVehicleSetupView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var vehicleName: String = ""
    @State private var showError: Bool = false
    @State private var isImporting = false
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
                
                // 添加导入备份选项
                VStack(spacing: 15) {
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
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    Button(action: { isImporting = true }) {
                        HStack {
                            Image(systemName: "arrow.up.doc.fill")
                                .foregroundColor(Color("FuelBlue"))
                            Text(String(localized: "Restore_From_Backup"))
                                .foregroundColor(Color("FuelBlue"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("FuelBlue").opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding()
            .alert(String(localized: "Vehicle_Name"), isPresented: $showError) {
                Button(String(localized: "OK"), role: .cancel) {}
            }
            .alert(String(localized: "Import_Successful"), isPresented: $viewModel.showImportSuccessAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "Import_Success_Message"))
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let selectedURL = urls.first else { return }
                    
                    // 为了安全起见，创建一个安全的可访问URL
                    let secureURL = selectedURL.startAccessingSecurityScopedResource()
                    viewModel.importBackup(from: selectedURL)
                    // 如果导入成功，关闭设置页面
                    if viewModel.importSuccess {
                        viewModel.isFirstLaunch = false
                        dismiss()
                    }
                    if secureURL {
                        selectedURL.stopAccessingSecurityScopedResource()
                    }
                    
                case .failure(let error):
                    viewModel.importError = error.localizedDescription
                }
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