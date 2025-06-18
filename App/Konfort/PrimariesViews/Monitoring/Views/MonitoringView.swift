//
//  MonitoringView.swift
//  Konfort
//
//  Created by Ivano Lu on 03/11/24.
//

import SwiftUI


struct MonitoringView: View {
    @StateObject private var viewModel = MonitoringViewModel()
    
    
    var body: some View {
        
        MonitoringContentView(
            sliderValue: $viewModel.sliderValue,
            state: $viewModel.state, 
            subInfo: $viewModel.description)
    }
}

#Preview {
    HomeView()
}
