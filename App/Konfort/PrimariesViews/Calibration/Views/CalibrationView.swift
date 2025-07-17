//
//  CalibrationView.swift
//  Konfort
//
//  Created by Ivano Lu on 03/11/24.
//

import SwiftUI

struct CalibrationView: View {
    
    @StateObject private var viewModel = CalibrationViewModel()
    
    var body: some View {
        CalibrationContentView(
            title: viewModel.title,
            subtitleText: viewModel.subtitle,
            titleButton: viewModel.titleButton,
            coordinates: $viewModel.coordinates,
            viewModel: viewModel)
    }
}

#Preview {
    CalibrationView()
}
