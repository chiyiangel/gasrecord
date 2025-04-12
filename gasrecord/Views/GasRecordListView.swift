//
//  GasRecordListView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct GasRecordListView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    @State private var showVehicleSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 显示当前选择的车辆
                VStack(spacing: 8) {
                    Text(String(localized: "Current_Vehicle_Being_Viewed"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VehiclePickerView(viewModel: viewModel)
                        .padding(.horizontal)
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
                
                if !viewModel.filteredRecords.isEmpty {
                    GasStatisticsView(viewModel: viewModel)
                        .padding(.top, 8)
                }
                
                ZStack {
                    if viewModel.filteredRecords.isEmpty {
                        VStack {
                            Image(systemName: "fuelpump.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                            
                            Text(String(localized: "No_Fuel_Records"))
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text(String(localized: "Add_Records_Instruction"))
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.top, 4)
                        }
                    } else {
                        List {
                            ForEach(viewModel.filteredRecords) { record in
                                NavigationLink(destination: GasRecordDetailView(record: record, viewModel: viewModel)) {
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .fill(Color("FuelBlue").opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "fuelpump.fill")
                                                .foregroundColor(Color("FuelBlue"))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(record.formattedDate)
                                                .font(.headline)
                                            
                                            HStack {
                                                Text(String(format: "%.2f L", record.gallons))
                                                    .foregroundColor(.secondary)
                                                
                                                Text("·")
                                                    .foregroundColor(.secondary)
                                                
                                                Text(record.formattedTotalCost)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .onDelete { indexSet in
                                // 需要转换索引集合，因为filteredRecords和gasRecords的索引可能不同
                                let recordsToDelete = indexSet.map { viewModel.filteredRecords[$0] }
                                let gasRecordIndices = recordsToDelete.compactMap { record in
                                    viewModel.gasRecords.firstIndex(where: { $0.id == record.id })
                                }
                                let gasRecordIndexSet = IndexSet(gasRecordIndices)
                                viewModel.deleteRecord(at: gasRecordIndexSet)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Fuel_Records"))
            .toolbar {
                if !viewModel.filteredRecords.isEmpty {
                    EditButton()
                }
            }
            .sheet(isPresented: $viewModel.isFirstLaunch) {
                DefaultVehicleSetupView(viewModel: viewModel)
            }
        }
    }
}

struct GasStatisticsView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    
    var body: some View {
        VStack(spacing: 16) {
                Text(String(localized: "Fuel_Statistics"))
                .font(.headline)
                .padding(.top, 12)
            
            HStack(spacing: 20) {
                StatisticItemView(
                    title: String(localized: "Average_Fuel_Efficiency"),
                    value: viewModel.formattedAverageFuelEfficiency,
                    iconName: "gauge.with.dots.needle.33percent"
                )
                
                StatisticItemView(
                    title: String(localized: "Total_Fuel_Amount"),
                    value: viewModel.formattedTotalGallons,
                    iconName: "drop.fill"
                )
            }
            
            HStack(spacing: 20) {
                StatisticItemView(
                    title: String(localized: "Total_Cost"),
                    value: viewModel.formattedTotalCost,
                    iconName: "dollarsign.circle.fill"
                )
                
                StatisticItemView(
                    title: String(localized: "Average_Fuel_Price"),
                    value: viewModel.formattedAveragePricePerGallon,
                    iconName: "fuelpump.fill"
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .id(viewModel.gasRecords.count) // 添加这一行，使记录数变化时视图强制刷新
    }
}

struct StatisticItemView: View {
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(Color("FuelBlue"))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("FuelBlue").opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    GasRecordListView(viewModel: GasRecordViewModel())
}
