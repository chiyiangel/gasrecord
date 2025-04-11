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
    
    enum Field: Hashable {
        case gallons, price, total, odometer, notes
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
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
                            
                            Text("记录加油")
                                .font(.headline)
                                .foregroundColor(Color("FuelBlue"))
                                .padding(.top, 8)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("基本信息")) {
                    DatePicker("加油日期", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    LabeledContent("行驶里程") {
                        TextField("公里数", text: $odometer)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .odometer)
                    }
                }
                
                Section(header: Text("加油信息")) {
                    LabeledContent("加油量") {
                        TextField("升", text: $gallons)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .gallons)
                            .onChange(of: gallons) { _, newValue in
                                calculateTotal()
                            }
                    }
                    
                    LabeledContent("单价") {
                        TextField("元/升", text: $pricePerGallon)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .price)
                            .onChange(of: pricePerGallon) { _, newValue in
                                calculateTotal()
                            }
                    }
                    
                    LabeledContent("总花费") {
                        TextField("元", text: $totalCost)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .total)
                    }
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle("添加加油记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isFormValid)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("完成") {
                        focusedField = nil
                    }
                }
            }
            .alert("输入错误", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
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
            alertMessage = "请确保所有数值都填写正确"
            showingAlert = true
            return
        }
        
        let record = GasRecord(
            date: date,
            gallons: gallonsDouble,
            pricePerGallon: priceDouble,
            totalCost: totalDouble,
            odometer: odometerInt,
            notes: notes
        )
        
        viewModel.addRecord(record)
        dismiss()
    }
}

#Preview {
    AddGasRecordView(viewModel: GasRecordViewModel())
}