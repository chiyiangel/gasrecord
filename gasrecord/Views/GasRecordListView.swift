//
//  GasRecordListView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct GasRecordListView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !viewModel.gasRecords.isEmpty {
                    GasStatisticsView(viewModel: viewModel)
                        .padding(.top, 8)
                }
                
                ZStack {
                    if viewModel.gasRecords.isEmpty {
                        VStack {
                            Image(systemName: "fuelpump.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                            
                            Text("暂无加油记录")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("点击\"加油\"标签页添加记录")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.top, 4)
                        }
                    } else {
                        List {
                            ForEach(viewModel.gasRecords) { record in
                                NavigationLink(destination: GasRecordDetailView(record: record)) {
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
                                viewModel.deleteRecord(at: indexSet)
                            }
                        }
                    }
                }
            }
            .navigationTitle("加油记录")
            .toolbar {
                if !viewModel.gasRecords.isEmpty {
                    EditButton()
                }
            }
        }
    }
}

struct GasStatisticsView: View {
    let viewModel: GasRecordViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("油耗统计与加油汇总")
                .font(.headline)
                .padding(.top, 12)
            
            HStack(spacing: 20) {
                StatisticItemView(
                    title: "平均油耗",
                    value: viewModel.formattedAverageFuelEfficiency,
                    iconName: "gauge.with.dots.needle.33percent"
                )
                
                StatisticItemView(
                    title: "总加油量",
                    value: viewModel.formattedTotalGallons,
                    iconName: "drop.fill"
                )
            }
            
            HStack(spacing: 20) {
                StatisticItemView(
                    title: "总花费",
                    value: viewModel.formattedTotalCost,
                    iconName: "dollarsign.circle.fill"
                )
                
                StatisticItemView(
                    title: "平均油价",
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