//
//  LaunchScreen.swift
//  gasrecord
//
//  Created by Liu Jun on 2025/4/10.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.6
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color("FuelBlue").opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "fuelpump.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color("FuelBlue"))
                    }
                    
                    Text(String(localized: "Fuel_Records"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("FuelBlue"))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.opacity = 1.0
                        self.scale = 1.0
                    }
                    
                    // Delay 2 seconds before transitioning to the main screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreen()
}