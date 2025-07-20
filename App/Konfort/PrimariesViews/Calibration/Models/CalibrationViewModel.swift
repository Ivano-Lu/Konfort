//
//  CalibrationViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 18/11/24.
//

import SwiftUI



struct Coordinates {
    var id = UUID()
    var name: String
    var x: Int
    var y: Int
    var z: Int
}

class CalibrationViewModel: ObservableObject {
    
    var title = "Calibrating the device is essential to ensure that the data accurately reflects your unique posture!"
    
    var subtitle = "Your current calibration"
    
    var titleButton = "Start calibration"
    
    @Published var coordinates: [Coordinates] = []
    @Published var isCalibrating = false
    @Published var calibrationProgress: Double = 0.0
    @Published var calibrationStatus = ""
    
    private let bluetoothManager = BluetoothManager()
    private let calibrationService = CalibrationService.shared
    private let calibrationStore = CalibrationDataStore.shared
    
    // Make bluetoothManager accessible for view
    var bleManager: BluetoothManager {
        return bluetoothManager
    }
    
    // Accumulated data from all positions
    private var accumulatedAccSamples: [[Double]] = []
    private var accumulatedMagSamples: [[Double]] = []
    private var currentPositionIndex = 0
    
    init() {
        calculateValues()
        setupBluetoothCallbacks()
    }
    
    private func setupBluetoothCallbacks() {
        bluetoothManager.onSensorDataReceived = { [weak self] (sensorData: SensorData) in
            DispatchQueue.main.async {
                self?.updateCoordinates(with: sensorData)
            }
        }
    }
    
    private func calculateValues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            // Check if user is logged in and load calibration data from backend
            let currentUserId = UserDefaults.standard.integer(forKey: "userId")
            if currentUserId > 0 {
                print("👤 User logged in (ID: \(currentUserId)), loading calibration data from backend...")
                self?.loadCalibrationData()
            } else {
                print("👤 No user logged in, skipping backend calibration data load")
            }
            
            // Initialize with placeholder values
            self?.coordinates.append(Coordinates(name: "Accellerometers", x: 0, y: 0, z: 0))
            self?.coordinates.append(Coordinates(name: "Magnetometers", x: 0, y: 0, z: 0))
        }
    }
    
    private func updateCoordinates(with sensorData: SensorData) {
        // Only update coordinates if we're in calibration mode
        guard isCalibrating else { return }
        
        // Update accelerometer coordinates
        if coordinates.count > 0 {
            coordinates[0].x = Int(sensorData.acc.x * 100)
            coordinates[0].y = Int(sensorData.acc.y * 100)
            coordinates[0].z = Int(sensorData.acc.z * 100)
        }
        
        // Update magnetometer coordinates
        if coordinates.count > 1 {
            coordinates[1].x = Int(sensorData.mag.x)
            coordinates[1].y = Int(sensorData.mag.y)
            coordinates[1].z = Int(sensorData.mag.z)
        }
    }
    
    private func updateCoordinatesFromCalibration() {
        guard let accCalibration = calibrationStore.getAccCalibration(),
              let magCalibration = calibrationStore.getMagCalibration() else {
            // No calibration data available
            if coordinates.count > 0 {
                coordinates[0].x = 0
                coordinates[0].y = 0
                coordinates[0].z = 0
            }
            if coordinates.count > 1 {
                coordinates[1].x = 0
                coordinates[1].y = 0
                coordinates[1].z = 0
            }
            return
        }
        
        // Update accelerometer coordinates from saved calibration
        if coordinates.count > 0 {
            coordinates[0].x = Int(accCalibration.vMedia[0] * 100)
            coordinates[0].y = Int(accCalibration.vMedia[1] * 100)
            coordinates[0].z = Int(accCalibration.vMedia[2] * 100)
        }
        
        // Update magnetometer coordinates from saved calibration
        if coordinates.count > 1 {
            coordinates[1].x = Int(magCalibration.vMedia[0])
            coordinates[1].y = Int(magCalibration.vMedia[1])
            coordinates[1].z = Int(magCalibration.vMedia[2])
        }
    }
    
    // MARK: - Calibration Methods
    func startCalibration() {
        print("🎯 Starting calibration process...")
        guard bluetoothManager.getConnectionStatus() else {
            print("❌ Device not connected - cannot start calibration")
            calibrationStatus = "❌ Device not connected - please check your connection"
            return
        }
        
        print("✅ Device is connected, starting data collection...")
        isCalibrating = true
        calibrationProgress = 0.0
        calibrationStatus = "🔄 Starting calibration... Please hold your device steady and don't move"
        
        // Reset accumulated data
        accumulatedAccSamples.removeAll()
        accumulatedMagSamples.removeAll()
        currentPositionIndex = 0
        
        // Enable detailed logging
        calibrationService.setCollectingMode(true)
        
        // Start data collection (this will disable connection monitoring)
        bluetoothManager.startDataCollection()
        
        // Start a timer to monitor collection progress
        startCollectionMonitoring()
    }
    
    private func startCollectionMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let progress = self.bluetoothManager.getCollectionProgress()
            print("📊 Collection progress - Acc: \(progress.accCount), Mag: \(progress.magCount), Active: \(progress.isCollecting)")
            
            if !progress.isCollecting {
                timer.invalidate()
                print("📊 Data collection stopped")
            }
        }
    }
    
    func stopCalibration() {
        print("🛑 Stopping calibration process...")
        isCalibrating = false
        
        // Disable detailed logging
        calibrationService.setCollectingMode(false)
        
        // Stop data collection and get samples (this will re-enable connection monitoring)
        let (accSamples, magSamples) = bluetoothManager.stopDataCollection()
        
        print("📊 Calibration results - Acc samples: \(accSamples.count), Mag samples: \(magSamples.count)")
        
        // Assess calibration quality
        let (isValid, issues) = bluetoothManager.assessCalibrationQuality()
        
        if !isValid {
            print("❌ Calibration quality assessment failed:")
            for issue in issues {
                print("   - \(issue)")
            }
            calibrationStatus = "❌ Calibration quality issues detected. Please try again with stable connection."
            return
        }
        
        if !issues.isEmpty {
            print("⚠️ Calibration quality warnings:")
            for issue in issues {
                print("   - \(issue)")
            }
            calibrationStatus = "⚠️ Calibration completed with warnings. Consider recalibrating for better accuracy."
            
            // Provide specific recommendations
            let recommendations = generateCalibrationRecommendations(issues: issues)
            if !recommendations.isEmpty {
                print("💡 Recommendations for better calibration:")
                for recommendation in recommendations {
                    print("   - \(recommendation)")
                }
            }
        }
        
        guard !accSamples.isEmpty && !magSamples.isEmpty else {
            print("❌ No data collected during calibration")
            calibrationStatus = "❌ No data collected - please ensure device is connected and sending data"
            return
        }
        
        guard accSamples.count >= 3 && magSamples.count >= 3 else {
            print("❌ Insufficient data collected - need at least 3 samples")
            calibrationStatus = "❌ Insufficient data - please hold position longer"
            return
        }
        
        calibrationStatus = "🧮 Computing calibration values..."
        print("🧮 Computing calibration with \(accSamples.count) accelerometer and \(magSamples.count) magnetometer samples")
        
        // Compute calibration values
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("🧮 Starting calibration computation...")
            
            // Enable detailed logging for calibration
            CalibrationMath.enableDetailedLogging = true
            
            let accCalibration = CalibrationMath.computeCalibration(from: accSamples)
            let magCalibration = CalibrationMath.computeCalibration(from: magSamples)
            
            // Disable detailed logging after calibration
            CalibrationMath.enableDetailedLogging = false
            
            print("✅ Calibration computed successfully")
            print("📊 Accelerometer calibration details:")
            print("   Mean vector: [\(String(format: "%.6f", accCalibration.vMedia[0])), \(String(format: "%.6f", accCalibration.vMedia[1])), \(String(format: "%.6f", accCalibration.vMedia[2]))]")
            print("   Determinant: \(String(format: "%.6e", accCalibration.det))")
            print("   Threshold: \(String(format: "%.6e", accCalibration.threshold))")
            print("   Sigma: [\(String(format: "%.6f", accCalibration.sigma[0])), \(String(format: "%.6f", accCalibration.sigma[1])), \(String(format: "%.6f", accCalibration.sigma[2]))]")
            
            print("📊 Magnetometer calibration details:")
            print("   Mean vector: [\(String(format: "%.6f", magCalibration.vMedia[0])), \(String(format: "%.6f", magCalibration.vMedia[1])), \(String(format: "%.6f", magCalibration.vMedia[2]))]")
            print("   Determinant: \(String(format: "%.6e", magCalibration.det))")
            print("   Threshold: \(String(format: "%.6e", magCalibration.threshold))")
            print("   Sigma: [\(String(format: "%.6f", magCalibration.sigma[0])), \(String(format: "%.6f", magCalibration.sigma[1])), \(String(format: "%.6f", magCalibration.sigma[2]))]")
            
            DispatchQueue.main.async {
                self?.saveCalibrationData(accCalibration: accCalibration, magCalibration: magCalibration)
            }
        }
    }
    
    // MARK: - Position-based Calibration
    func startPositionCalibration() {
        print("📊 Starting data collection for position \(currentPositionIndex + 1)...")
        bluetoothManager.startDataCollection()
    }
    
    func stopPositionCalibration() {
        print("📊 Stopping data collection for position \(currentPositionIndex + 1)...")
        let (accSamples, magSamples) = bluetoothManager.stopDataCollection()
        
        // Accumulate data from this position
        accumulatedAccSamples.append(contentsOf: accSamples)
        accumulatedMagSamples.append(contentsOf: magSamples)
        
        print("📊 Position \(currentPositionIndex + 1) samples - Acc: \(accSamples.count), Mag: \(magSamples.count)")
        print("📊 Total accumulated samples - Acc: \(accumulatedAccSamples.count), Mag: \(accumulatedMagSamples.count)")
        
        currentPositionIndex += 1
        
        // If this was the last position, process all accumulated data
        if currentPositionIndex >= 4 { // 4 positions total
            processAccumulatedCalibrationData()
        }
    }
    
    private func processAccumulatedCalibrationData() {
        print("🧮 Processing accumulated calibration data...")
        print("📊 Final accumulated samples - Acc: \(accumulatedAccSamples.count), Mag: \(accumulatedMagSamples.count)")
        
        // Log sample data for analysis
        print("📊 Accelerometer samples:")
        for (i, sample) in accumulatedAccSamples.enumerated() {
            print("   Sample \(i+1): [\(String(format: "%.3f", sample[0])), \(String(format: "%.3f", sample[1])), \(String(format: "%.3f", sample[2]))]")
        }
        
        print("📊 Magnetometer samples:")
        for (i, sample) in accumulatedMagSamples.enumerated() {
            print("   Sample \(i+1): [\(String(format: "%.1f", sample[0])), \(String(format: "%.1f", sample[1])), \(String(format: "%.1f", sample[2]))]")
        }
        
        guard !accumulatedAccSamples.isEmpty && !accumulatedMagSamples.isEmpty else {
            print("❌ No data collected during calibration")
            calibrationStatus = "❌ No data collected - please ensure device is connected and sending data"
            return
        }
        
        guard accumulatedAccSamples.count >= 12 && accumulatedMagSamples.count >= 12 else { // At least 3 samples per position
            print("❌ Insufficient data collected - need at least 12 total samples")
            calibrationStatus = "❌ Insufficient data - please hold each position longer"
            return
        }
        
        calibrationStatus = "🧮 Computing calibration values..."
        print("🧮 Computing calibration with \(accumulatedAccSamples.count) accelerometer and \(accumulatedMagSamples.count) magnetometer samples")
        
        // Compute calibration values
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("🧮 Starting calibration computation...")
            
            // Enable detailed logging for calibration
            CalibrationMath.enableDetailedLogging = true
            
            let accCalibration = CalibrationMath.computeCalibration(from: self?.accumulatedAccSamples ?? [])
            let magCalibration = CalibrationMath.computeCalibration(from: self?.accumulatedMagSamples ?? [])
            
            // Disable detailed logging after calibration
            CalibrationMath.enableDetailedLogging = false
            
            print("✅ Calibration computed successfully")
            print("📊 Accelerometer calibration details:")
            print("   Mean vector: [\(String(format: "%.6f", accCalibration.vMedia[0])), \(String(format: "%.6f", accCalibration.vMedia[1])), \(String(format: "%.6f", accCalibration.vMedia[2]))]")
            print("   Determinant: \(String(format: "%.6e", accCalibration.det))")
            print("   Threshold: \(String(format: "%.6e", accCalibration.threshold))")
            print("   Sigma: [\(String(format: "%.6f", accCalibration.sigma[0])), \(String(format: "%.6f", accCalibration.sigma[1])), \(String(format: "%.6f", accCalibration.sigma[2]))]")
            
            print("📊 Magnetometer calibration details:")
            print("   Mean vector: [\(String(format: "%.6f", magCalibration.vMedia[0])), \(String(format: "%.6f", magCalibration.vMedia[1])), \(String(format: "%.6f", magCalibration.vMedia[2]))]")
            print("   Determinant: \(String(format: "%.6e", magCalibration.det))")
            print("   Threshold: \(String(format: "%.6e", magCalibration.threshold))")
            print("   Sigma: [\(String(format: "%.6f", magCalibration.sigma[0])), \(String(format: "%.6f", magCalibration.sigma[1])), \(String(format: "%.6f", magCalibration.sigma[2]))]")
            
            DispatchQueue.main.async {
                self?.saveCalibrationData(accCalibration: accCalibration, magCalibration: magCalibration)
            }
        }
    }
    
    private func saveCalibrationData(accCalibration: CalibrationResult, magCalibration: CalibrationResult) {
        print("💾 Saving calibration data...")
        
        // Save to local store
        calibrationStore.setAccCalibration(accCalibration)
        calibrationStore.setMagCalibration(magCalibration)
        print("✅ Calibration data saved to local store")
        
        // Immediately update coordinates display with new calibration data
        DispatchQueue.main.async { [weak self] in
            self?.updateCoordinatesFromCalibration()
        }
        
        // Get current user ID from UserDefaults
        let currentUserId = UserDefaults.standard.integer(forKey: "userId")
        let targetUserId = currentUserId > 0 ? currentUserId : 1 // fallback to 1 if no user logged in
        
        // Save to backend
        calibrationService.saveCalibrationData(accCalibration: accCalibration, magCalibration: magCalibration, userId: targetUserId) { [weak self] (success: Bool) in
            DispatchQueue.main.async {
                if success {
                    print("✅ Calibration data saved to backend successfully")
                    self?.calibrationStatus = "✅ Calibration completed and saved!"
                    self?.calibrationProgress = 1.0
                } else {
                    print("⚠️ Failed to save to backend, but calibration is complete")
                    self?.calibrationStatus = "⚠️ Calibration completed but failed to save to cloud"
                    self?.calibrationProgress = 1.0
                }
            }
        }
    }
    
    func loadCalibrationData() {
        print("📥 Loading calibration data from backend...")
        
        // Get current user ID from UserDefaults
        let currentUserId = UserDefaults.standard.integer(forKey: "userId")
        let targetUserId = currentUserId > 0 ? currentUserId : 1 // fallback to 1 if no user logged in
        
        calibrationService.fetchCalibrationData(userId: targetUserId) { [weak self] (accCalibration: CalibrationResult?, magCalibration: CalibrationResult?) in
            DispatchQueue.main.async {
                if let accCal = accCalibration, let magCal = magCalibration {
                    self?.calibrationStore.setAccCalibration(accCal)
                    self?.calibrationStore.setMagCalibration(magCal)
                    self?.calibrationStatus = "✅ Calibration data loaded"
                    print("✅ Calibration data loaded successfully")
                    
                    // Update coordinates display with loaded data
                    self?.updateCoordinatesFromCalibration()
                } else {
                    self?.calibrationStatus = "❌ No calibration data found"
                    print("❌ No calibration data found in backend")
                    
                    // Clear coordinates display
                    self?.updateCoordinatesFromCalibration()
                }
            }
        }
    }
    
    func hasCalibrationData() -> Bool {
        return calibrationStore.hasCalibrationData()
    }
    
    // MARK: - Public Access Methods
    func getCollectionProgress() -> (accCount: Int, magCount: Int, isCollecting: Bool) {
        return bluetoothManager.getCollectionProgress()
    }
    
    // MARK: - Debug Methods
    func debugCalibrationData() {
        print("🔍 Debug: Testing calibration data retrieval...")
        
        // Get current user ID from UserDefaults
        let currentUserId = UserDefaults.standard.integer(forKey: "userId")
        let targetUserId = currentUserId > 0 ? currentUserId : 1 // fallback to 1 if no user logged in
        
        calibrationService.debugCalibrationData(userId: targetUserId) { [weak self] (result: String) in
            DispatchQueue.main.async {
                print("🔍 Debug result: \(result)")
                self?.calibrationStatus = "🔍 Debug: \(result)"
            }
        }
    }
    
    // MARK: - System Test
    func runComprehensiveTest() {
        print("🧪 Running comprehensive calibration system test...")
        CalibrationResult.comprehensiveTest()
    }
    
    // MARK: - Calibration Recommendations
    private func generateCalibrationRecommendations(issues: [String]) -> [String] {
        var recommendations: [String] = []
        
        for issue in issues {
            if issue.contains("Connection was lost") {
                recommendations.append("Ensure device is close to phone and not obstructed")
                recommendations.append("Avoid moving phone during calibration")
                recommendations.append("Check for interference from other Bluetooth devices")
            }
            
            if issue.contains("Insufficient") {
                recommendations.append("Hold each position for at least 10-15 seconds")
                recommendations.append("Ensure device is sending data continuously")
                recommendations.append("Try calibration in a different location")
            }
            
            if issue.contains("Very low") {
                recommendations.append("Move device more during calibration to capture variation")
                recommendations.append("Try different positions (standing, sitting, leaning)")
                recommendations.append("Ensure device is not stuck in one position")
            }
            
            if issue.contains("Sample count mismatch") {
                recommendations.append("Restart calibration to ensure consistent data collection")
                recommendations.append("Check device connection stability")
            }
        }
        
        // Remove duplicates while preserving order
        return Array(Set(recommendations)).sorted()
    }
}
