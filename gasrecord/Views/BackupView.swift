//
//  BackupView.swift
//  gasrecord
//
//  Created by AI on 2025/4/13.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var backupFileURL: URL? = nil
    @State private var isImporting = false
    @State private var showingImportAlert = false
    @State private var showingEmptyDataAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color("FuelBlue").opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color("FuelBlue"))
                            }
                            
                            Text(String(localized: "Backup_And_Restore"))
                                .font(.headline)
                                .foregroundColor(Color("FuelBlue"))
                                .padding(.top, 8)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.clear)
                }
                
                // 备份数据统计
                Section(header: Text(String(localized: "Data_Summary"))) {
                    dataCountRow(
                        title: String(localized: "Vehicles_Count"),
                        count: viewModel.vehicles.count,
                        icon: "car.fill"
                    )
                    
                    dataCountRow(
                        title: String(localized: "Records_Count"),
                        count: viewModel.gasRecords.count,
                        icon: "fuelpump.fill"
                    )
                }
                
                // 备份功能
                Section(header: Text(String(localized: "Create_Backup"))) {
                    Button(action: backupData) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                                .foregroundColor(Color("FuelBlue"))
                                .frame(width: 30)
                            Text(String(localized: "Export_Data"))
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.isBackupInProgress {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .disabled(viewModel.vehicles.isEmpty || viewModel.isBackupInProgress)
                    
                    if let error = viewModel.backupError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                
                // 恢复功能
                Section(header: Text(String(localized: "Restore_Data"))) {
                    Button(action: { isImporting = true }) {
                        HStack {
                            Image(systemName: "arrow.up.doc.fill")
                                .foregroundColor(Color("FuelBlue"))
                                .frame(width: 30)
                            Text(String(localized: "Import_Data"))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    if let error = viewModel.importError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                
                // 备份说明
                Section(header: Text(String(localized: "Information"))) {
                    Text(String(localized: "Backup_Info_Details"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(String(localized: "Backup_And_Restore"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = backupFileURL {
                    ShareSheet(activityItems: [url])
                }
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
                    if secureURL {
                        selectedURL.stopAccessingSecurityScopedResource()
                    }
                    
                case .failure(let error):
                    viewModel.importError = error.localizedDescription
                }
            }
            .alert(String(localized: "Import_Successful"), isPresented: $viewModel.showImportSuccessAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "Import_Success_Message"))
            }
            .alert(String(localized: "No_Data"), isPresented: $showingEmptyDataAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "Create_Vehicle_First"))
            }
        }
    }
    
    private func dataCountRow(title: String, count: Int, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("FuelBlue"))
                .frame(width: 30)
            Text(title)
            Spacer()
            Text("\(count)")
                .fontWeight(.medium)
        }
    }
    
    private func backupData() {
        if viewModel.vehicles.isEmpty {
            showingEmptyDataAlert = true
            return
        }
        
        backupFileURL = viewModel.exportBackup()
        if backupFileURL != nil {
            showShareSheet = true
        }
    }
}

// 用于分享文件的视图
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    BackupView(viewModel: GasRecordViewModel())
}