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
            ScrollView {
                VStack(spacing: 24) {
                    // Title section
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        Text(viewModel.hasCalibrationData() ? subtitleText : "No previous calibration data available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(viewModel.hasCalibrationData() ? .gray : .orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Coordinates sections
                    VStack(spacing: 20) {
                        ForEach($coordinates, id: \.id) { coordinate in
                            CalibrationSectionView(coordinate: coordinate)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Connection warning banner
                    if !viewModel.bleManager.getConnectionStatus() {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Connection Warning")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Device is not connected. Please ensure:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("• Device is turned on and nearby")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("• Bluetooth is enabled")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("• No interference from other devices")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(20)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }

                    // Main calibration button
                    Button(action: {
                        withAnimation {
                            showCalibrationCard = true
                        }
                    }) {
                        Text(titleButton)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    
                    // Debug buttons section
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.testBLEDataReception()
                        }) {
                            Text("🔍 Test BLE Data")
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal, 24)
                        }
                        
                        Button(action: {
                            viewModel.runComprehensiveTest()
                        }) {
                            Text("🧪 Test Calibration System")
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Bottom spacing
                    Spacer(minLength: 40)
                }
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

// MARK: - Seated Figure View
struct SeatedFigureView: View {
    enum ArmPosition {
        case up, down
    }
    
    let leftArmPosition: ArmPosition
    let rightArmPosition: ArmPosition
    let leftArmColor: Color
    let rightArmColor: Color
    
    var body: some View {
        ZStack {
            // Chair/seat background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
                .frame(width: 80, height: 20)
                .offset(y: 35)
            
            // Person figure
            VStack(spacing: 0) {
                // Arms (only show when up)
                HStack(spacing: 0) {
                    // Left arm (only show if up)
                    if leftArmPosition == .up {
                        Rectangle()
                            .fill(leftArmColor)
                            .frame(width: 4, height: 40)
                            .rotationEffect(.degrees(-90))
                            .offset(x: -10)
                            .offset(y: -20)
                    }
                    
                    Spacer()
                        .frame(width: 20)
                    
                    // Right arm (only show if up)
                    if rightArmPosition == .up {
                        Rectangle()
                            .fill(rightArmColor)
                            .frame(width: 4, height: 40)
                            .rotationEffect(.degrees(90))
                            .offset(x: 10)
                            .offset(y: -20)
                    }
                }
                .frame(width: 40)
                
                // Head
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                
                // Neck
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 6, height: 8)
                
                // Torso
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 30)
                
                // Hips (seated position)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 24, height: 8)
                    .offset(y: -2)
            }
        }
        .frame(width: 80, height: 80)
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
        .init(title: "Position 1: Both Arms Up", description: "Raise both arms straight up above your head. Keep your back straight and hold this position."),
        .init(title: "Position 2: Right Arm Up", description: "Lower your left arm and keep only your right arm raised straight up above your head."),
        .init(title: "Position 3: Left Arm Up", description: "Lower your right arm and raise only your left arm straight up above your head."),
        .init(title: "Position 4: Both Arms Down", description: "Lower both arms to your sides in a relaxed, natural position.")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🧭 Calibration")
                .font(.title2)
                .fontWeight(.bold)

            Group {
                switch phase {
                case .intro:
                    VStack(spacing: 16) {
                        Text("Arm Position Calibration")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("During calibration, you will be asked to hold 4 different arm positions. Follow the visual guide and hold each position for a few seconds while we collect data.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Preview of all positions
                        HStack(spacing: 16) {
                            ForEach(0..<4, id: \.self) { index in
                                VStack(spacing: 4) {
                                    getPositionVisual(for: index)
                                        .frame(height: 50)
                                    Text("Pos \(index + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 12)
                    }

                case .preparation(let index):
                    VStack(spacing: 20) {
                        Text(positions[index].title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Position visual indicator
                        getPositionVisual(for: index)
                            .frame(height: 100)
                            .padding(.vertical, 8)
                        
                        Text(positions[index].description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Get ready... \(timerValue)s")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }

                case .calibrating(let index):
                    VStack(spacing: 20) {
                        Text(positions[index].title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Position visual indicator
                        getPositionVisual(for: index)
                            .frame(height: 100)
                            .padding(.vertical, 8)
                        
                        Text("Hold the position for calibration.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Calibrating... \(timerValue)s")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                        
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
    
    @ViewBuilder
    private func getPositionVisual(for index: Int) -> some View {
        VStack(spacing: 0) {
            switch index {
            case 0: // Both Arms Up
                SeatedFigureView(
                    leftArmPosition: .up,
                    rightArmPosition: .up,
                    leftArmColor: .white,
                    rightArmColor: .white
                )
                
            case 1: // Right Arm Up
                SeatedFigureView(
                    leftArmPosition: .up,
                    rightArmPosition: .down,
                    leftArmColor: .white,
                    rightArmColor: .white
                )
                
            case 2: // Left Arm Up
                SeatedFigureView(
                    leftArmPosition: .down,
                    rightArmPosition: .up,
                    leftArmColor: .white,
                    rightArmColor: .white
                )
                
            case 3: // Both Arms Down
                SeatedFigureView(
                    leftArmPosition: .down,
                    rightArmPosition: .down,
                    leftArmColor: .white,
                    rightArmColor: .white
                )
                
            default:
                EmptyView()
            }
        }
    }
}

struct CalibrationSectionView: View {
    @Binding var coordinate: Coordinates

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(coordinate.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 0) {
                Spacer()
                CalibrationAxisView(axisTitle: "X", state: $coordinate.x)
                Spacer()
                CalibrationAxisView(axisTitle: "Y", state: $coordinate.y)
                Spacer()
                CalibrationAxisView(axisTitle: "Z", state: $coordinate.z)
                Spacer()
            }
        }
        .padding(20)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(12)
    }
}

struct CalibrationAxisView: View {
    
    var axisTitle: String
    @Binding var state: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(axisTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            Text("\(state > 0 ? "+" : "")\(state)°")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(state > 0 ? Color(red: 0.4, green: 0.9, blue: 0.7) : state < 0 ? .red : .yellow)
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
