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
    @State private var showCalibrationCard = false
    @ObservedObject var viewModel: CalibrationViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Text(viewModel.hasCalibrationData() ? subtitleText : "No previous calibration data available")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.hasCalibrationData() ? .primary : .orange)
                    .padding(.top)

                VStack(spacing: 30) {
                    ForEach($coordinates, id: \.id) { coordinate in
                        CalibrationSectionView(coordinate: coordinate)
                    }
                }
                .padding(.horizontal)
                
                // Connection warning banner
                if !viewModel.bleManager.getConnectionStatus() {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Connection Warning")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Device is not connected. Please ensure:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Device is turned on and nearby")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Bluetooth is enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• No interference from other devices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                Button(action: {
                    withAnimation {
                        showCalibrationCard = true
                    }
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
                
                // Debug button
                Button(action: {
                    viewModel.testBLEDataReception()
                }) {
                    Text("🔍 Test BLE Data")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 10)
                
                // System test button
                Button(action: {
                    viewModel.runComprehensiveTest()
                }) {
                    Text("🧪 Test Calibration System")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            .blur(radius: showCalibrationCard ? 3 : 0)

            if showCalibrationCard {
                CalibrationCard(show: $showCalibrationCard, viewModel: viewModel)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showCalibrationCard)
    }
}

struct CalibrationCard: View {
    @Binding var show: Bool
    @ObservedObject var viewModel: CalibrationViewModel

    enum CalibrationPhase {
        case intro
        case preparation(Int) // positionIndex
        case calibrating(Int)
        case transitionMessage(Int) // after calibration, before next preparation
        case done
    }
    
    let transitionMessages = [
        "Great job! You're almost done with this position.",
        "Nice work! Get ready for the next position.",
        "Well done! Take a moment before the next one.",
        "Well done! we saved your calibration into the cloud"
    ]

    struct PositionInstruction {
        let title: String
        let description: String
    }

    @State private var phase: CalibrationPhase = .intro
    @State private var timerValue: Int = 0
    @State private var currentPosition: Int = 0
    @State private var timer: Timer?

    let preparationDuration = 3
    let calibrationDuration = 3

    let positions: [PositionInstruction] = [
        .init(title: "Position 1", description: "Sit straight with your back against the chair."),
        .init(title: "Position 2", description: "Lean your back slightly forward."),
        .init(title: "Position 3", description: "Relax your shoulders and let your torso drop."),
        .init(title: "Position 4", description: "Return to a neutral, relaxed position.")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🧭 Calibration")
                .font(.title2)
                .fontWeight(.bold)

            Group {
                switch phase {
                case .intro:
                    Text("During calibration, you will be asked to hold 4 different positions. Follow the instructions and hold each position for a few seconds while we collect data.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                case .preparation(let index):
                    VStack(spacing: 10) {
                        Text(positions[index].title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(positions[index].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("Get ready... \(timerValue)s")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }

                case .calibrating(let index):
                    VStack(spacing: 10) {
                        Text(positions[index].title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Hold the position for calibration.")
                        Text("Calibrating... \(timerValue)s")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        // Show calibration status
                        if !viewModel.calibrationStatus.isEmpty {
                            Text(viewModel.calibrationStatus)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Show collection progress
                        let progress = viewModel.getCollectionProgress()
                        if progress.isCollecting {
                            VStack(spacing: 5) {
                                Text("📊 Collecting data...")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("Acc: \(progress.accCount) | Mag: \(progress.magCount)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                case .transitionMessage(let index):
                    VStack(spacing: 10) {
                        Text(transitionMessages[index])
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Start next position") {
                            let nextIndex = index + 1
                            if nextIndex < positions.count {
                                startPreparation(for: nextIndex)
                            } else {
                                phase = .done
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                case .done:
                    VStack(spacing: 10) {
                        Text("✅ Calibration complete!")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("You can now proceed.")
                        
                        if !viewModel.calibrationStatus.isEmpty {
                            Text(viewModel.calibrationStatus)
                                .font(.caption)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
            }

            Spacer()

            Group {
                switch phase {
                case .intro:
                    Button("Start Calibration") {
                        startPreparation(for: 0)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                case .preparation, .calibrating:
                    EmptyView()

                case .transitionMessage:
                    EmptyView()

                case .done:
                    Button("Continue") {
                        show = false
                        // Navigate to next screen
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }

            if case .done = phase {
                EmptyView()
            } else {
                Button("Cancel Calibration") {
                    cancelCalibration()
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Main functions

    private func startCalibration(for index: Int) {
        phase = .calibrating(index)
        
        // Start data collection only during actual calibration phase
        viewModel.startPositionCalibration()
        
        startTimer(duration: calibrationDuration) {
            // Stop data collection when calibration phase ends
            viewModel.stopPositionCalibration()
            phase = .transitionMessage(index)
        }
    }
    
    private func startPreparation(for index: Int) {
        currentPosition = index
        phase = .preparation(index)
        startTimer(duration: preparationDuration) {
            startCalibration(for: index)
        }
    }

    private func startTimer(duration: Int, completion: @escaping () -> Void) {
        timer?.invalidate()
        timerValue = duration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer?.invalidate()
                completion()
            }
        }
    }

    private func cancelCalibration() {
        timer?.invalidate()
        viewModel.isCalibrating = false
        show = false
        // Reset states if needed
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

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

#Preview {
    CalibrationView()
}
