//
//  ContentView.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GasRecordViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                AddFuelButtonView(viewModel: viewModel)
            }
            .tabItem {
                Label(String(localized: "Add_Fuel"), systemImage: "fuelpump")
            }
            
            GasRecordListView(viewModel: viewModel)
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
    }
}

#Preview {
    ContentView()
}
