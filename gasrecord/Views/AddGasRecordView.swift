//
//  AddGasRecordView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct AddGasRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GasRecordViewModel
    @FocusState private var focusedField: Field?
    
    @State private var date = Date()
    @State private var gallons = ""
    @State private var pricePerGallon = ""
    @State private var totalCost = ""
    @State private var odometer = ""
    @State private var notes = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDatePicker = false
    
    enum Field: Hashable {
        case gallons, price, total, odometer, notes
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter;
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // 表单顶部添加加油图标
                    HStack {
                        Spacer()
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color("FuelBlue").opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "fuelpump.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color("FuelBlue"))
                            }
                            
                            Text(String(localized: "Record_Fuel"))
                                .font(.headline)
                                .foregroundColor(Color("FuelBlue"))
                                .padding(.top, 8)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text(String(localized: "Basic_Info"))) {
                    // 显示当前选中的车辆（不可更改）
                    HStack {
                        Text(String(localized: "Vehicle"))
                        Spacer()
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(Color("FuelBlue"))
                                .font(.caption)
                            Text(viewModel.selectedVehicleName)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text(String(localized: "Fuel_Date"))
                        Spacer()
                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    if showingDatePicker {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: date) { oldValue, newValue in
                            showingDatePicker = false
                        }
                    }
                    
                    LabeledContent(String(localized: "Odometer")) {
                        TextField(String(localized: "Kilometers"), text: $odometer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .odometer)
                    }
                }
                
                Section(header: Text(String(localized: "Fuel_Info"))) {
                    LabeledContent(String(localized: "Fuel_Amount")) {
                        TextField(String(localized: "Liters"), text: $gallons)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .gallons)
                            .onChange(of: gallons) { _, newValue in
                                calculateTotal()
                            }
                    }
                    
                    LabeledContent(String(localized: "Price")) {
                        TextField(String(localized: "Price_Per_Liter"), text: $pricePerGallon)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .price)
                            .onChange(of: pricePerGallon) { _, newValue in
                                calculateTotal()
                            }
                    }
                    
                    LabeledContent(String(localized: "Total_Cost")) {
                        TextField(String(localized: "Yuan"), text: $totalCost)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .total)
                    }
                }
                
                Section(header: Text(String(localized: "Notes"))) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle(String(localized: "Add_Fuel_Record"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        saveRecord()
                    }
                    .disabled(!isFormValid)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(String(localized: "Done")) {
                        focusedField = nil
                    }
                }
            }
            .alert(String(localized: "Input_Error"), isPresented: $showingAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !gallons.isEmpty && !pricePerGallon.isEmpty && !totalCost.isEmpty && !odometer.isEmpty
    }
    
    private func calculateTotal() {
        if let gallonsValue = Double(gallons.replacingOccurrences(of: ",", with: ".")),
           let priceValue = Double(pricePerGallon.replacingOccurrences(of: ",", with: ".")) {
            let total = gallonsValue * priceValue
            totalCost = String(format: "%.2f", total)
        }
    }
    
    private func saveRecord() {
        // Validate input
        guard let gallonsDouble = Double(gallons.replacingOccurrences(of: ",", with: ".")),
              let priceDouble = Double(pricePerGallon.replacingOccurrences(of: ",", with: ".")),
              let totalDouble = Double(totalCost.replacingOccurrences(of: ",", with: ".")),
              let odometerInt = Int(odometer) else {
            alertMessage = String(localized: "Ensure_Values_Correct")
            showingAlert = true
            return
        }
        
        // 验证是否选择了车辆
        if viewModel.selectedVehicleId == nil {
            alertMessage = String(localized: "Please_Select_Vehicle")
            showingAlert = true
            return
        }
        
        let record = GasRecord(
            date: date,
            gallons: gallonsDouble,
            pricePerGallon: priceDouble,
            totalCost: totalDouble,
            odometer: odometerInt,
            notes: notes,
            vehicleId: viewModel.selectedVehicleId
        )
        
        viewModel.addRecord(record)
        dismiss()
    }
}

#Preview {
    AddGasRecordView(viewModel: GasRecordViewModel())
}
