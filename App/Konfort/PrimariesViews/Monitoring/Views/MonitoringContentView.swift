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
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status and data info
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(connectionStatus == "Connected" ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(connectionStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if isCalibrated && connectionStatus == "Connected" {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.blue)
                        Text("Data received: \(dataReceivedCount) samples")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    let timeSinceUpdate = Date().timeIntervalSince(lastUpdateTime)
                    if timeSinceUpdate < 3.0 {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.green)
                            Text("Real-time monitoring active")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Waiting for data...")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(.top)
            
            if isCalibrated {
                // Calibrated state - show posture monitoring
                VStack(spacing: 15) {
                    Text("\(state.rawValue)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(state.color)
                    
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 200, height: 200)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: sliderValue / 100)
                            .stroke(state.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: sliderValue)
                        
                        // Center text
                        VStack {
                            Text("\(Int(sliderValue))%")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(state.color)
                            
                            Text("Posture Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    Text(subInfo)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.3), value: subInfo)
                }
            } else {
                // Uncalibrated state - show calibration prompt
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Device Not Calibrated")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Please calibrate your device first to start posture monitoring.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Navigate to calibration
                        // This will be handled by the parent view
                    }) {
                        Text("Go to Calibration")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MonitoringView()
}


