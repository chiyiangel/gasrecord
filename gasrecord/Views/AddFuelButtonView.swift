//
//  AddFuelButtonView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct AddFuelButtonView: View {
    @ObservedObject var viewModel: GasRecordViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                viewModel.showAddRecordSheet = true
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
                        
                        Text("点击加油")
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
        .navigationTitle("加油记录")
    }
}

#Preview {
    AddFuelButtonView(viewModel: GasRecordViewModel())
}