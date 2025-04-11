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
                Label("加油", systemImage: "fuelpump")
            }
            
            GasRecordListView(viewModel: viewModel)
            .tabItem {
                Label("记录", systemImage: "list.bullet")
            }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
