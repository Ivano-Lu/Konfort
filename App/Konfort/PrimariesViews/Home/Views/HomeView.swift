//
//  HomeView.swift
//  Konfort
//
//  Created by Ivano Lu on 03/11/24.
//

import SwiftUI

struct HomeUIItem {
    var title: String
    var chips: [ChipUIItem]
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var userData = UserDataStore.shared
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Konfort")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Welcome back ")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text(userData.userName.isEmpty ? "User" : userData.userName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Navigation tabs
                HStack(spacing: 12) {
                    ForEach(viewModel.chips, id: \.title) { chip in
                        ChipView(item: chip)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Content area
                ZStack {
                    switch viewModel.selectTab {
                    case .monitoring:
                        MonitoringView(homeViewModel: viewModel)
                    case .calibration:
                        CalibrationView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    HomeView()
}
