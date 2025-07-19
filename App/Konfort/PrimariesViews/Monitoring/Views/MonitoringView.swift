//
//  MonitoringView.swift
//  Konfort
//
//  Created by Ivano Lu on 03/11/24.
//

import SwiftUI


struct MonitoringView: View {
    @StateObject private var viewModel = MonitoringViewModel()
    @ObservedObject var homeViewModel: HomeViewModel
    
    
    var body: some View {
        
        MonitoringContentView(
            sliderValue: $viewModel.sliderValue,
            state: $viewModel.state, 
            subInfo: $viewModel.description,
            isCalibrated: $viewModel.isCalibrated,
            connectionStatus: $viewModel.connectionStatus,
            lastUpdateTime: $viewModel.lastUpdateTime,
            dataReceivedCount: $viewModel.dataReceivedCount,
            homeViewModel: homeViewModel)
    }
}

#Preview {
    MonitoringView(homeViewModel: HomeViewModel())
}
