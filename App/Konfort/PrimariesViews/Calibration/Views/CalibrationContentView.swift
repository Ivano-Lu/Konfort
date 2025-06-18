//
//  CalibrationContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 18/11/24.
//

import SwiftUI

struct CalibrationContentView: View {
    
    var title = ""
    var subtitleText = ""
    var titleButton = ""
    
    @Binding var coordinates: [Coordinates]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Text
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            
            
            Text(subtitleText)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // Calibration Data
            VStack(spacing: 30) {
                ForEach($coordinates, id: \.id) { coordinate in
                    CalibrationSectionView(coordinate: coordinate)
                }            }
            .padding(.horizontal)
            
            // Calibration Button
            Button(action: {
                // Action for starting calibration
            }) {
                Text(titleButton)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.top, 30)
        }
        .background()
    }
}


struct CalibrationSectionView: View {
    @Binding var coordinate: Coordinates

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(coordinate.name)
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 50) {
                CalibrationAxisView(axisTitle: "X", state: $coordinate.x)
                CalibrationAxisView(axisTitle: "Y", state: $coordinate.y)
                CalibrationAxisView(axisTitle: "Z", state: $coordinate.z)
            }
        }
    }
}

struct CalibrationAxisView: View {
    
    var axisTitle: String
    @Binding var state: Int
    
    var body: some View {
        VStack {
            Text(axisTitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(state > 0 ? "+" : "")\(state)°")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(state > 0 ? .green : state < 0 ? .red : .yellow)
        }
    }
}

#Preview {
    CalibrationView()
}
