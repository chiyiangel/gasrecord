//
//  GasRecordDetailView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct GasRecordDetailView: View {
    let record: GasRecord
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with date and fuel pump icon
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.formattedDate)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(String(localized: "Fuel_Record"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color("FuelBlue").opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("FuelBlue"))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Fuel details card
                VStack(spacing: 15) {
                    Text(String(localized: "Fuel_Details"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    DetailRow(title: String(localized: "Fuel_Amount"), value: String(format: "%.2f L", record.gallons), icon: "drop.fill")
                    
                    DetailRow(title: String(localized: "Price"), value: record.formattedPricePerGallon, icon: "yensign.circle.fill")
                    
                    DetailRow(title: String(localized: "Total_Cost"), value: record.formattedTotalCost, icon: "creditcard.fill")
                    
                    DetailRow(title: String(localized: "Odometer"), value: "\(record.odometer) km", icon: "speedometer")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Notes card if available
                if !record.notes.isEmpty {
                    VStack(spacing: 15) {
                        Text(String(localized: "Notes"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        Text(record.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "Fuel_Record_Details"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color("FuelBlue"))
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        GasRecordDetailView(record: GasRecord.sampleRecords[0])
    }
}
