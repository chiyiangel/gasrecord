//
//  ContentView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GasRecordViewModel()
    @State private var showBackupView = false
    
    var body: some View {
        TabView {
            NavigationStack {
                AddFuelButtonView(viewModel: viewModel)
            }
            .tabItem {
                Label(String(localized: "Add_Fuel"), systemImage: "fuelpump")
            }
            
            NavigationStack {
                GasRecordListView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showBackupView = true }) {
                                Image(systemName: "arrow.up.arrow.down.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Label(String(localized: "Records"), systemImage: "list.bullet")
            }
            
            NavigationStack {
                VehicleManagementView(viewModel: viewModel)
            }
            .tabItem {
                Label(String(localized: "Vehicles"), systemImage: "car.fill")
            }
        }
        .tint(Color("FuelBlue"))
        .sheet(isPresented: $showBackupView) {
            BackupView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
