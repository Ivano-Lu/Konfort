//
//  MonitoringContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 07/11/24.
//

import SwiftUI

struct MonitoringContentView: View {
    
    @Binding var sliderValue: Double
    @Binding var state: StateMonitoring
    @Binding var subInfo: String
    let numberOfDots: Int = 40
    
    var body: some View {
        VStack {
            Text("\(state.rawValue)")
                .font(.title)
                .padding()
                .foregroundStyle(state.color)
            
            ZStack {
                ForEach(0..<numberOfDots) { index in
                    let angle = Angle(degrees: -180 + (Double(index) / Double(numberOfDots)) * 180)
                    let x = cos(angle.radians) * 90
                    let y = sin(angle.radians) * 90
                    
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(.blue)
                        .position(x: 100 + CGFloat(x), y: 100 + CGFloat(y))
                        .opacity(sliderValue >= Double(index) * (100 / Double(numberOfDots)) ? 1 : 0)
                    
                    Text("\(Int(sliderValue))°")
                    
                        .font(.title)
                        .padding()
                }
            }
            .frame(width: 200, height: 200)
            .padding()
            
            Text(subInfo)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    MonitoringView()
}


