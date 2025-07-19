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
    @Binding var isCalibrated: Bool
    @Binding var connectionStatus: String
    @Binding var lastUpdateTime: Date
    @Binding var dataReceivedCount: Int
    let numberOfDots: Int = 40
    
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if isCalibrated {
                // Calibrated state - show posture monitoring
                VStack(spacing: 0) {
                    // Main content card
                    VStack(spacing: 32) {
                        // Status text
                        Text(getStatusText())
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                        
                        // Gauge visualization
                        ZStack {
                            // Background semi-circle
                            Circle()
                                .trim(from: 0.5, to: 1.0)
                                .stroke(Color(red: 0.15, green: 0.15, blue: 0.17), lineWidth: 12)
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(180))
                            
                            // Progress semi-circle
                            Circle()
                                .trim(from: 0.5, to: 0.5 + (sliderValue / 100) * 0.5)
                                .stroke(Color(red: 0.4, green: 0.9, blue: 0.7), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(180))
                                .animation(.easeInOut(duration: 0.3), value: sliderValue)
                            
                            // Center value
                            VStack(spacing: 4) {
                                Text("\(Int(sliderValue))°")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(y: -20)
                        }
                        
                        // Description text
                        Text(subInfo)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .animation(.easeInOut(duration: 0.3), value: subInfo)
                    }
                    .padding(32)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
            } else {
                // Uncalibrated state - show calibration prompt
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Device Not Calibrated")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Please calibrate your device first to start posture monitoring.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Navigate to calibration tab
                        homeViewModel.selectTab = .calibration
                    }) {
                        Text("Go to Calibration")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .background(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                            .cornerRadius(8)
                    }
                }
                .padding(32)
                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
    
    private func getStatusText() -> String {
        switch state {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .bad:
            return "Poor"
        }
    }
}

#Preview {
    MonitoringView(homeViewModel: HomeViewModel())
}


