//
//  MonitoringViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 07/11/24.
//

import Foundation
import SwiftUI

enum StateMonitoring: String {
    case excellent = "Eccellente"
    case good = "Buono"
    case bad = "Cattivo"

    
    var color: Color {
        switch self {
        case .excellent:
            return Color.green
        case .good:
            return Color.yellow
        case .bad:
            return Color.red
        }
    }
    
    static func from(sliderValue: Double) -> StateMonitoring {
        switch sliderValue {
        case 90...100:
            return .excellent
        case 50..<90:
            return .good
        default:
            return .bad
        }
    }
    
    static func color(from value: Double) -> Color {
        switch value {
        case 90...:
            return Color.green
        case 50..<90:
            return Color.yellow
        default:
            return Color.red
        }
    }
    
    static func color(from value: Int) -> Color {
        switch value {
        case 6...:
            return Color.red
        case 0..<6:
            return Color.yellow
        default:
            return Color.green
        }
    }
}

class MonitoringViewModel: ObservableObject {
    
    @Published var sliderValue: Double = 0 {
        didSet {
            updateState()
        }
    }
    
    @Published var description = "Connecting to device..."
    @Published var isLoader: Bool = false
    @Published var state: StateMonitoring = .bad
    @Published var isPostureCorrect: Bool = false
    @Published var postureConfidence: Double = 0.0
    @Published var isCalibrated: Bool = false
    @Published var connectionStatus: String = "Connecting..."
    @Published var lastUpdateTime: Date = Date()
    @Published var dataReceivedCount: Int = 0
    
    private let bluetoothManager = BluetoothManager()
    private let calibrationStore = CalibrationDataStore.shared
    private var logCounter = 0
    private var lastEvaluationTime = Date()
    private var evaluationInterval: TimeInterval = 0.5 // Evaluate every 0.5 seconds for faster response
    private var lastUIUpdateTime = Date()
    private var uiUpdateInterval: TimeInterval = 0.3 // Update UI every 0.3 seconds for smooth updates
    
    // Cached calibration data for faster access
    private var cachedAccCalibration: CalibrationResult?
    private var cachedMagCalibration: CalibrationResult?
    
    init() {
        setupBluetoothCallbacks()
        loadCalibrationData()
        startConnectionMonitoring()
    }
    
    private func setupBluetoothCallbacks() {
        bluetoothManager.onSensorDataReceived = { [weak self] (sensorData: SensorData) in
            // Process sensor data on background queue for better performance
            DispatchQueue.global(qos: .userInteractive).async {
                self?.handleSensorData(sensorData)
            }
        }
    }
    
    private func startConnectionMonitoring() {
        // Monitor connection status every 5 seconds (less frequent for better performance)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateConnectionStatus()
            }
        }
    }
    
    private func updateConnectionStatus() {
        let connected = bluetoothManager.getConnectionStatus()
        
        if connected {
            connectionStatus = "Connected"
            if !isCalibrated {
                description = "Device connected! Please calibrate your device first."
                sliderValue = 0
                state = .bad
            }
        } else {
            connectionStatus = "Disconnected"
            description = "Device disconnected. Please check your connection."
            sliderValue = 0
            state = .bad
        }
    }
    

    
    private func validateAndFixCalibrationData(accCalibration: CalibrationResult, magCalibration: CalibrationResult) -> (accCalibration: CalibrationResult, magCalibration: CalibrationResult) {
        var fixedAccCalibration = accCalibration
        var fixedMagCalibration = magCalibration
        
        // Fix accelerometer threshold if needed
        if accCalibration.threshold <= 1e-10 {
            print("⚠️ Accelerometer threshold too low (\(accCalibration.threshold)), applying minimum threshold")
            fixedAccCalibration.threshold = 1e-10
        }
        
        // Fix magnetometer threshold if needed
        if magCalibration.threshold <= 1e-10 {
            print("⚠️ Magnetometer threshold too low (\(magCalibration.threshold)), applying minimum threshold")
            fixedMagCalibration.threshold = 1e-10
        }
        
        // Fix determinant if needed
        if accCalibration.det <= 1e-10 {
            print("⚠️ Accelerometer determinant too low (\(accCalibration.det)), applying minimum determinant")
            fixedAccCalibration.det = 1e-10
        }
        
        if magCalibration.det <= 1e-10 {
            print("⚠️ Magnetometer determinant too low (\(magCalibration.det)), applying minimum determinant")
            fixedMagCalibration.det = 1e-10
        }
        
        // Fix eigenvalues/sigma if needed
        for i in 0..<3 {
            if accCalibration.sigma[i] <= 1e-10 {
                print("⚠️ Accelerometer sigma[\(i)] too low (\(accCalibration.sigma[i])), applying minimum sigma")
                fixedAccCalibration.sigma[i] = 1e-10
            }
            
            if magCalibration.sigma[i] <= 1e-10 {
                print("⚠️ Magnetometer sigma[\(i)] too low (\(magCalibration.sigma[i])), applying minimum sigma")
                fixedMagCalibration.sigma[i] = 1e-10
            }
        }
        
        return (fixedAccCalibration, fixedMagCalibration)
    }
    
    private func loadCalibrationData() {
        // Load calibration data from store
        isCalibrated = calibrationStore.hasCalibrationData()
        
        if isCalibrated {
            // Cache calibration data for faster access
            cachedAccCalibration = calibrationStore.getAccCalibration()
            cachedMagCalibration = calibrationStore.getMagCalibration()
            
            // Validate and fix calibration data if needed
            if let accCal = cachedAccCalibration, let magCal = cachedMagCalibration {
                let (fixedAccCal, fixedMagCal) = validateAndFixCalibrationData(accCalibration: accCal, magCalibration: magCal)
                
                // Update cached data with fixed values
                cachedAccCalibration = fixedAccCal
                cachedMagCalibration = fixedMagCal
                
                // Check if any fixes were applied
                let accWasFixed = accCal.threshold != fixedAccCal.threshold || accCal.det != fixedAccCal.det
                let magWasFixed = magCal.threshold != fixedMagCal.threshold || magCal.det != fixedMagCal.det
                
                if accWasFixed || magWasFixed {
                    print("⚠️ Calibration data was automatically fixed due to invalid values")
                    description = "Calibration data was corrected. Consider recalibrating for better accuracy."
                }
                
                let isValid = validateCalibrationData(accCalibration: fixedAccCal, magCalibration: fixedMagCal)
                if !isValid {
                    print("⚠️ WARNING: Calibration data appears to be invalid even after fixing!")
                    description = "Calibration data appears invalid. Please recalibrate."
                    return
                }
                
                description = "Monitoring your posture..."
                print("✅ Calibration data loaded, fixed, and validated successfully")
                
                // Test the calibration data by calculating density with mean values
                testCalibrationData(accCalibration: fixedAccCal, magCalibration: fixedMagCal)
            }
        } else {
            description = "Device connected! Please calibrate your device first."
            print("⚠️ No calibration data available")
        }
    }
    
    private func validateCalibrationData(accCalibration: CalibrationResult, magCalibration: CalibrationResult) -> Bool {
        print("🔍 Validating calibration data...")
        
        var isValid = true
        
        // Check accelerometer calibration
        if accCalibration.threshold <= 0 {
            print("❌ Invalid accelerometer threshold: \(accCalibration.threshold)")
            isValid = false
        }
        
        if accCalibration.det <= 0 {
            print("❌ Invalid accelerometer determinant: \(accCalibration.det)")
            isValid = false
        }
        
        // Check magnetometer calibration
        if magCalibration.threshold <= 0 {
            print("❌ Invalid magnetometer threshold: \(magCalibration.threshold)")
            isValid = false
        }
        
        if magCalibration.det <= 0 {
            print("❌ Invalid magnetometer determinant: \(magCalibration.det)")
            isValid = false
        }
        
        // Check mean vectors
        for (i, value) in accCalibration.vMedia.enumerated() {
            if value.isNaN || value.isInfinite {
                print("❌ Invalid accelerometer mean[\(i)]: \(value)")
                isValid = false
            }
        }
        
        for (i, value) in magCalibration.vMedia.enumerated() {
            if value.isNaN || value.isInfinite {
                print("❌ Invalid magnetometer mean[\(i)]: \(value)")
                isValid = false
            }
        }
        
        if isValid {
            print("✅ Calibration data validation passed")
        } else {
            print("❌ Calibration data validation failed")
        }
        
        return isValid
    }
    
    private func testCalibrationData(accCalibration: CalibrationResult, magCalibration: CalibrationResult) {
        print("🧪 Testing calibration data...")
        
        // Test with the mean values (should give high density)
        let accDensityWithMean = CalibrationMath.computeDensity(
            val: accCalibration.vMedia,
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        
        let magDensityWithMean = CalibrationMath.computeDensity(
            val: magCalibration.vMedia,
            vMedia: magCalibration.vMedia,
            det: magCalibration.det,
            mInv: magCalibration.mInv
        )
        
        print("🧪 Test results with mean values:")
        print("   Acc density with mean: \(String(format: "%.6e", accDensityWithMean))")
        print("   Acc threshold: \(String(format: "%.6e", accCalibration.threshold))")
        print("   Acc ratio: \(accDensityWithMean / accCalibration.threshold)")
        print("   Mag density with mean: \(String(format: "%.6e", magDensityWithMean))")
        print("   Mag threshold: \(String(format: "%.6e", magCalibration.threshold))")
        print("   Mag ratio: \(magDensityWithMean / magCalibration.threshold)")
        
        // Test with slightly different values
        let testAcc = accCalibration.vMedia.map { $0 + 0.1 }
        let testMag = magCalibration.vMedia.map { $0 + 1.0 }
        
        let accDensityWithOffset = CalibrationMath.computeDensity(
            val: testAcc,
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        
        let magDensityWithOffset = CalibrationMath.computeDensity(
            val: testMag,
            vMedia: magCalibration.vMedia,
            det: magCalibration.det,
            mInv: magCalibration.mInv
        )
        
        print("🧪 Test results with offset values:")
        print("   Acc density with offset: \(String(format: "%.6e", accDensityWithOffset))")
        print("   Acc ratio: \(accDensityWithOffset / accCalibration.threshold)")
        print("   Mag density with offset: \(String(format: "%.6e", magDensityWithOffset))")
        print("   Mag ratio: \(magDensityWithOffset / magCalibration.threshold)")
    }
    
    private func handleSensorData(_ sensorData: SensorData) {
        guard isCalibrated,
              let accCalibration = cachedAccCalibration,
              let magCalibration = cachedMagCalibration else {
            return
        }
        
        // Update data counter
        dataReceivedCount += 1
        lastUpdateTime = Date()
        
        // Only evaluate posture at specified intervals for performance
        let timeSinceLastEvaluation = Date().timeIntervalSince(lastEvaluationTime)
        guard timeSinceLastEvaluation >= evaluationInterval else { return }
        
        lastEvaluationTime = Date()
        
        // Convert to arrays for the algorithm
        let arrays = sensorData.toArrays()
        
        // Log only every 50th evaluation to reduce spam
        logCounter += 1
        let shouldLog = logCounter % 50 == 0
        
        if shouldLog {
            print("📊 Evaluating posture (sample #\(dataReceivedCount))")
        }
        
        // Evaluate posture according to documentation: 
        // Posture is incorrect only if BOTH sensors give values below threshold
        let (isCorrect, accDensity, magDensity) = evaluatePostureAccordingToDocumentation(
            accData: arrays.acc,
            magData: arrays.mag,
            accCalibration: accCalibration,
            magCalibration: magCalibration,
            shouldLog: shouldLog
        )
        
        // Generate posture advice
        let advice = generatePostureAdvice(
            accData: arrays.acc,
            magData: arrays.mag,
            accDensity: accDensity,
            magDensity: magDensity,
            accThreshold: accCalibration.threshold,
            magThreshold: magCalibration.threshold
        )
        
        // Calculate score based on densities vs thresholds
        let score = calculateScoreFromDensities(
            accDensity: accDensity, 
            magDensity: magDensity,
            accThreshold: accCalibration.threshold,
            magThreshold: magCalibration.threshold
        )
        
        // Update UI immediately for faster response
        DispatchQueue.main.async {
            self.updatePostureDisplayWithAdvice(isCorrect: isCorrect, score: score, advice: advice)
        }
    }
    
    private func calculateDistance(from data: [Double], to mean: [Double]) -> Double {
        var sum = 0.0
        for i in 0..<3 {
            let diff = data[i] - mean[i]
            sum += diff * diff
        }
        return sqrt(sum)
    }
    
    private func applyBasicPostureFactors(score: Double, accData: [Double]) -> Double {
        var adjustedScore = score
        
        // Factor 1: Vertical alignment (accelerometer Z should be close to 9.8)
        let verticalAlignment = abs(accData[2] - 9.8)
        if verticalAlignment > 1.5 {
            adjustedScore -= 20 // Significant penalty for poor vertical alignment
        } else if verticalAlignment < 0.3 {
            adjustedScore += 10 // Bonus for excellent vertical alignment
        }
        
        // Factor 2: Stability (small horizontal variations are good)
        let horizontalStability = sqrt(accData[0] * accData[0] + accData[1] * accData[1])
        if horizontalStability > 1.0 {
            adjustedScore -= 15 // Penalty for unstable position
        } else if horizontalStability < 0.2 {
            adjustedScore += 5 // Bonus for very stable position
        }
        
        return adjustedScore
    }
    
    private func evaluatePostureAccordingToDocumentation(accData: [Double], magData: [Double], 
                                                        accCalibration: CalibrationResult, 
                                                        magCalibration: CalibrationResult,
                                                        shouldLog: Bool) -> (isCorrect: Bool, accDensity: Double, magDensity: Double) {
        
        // Calculate densities using the original algorithm
        let accDensity = CalibrationMath.computeDensity(
            val: accData,
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        
        let magDensity = CalibrationMath.computeDensity(
            val: magData,
            vMedia: magCalibration.vMedia,
            det: magCalibration.det,
            mInv: magCalibration.mInv
        )
        
        // Fix for invalid thresholds - use minimum thresholds if calibration is invalid
        let accThreshold = accCalibration.threshold > 0 ? accCalibration.threshold : 1e-10
        let magThreshold = magCalibration.threshold > 0 ? magCalibration.threshold : 1e-10
        
        // According to documentation: Posture is incorrect only if BOTH sensors give values below threshold
        let accCorrect = accDensity >= accThreshold
        let magCorrect = magDensity >= magThreshold
        
        // Posture is correct if at least one sensor gives correct posture
        // (This means posture is INCORRECT only if BOTH sensors are below threshold)
        let isCorrect = accCorrect || magCorrect
        
        // Only log detailed evaluation occasionally
        if shouldLog {
            print("📊 Posture evaluation details:")
            print("   Acc density: \(String(format: "%.6e", accDensity))")
            print("   Acc threshold: \(String(format: "%.6e", accThreshold))")
            print("   Acc correct: \(accCorrect)")
            print("   Mag density: \(String(format: "%.6e", magDensity))")
            print("   Mag threshold: \(String(format: "%.6e", magThreshold))")
            print("   Mag correct: \(magCorrect)")
            print("   Final result: \(isCorrect ? "CORRECT" : "INCORRECT")")
        }
        
        return (isCorrect, accDensity, magDensity)
    }
    
    private func calculateScoreFromDensities(accDensity: Double, magDensity: Double, 
                                           accThreshold: Double, magThreshold: Double) -> Double {
        
        // Use corrected thresholds (minimum values if original is invalid)
        let correctedAccThreshold = accThreshold > 0 ? accThreshold : 1e-10
        let correctedMagThreshold = magThreshold > 0 ? magThreshold : 1e-10
        
        // Calculate how much each sensor is above/below its threshold
        let accRatio = accDensity / correctedAccThreshold
        let magRatio = magDensity / correctedMagThreshold
        
        // Convert ratios to scores (above threshold = good, below threshold = bad)
        let accScore = max(0, min(100, accRatio * 100))
        let magScore = max(0, min(100, magRatio * 100))
        
        // Weighted average (accelerometer is more important for posture)
        let weightedScore = (accScore * 0.8) + (magScore * 0.2)
        
        // Apply scoring logic: scores above 100 (above threshold) get bonus, below 100 get penalty
        var finalScore = weightedScore
        
        if weightedScore >= 100 {
            // Above threshold - bonus for excellent posture
            finalScore = min(100, weightedScore + 10)
        } else if weightedScore >= 80 {
            // Close to threshold - good posture
            finalScore = weightedScore
        } else if weightedScore >= 60 {
            // Below threshold but not too bad - fair posture
            finalScore = weightedScore - 10
        } else {
            // Well below threshold - poor posture
            finalScore = max(0, weightedScore - 20)
        }
        
        return finalScore
    }
    
    private func updatePostureDisplay(isCorrect: Bool, score: Double) {
        // Update immediately for faster response
        sliderValue = score
        isPostureCorrect = isCorrect
        
        // Determine state based on score ranges and correctness
        if isCorrect && score >= 90 {
            state = .excellent
            description = "Excellent posture! Keep it up! 🎉"
        } else if isCorrect && score >= 75 {
            state = .good
            description = "Good posture! Minor adjustments needed 💪"
        } else if isCorrect && score >= 60 {
            state = .good
            description = "Fair posture. Try to sit up straighter 📏"
        } else if !isCorrect {
            state = .bad
            description = "Poor posture. Please adjust your position ⚠️"
        } else {
            state = .bad
            description = "Posture needs improvement 📏"
        }
    }
    
    private func updatePostureDisplayWithAdvice(isCorrect: Bool, score: Double, advice: PostureAdvice) {
        // Update immediately for faster response
        sliderValue = score
        isPostureCorrect = isCorrect
        
        // Simplified description for faster updates
        let statusEmoji = isCorrect ? "✅" : "⚠️"
        let statusText = isCorrect ? "Good" : "Poor"
        
        // Determine state based on score for faster response
        if score >= 90 {
            state = .excellent
            description = "\(statusEmoji) Excellent posture! Keep it up!"
        } else if score >= 75 {
            state = .good
            description = "\(statusEmoji) Good posture! Minor adjustments needed"
        } else if score >= 60 {
            state = .good
            description = "\(statusEmoji) Fair posture. Try to sit up straighter"
        } else {
            state = .bad
            description = "\(statusEmoji) Poor posture. Please adjust your position"
        }
        
        // Add score information
        description += "\nScore: \(Int(score))%"
    }
    
    func updateSliderValue(fromAPI value: Double) {
        self.sliderValue = value
        self.updateState()
    }
    
    private func updateState() {
        self.state = StateMonitoring.from(sliderValue: sliderValue)
    }
    
    // MARK: - Posture Advice System
    struct PostureAdvice {
        let title: String
        let description: String
        let priority: AdvicePriority
        let specificAction: String
    }
    
    enum AdvicePriority {
        case critical    // Red - immediate action needed
        case important   // Orange - should fix soon
        case moderate    // Yellow - minor adjustment
        case good        // Green - maintaining good posture
        case excellent   // Blue - perfect posture
    }
    
    private func generatePostureAdvice(accData: [Double], magData: [Double], 
                                      accDensity: Double, magDensity: Double,
                                      accThreshold: Double, magThreshold: Double) -> PostureAdvice {
        
        // Analyze accelerometer data for specific posture issues
        let accAnalysis = analyzeAccelerometerData(accData)
        let magAnalysis = analyzeMagnetometerData(magData)
        
        // Determine overall posture quality
        let accCorrect = accDensity >= accThreshold
        let magCorrect = magDensity >= magThreshold
        let overallQuality = calculateOverallQuality(accAnalysis: accAnalysis, magAnalysis: magAnalysis)
        
        // Generate specific advice based on analysis
        if !accCorrect && !magCorrect {
            // Both sensors indicate poor posture
            return PostureAdvice(
                title: "Postura Scorretta",
                description: "Entrambi i sensori rilevano una postura non ottimale.",
                priority: .critical,
                specificAction: generateSpecificAction(accAnalysis: accAnalysis, magAnalysis: magAnalysis)
            )
        } else if !accCorrect {
            // Only accelerometer indicates poor posture
            return PostureAdvice(
                title: "Aggiustamento Necessario",
                description: "La posizione del busto necessita di correzione.",
                priority: .important,
                specificAction: generateAccelerometerAction(accAnalysis: accAnalysis)
            )
        } else if !magCorrect {
            // Only magnetometer indicates poor posture
            return PostureAdvice(
                title: "Orientamento da Correggere",
                description: "L'orientamento del dispositivo suggerisce un aggiustamento.",
                priority: .moderate,
                specificAction: generateMagnetometerAction(magAnalysis: magAnalysis)
            )
        } else if overallQuality >= 0.8 {
            // Excellent posture
            return PostureAdvice(
                title: "Postura Perfetta!",
                description: "Ottimo lavoro! Mantieni questa posizione.",
                priority: .excellent,
                specificAction: "Continua così! La tua postura è esemplare."
            )
        } else {
            // Good but could be better
            return PostureAdvice(
                title: "Postura Buona",
                description: "La tua postura è buona, ma può essere migliorata.",
                priority: .good,
                specificAction: generateImprovementAction(accAnalysis: accAnalysis, magAnalysis: magAnalysis)
            )
        }
    }
    
    private func analyzeAccelerometerData(_ accData: [Double]) -> [String: Double] {
        var analysis: [String: Double] = [:]
        
        // Vertical alignment (Z should be close to 9.8)
        let verticalAlignment = abs(accData[2] - 9.8)
        analysis["verticalAlignment"] = verticalAlignment
        
        // Horizontal stability (X and Y should be small)
        let horizontalStability = sqrt(accData[0] * accData[0] + accData[1] * accData[1])
        analysis["horizontalStability"] = horizontalStability
        
        // Forward/backward tilt (Y component)
        analysis["forwardTilt"] = abs(accData[1])
        
        // Side tilt (X component)
        analysis["sideTilt"] = abs(accData[0])
        
        return analysis
    }
    
    private func analyzeMagnetometerData(_ magData: [Double]) -> [String: Double] {
        var analysis: [String: Double] = [:]
        
        // Calculate magnitude for orientation analysis
        let magnitude = sqrt(magData[0] * magData[0] + magData[1] * magData[1] + magData[2] * magData[2])
        analysis["magnitude"] = magnitude
        
        // Orientation stability (variation from expected values)
        // These are approximate values - should be calibrated based on your device
        let expectedX = 25.0
        let expectedY = 536.0
        let expectedZ = 600.0
        
        analysis["xDeviation"] = abs(magData[0] - expectedX)
        analysis["yDeviation"] = abs(magData[1] - expectedY)
        analysis["zDeviation"] = abs(magData[2] - expectedZ)
        
        return analysis
    }
    
    private func calculateOverallQuality(accAnalysis: [String: Double], magAnalysis: [String: Double]) -> Double {
        var quality = 1.0
        
        // Vertical alignment penalty
        if let verticalAlignment = accAnalysis["verticalAlignment"] {
            if verticalAlignment > 2.0 {
                quality -= 0.4
            } else if verticalAlignment > 1.0 {
                quality -= 0.2
            } else if verticalAlignment > 0.5 {
                quality -= 0.1
            }
        }
        
        // Horizontal stability penalty
        if let horizontalStability = accAnalysis["horizontalStability"] {
            if horizontalStability > 2.0 {
                quality -= 0.3
            } else if horizontalStability > 1.0 {
                quality -= 0.15
            } else if horizontalStability > 0.5 {
                quality -= 0.05
            }
        }
        
        // Forward tilt penalty
        if let forwardTilt = accAnalysis["forwardTilt"] {
            if forwardTilt > 1.5 {
                quality -= 0.3
            } else if forwardTilt > 0.8 {
                quality -= 0.15
            }
        }
        
        return max(0.0, quality)
    }
    
    private func generateSpecificAction(accAnalysis: [String: Double], magAnalysis: [String: Double]) -> String {
        var actions: [String] = []
        
        // Check vertical alignment
        if let verticalAlignment = accAnalysis["verticalAlignment"], verticalAlignment > 1.5 {
            actions.append("Raddrizza la schiena - mantieni la testa alta")
        }
        
        // Check forward tilt
        if let forwardTilt = accAnalysis["forwardTilt"], forwardTilt > 1.0 {
            actions.append("Tira indietro le spalle - non piegarti in avanti")
        }
        
        // Check side tilt
        if let sideTilt = accAnalysis["sideTilt"], sideTilt > 0.8 {
            actions.append("Bilancia il peso - non inclinarti da un lato")
        }
        
        // Check horizontal stability
        if let horizontalStability = accAnalysis["horizontalStability"], horizontalStability > 1.5 {
            actions.append("Stabilizza la posizione - evita movimenti eccessivi")
        }
        
        if actions.isEmpty {
            return "Fai un respiro profondo e raddrizza la postura"
        }
        
        return actions.joined(separator: "\n• ")
    }
    
    private func generateAccelerometerAction(accAnalysis: [String: Double]) -> String {
        var actions: [String] = []
        
        if let verticalAlignment = accAnalysis["verticalAlignment"], verticalAlignment > 1.0 {
            actions.append("Raddrizza la schiena")
        }
        
        if let forwardTilt = accAnalysis["forwardTilt"], forwardTilt > 0.8 {
            actions.append("Tira indietro le spalle")
        }
        
        if let horizontalStability = accAnalysis["horizontalStability"], horizontalStability > 1.0 {
            actions.append("Stabilizza la posizione")
        }
        
        return actions.isEmpty ? "Migliora l'allineamento verticale" : actions.joined(separator: "\n• ")
    }
    
    private func generateMagnetometerAction(magAnalysis: [String: Double]) -> String {
        return "Aggiusta l'orientamento del dispositivo o la posizione del busto"
    }
    
    private func generateImprovementAction(accAnalysis: [String: Double], magAnalysis: [String: Double]) -> String {
        var suggestions: [String] = []
        
        if let verticalAlignment = accAnalysis["verticalAlignment"], verticalAlignment > 0.5 {
            suggestions.append("Migliora l'allineamento verticale")
        }
        
        if let horizontalStability = accAnalysis["horizontalStability"], horizontalStability > 0.5 {
            suggestions.append("Riduci i movimenti laterali")
        }
        
        if suggestions.isEmpty {
            return "Mantieni questa buona postura"
        }
        
        return suggestions.joined(separator: "\n• ")
    }
}
