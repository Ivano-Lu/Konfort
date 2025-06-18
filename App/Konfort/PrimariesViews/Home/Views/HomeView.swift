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
    
    var body: some View {
        VStack {
            
            HStack {
                ForEach(viewModel.chips, id: \.title) { chip in
                    ChipView(item: chip)
                }
            }
          //  .frame(height: 0)
            .padding()
            
            Spacer()
           
            ZStack {
                switch viewModel.selectTab {
                case .monitoring:
                    MonitoringView()
                case .history:
                    HistoryView()
                case .calibration:
                    CalibrationView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            //.clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

#Preview {
    HomeView()
}
