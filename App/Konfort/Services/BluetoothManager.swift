//
//  BluetoothManager.swift
//  Konfort
//
//  Created by Ivano Lu on 15/07/25.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var rxCharacteristic: CBCharacteristic?

    @Published var receivedText = ""
    @Published var currentSensorData: SensorData?
    @Published var isConnected: Bool = false
    
    // Callback for real-time data
    var onSensorDataReceived: ((SensorData) -> Void)?
    
    // Data collection for calibration
    private var isCollectingData = false
    private var collectedAccSamples: [[Double]] = []
    private var collectedMagSamples: [[Double]] = []
    
    // Connection monitoring
    private var connectionTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    // MARK: - Connection Quality Monitoring
    private var connectionQualityTimer: Timer?
    private var lastDataReceivedTime = Date()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    private func startScanning() {
        guard centralManager.isScanning == false else { return }
        print("🔍 Inizio scansione per 'Konfort'...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    private func stopScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
            print("⏹️ Scansione fermata")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "🕵️‍♂️ Nessun nome"
            print("🔍 Trovato dispositivo: \(name)")
        
        if peripheral.name?.contains("Arduino") == true {
            print("✅ Trovato dispositivo Konfort")
            targetPeripheral = peripheral
            stopScanning()
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔗 Connesso a \(peripheral.name ?? "sconosciuto")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        isConnected = true
        reconnectAttempts = 0
        
        // Start gentle connection monitoring (not aggressive)
        startGentleConnectionMonitoring()
        
        // Start connection quality monitoring
        startConnectionQualityMonitoring()
    }
    
    private func startGentleConnectionMonitoring() {
        connectionTimer?.invalidate()
        
        // Use a gentle monitoring approach - check connection every 30 seconds
        // This is much less aggressive than the previous 5-10 second intervals
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Only check if we're not connected and not currently collecting data
            if !self.isConnected && !self.isCollectingData {
                print("🔍 Checking connection status...")
                if let peripheral = self.targetPeripheral {
                    print("🔄 Attempting gentle reconnection...")
                    self.centralManager.connect(peripheral, options: nil)
                } else {
                    print("🔄 No peripheral found, starting scan...")
                    self.startScanning()
                }
            }
        }
        
        print("📊 Gentle connection monitoring started (30s intervals)")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("⚠️ Connessione fallita. Riprovo...")
        isConnected = false
        targetPeripheral = nil
        reconnectAttempts += 1
        
        if reconnectAttempts < maxReconnectAttempts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startScanning()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Disconnesso da \(peripheral.name ?? "sconosciuto")")
        
        // Diagnostic information
        if let error = error {
            print("🔍 Disconnection error: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("🔍 Error code: \(urlError.code.rawValue)")
            }
        } else {
            print("🔍 Disconnection reason: Unknown (no error provided)")
        }
        
        // Check if we were collecting data when disconnected
        if isCollectingData {
            print("🔍 ⚠️ CRITICAL: Disconnected during data collection!")
            print("🔍 Current samples collected - Acc: \(collectedAccSamples.count), Mag: \(collectedMagSamples.count)")
            
            // If we have very few samples, this might be a serious problem
            if collectedAccSamples.count < 10 {
                print("🔍 ⚠️ WARNING: Very few samples collected (\(collectedAccSamples.count)) - calibration may be invalid")
            }
        }
        
        isConnected = false
        reconnectAttempts += 1
        
        // Always attempt reconnection, but with different strategies
        if isCollectingData {
            // During calibration - more aggressive reconnection strategy
            print("⚠️ Disconnected during calibration - attempting reconnection in 2 seconds...")
            print("⚠️ This may affect calibration quality. Consider restarting if reconnection fails.")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.reconnectAttempts < self.maxReconnectAttempts {
                    print("🔄 Attempting reconnection during calibration (attempt \(self.reconnectAttempts + 1)/\(self.maxReconnectAttempts))")
                    self.centralManager.connect(peripheral, options: nil)
                } else {
                    print("❌ Max reconnection attempts reached during calibration")
                    print("❌ Calibration data may be incomplete or invalid")
                }
            }
        } else {
            // During monitoring - attempt immediate reconnection
            print("🔄 Disconnected during monitoring - attempting immediate reconnection...")
            if reconnectAttempts < maxReconnectAttempts {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.centralManager.connect(peripheral, options: nil)
                }
            } else {
                print("🔄 Max reconnection attempts reached, starting fresh scan...")
                self.targetPeripheral = nil
                self.startScanning()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            if characteristic.properties.contains(.read) || characteristic.properties.contains(.notify) {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value,
           let string = String(data: data, encoding: .utf8) {
            
            // Update last data received time for connection quality monitoring
            lastDataReceivedTime = Date()
            
            DispatchQueue.main.async {
                self.receivedText += string
                self.parseSensorData(from: string)
            }
        }
    }
    
    // MARK: - Sensor Data Parsing
    private func parseSensorData(from jsonString: String) {
        // Only log raw data very occasionally during calibration to prevent buffer overflow
        if isCollectingData && collectedAccSamples.count % 50 == 0 {
            print("📡 Received raw data (sample #\(collectedAccSamples.count))")
        }
        
        // Try to extract JSON from the received string
        let lines = jsonString.components(separatedBy: .newlines)
        for line in lines {
            if line.contains("\"acc\"") && line.contains("\"mag\"") {
                if let data = line.data(using: .utf8),
                   let sensorData = try? JSONDecoder().decode(SensorData.self, from: data) {
                    
                    DispatchQueue.main.async {
                        self.currentSensorData = sensorData
                        self.onSensorDataReceived?(sensorData)
                        
                        // Collect data if calibration is active
                        if self.isCollectingData {
                            let arrays = sensorData.toArrays()
                            self.collectedAccSamples.append(arrays.acc)
                            self.collectedMagSamples.append(arrays.mag)
                            
                            // Log progress every 50 samples to reduce console spam
                            if self.collectedAccSamples.count % 50 == 0 {
                                print("📊 Collected \(self.collectedAccSamples.count) samples for calibration")
                            }
                        }
                    }
                    break
                } else {
                    // Only log parsing errors occasionally
                    if isCollectingData && collectedAccSamples.count % 100 == 0 {
                        print("❌ Failed to parse sensor data")
                    }
                }
            }
        }
    }
    
    // MARK: - Data Collection for Calibration
    func startDataCollection() {
        isCollectingData = true
        collectedAccSamples.removeAll()
        collectedMagSamples.removeAll()
        
        // Reset reconnection attempts for clean calibration
        reconnectAttempts = 0
        
        // Use gentle connection monitoring during calibration
        print("📊 Started collecting sensor data for calibration")
        print("📊 Using gentle connection monitoring during calibration")
        print("📊 Reconnection attempts reset to 0")
    }
    
    func stopDataCollection() -> (accSamples: [[Double]], magSamples: [[Double]]) {
        isCollectingData = false
        let accSamples: [[Double]] = collectedAccSamples
        let magSamples: [[Double]] = collectedMagSamples
        
        print("📊 Stopped collecting sensor data. Collected \(accSamples.count) samples")
        
        // Re-enable gentle connection monitoring after calibration
        startGentleConnectionMonitoring()
        
        collectedAccSamples.removeAll()
        collectedMagSamples.removeAll()
        return (accSamples, magSamples)
    }
    
    // MARK: - Enhanced Data Collection with Progress
    func getCollectionProgress() -> (accCount: Int, magCount: Int, isCollecting: Bool) {
        return (collectedAccSamples.count, collectedMagSamples.count, isCollectingData)
    }
    
    // MARK: - Calibration Quality Assessment
    func assessCalibrationQuality() -> (isValid: Bool, issues: [String]) {
        var issues: [String] = []
        var isValid = true
        
        // Check sample count
        if collectedAccSamples.count < 50 {
            issues.append("Insufficient accelerometer samples: \(collectedAccSamples.count) (minimum 50 recommended)")
            isValid = false
        }
        
        if collectedMagSamples.count < 50 {
            issues.append("Insufficient magnetometer samples: \(collectedMagSamples.count) (minimum 50 recommended)")
            isValid = false
        }
        
        // Check for data consistency (no gaps)
        if collectedAccSamples.count != collectedMagSamples.count {
            issues.append("Sample count mismatch: Acc=\(collectedAccSamples.count), Mag=\(collectedMagSamples.count)")
            isValid = false
        }
        
        // Check for connection issues during collection
        if reconnectAttempts > 0 {
            issues.append("Connection was lost \(reconnectAttempts) times during calibration")
            if reconnectAttempts > 2 {
                isValid = false
            }
        }
        
        // Check data quality (no extreme outliers)
        if !collectedAccSamples.isEmpty {
            let accXValues = collectedAccSamples.map { $0[0] }
            let accYValues = collectedAccSamples.map { $0[1] }
            let accZValues = collectedAccSamples.map { $0[2] }
            
            let accXRange = (accXValues.max() ?? 0) - (accXValues.min() ?? 0)
            let accYRange = (accYValues.max() ?? 0) - (accYValues.min() ?? 0)
            let accZRange = (accZValues.max() ?? 0) - (accZValues.min() ?? 0)
            
            if accXRange < 0.1 || accYRange < 0.1 || accZRange < 0.1 {
                issues.append("Very low accelerometer variation detected - device may not have moved enough")
            }
        }
        
        if !collectedMagSamples.isEmpty {
            let magXValues = collectedMagSamples.map { $0[0] }
            let magYValues = collectedMagSamples.map { $0[1] }
            let magZValues = collectedMagSamples.map { $0[2] }
            
            let magXRange = (magXValues.max() ?? 0) - (magXValues.min() ?? 0)
            let magYRange = (magYValues.max() ?? 0) - (magYValues.min() ?? 0)
            let magZRange = (magZValues.max() ?? 0) - (magZValues.min() ?? 0)
            
            if magXRange < 1.0 || magYRange < 1.0 || magZRange < 1.0 {
                issues.append("Very low magnetometer variation detected - device may not have moved enough")
            }
        }
        
        return (isValid, issues)
    }
    
    func getConnectionStatus() -> Bool {
        return isConnected
    }
    
    func cleanup() {
        connectionTimer?.invalidate()
        connectionTimer = nil
        connectionQualityTimer?.invalidate()
        connectionQualityTimer = nil
        stopScanning()
        if let peripheral = targetPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    private func startConnectionMonitoring() {
        connectionTimer?.invalidate()
        
        // Completely disable connection monitoring to prevent interference with BLE connection
        print("📊 Connection monitoring completely disabled to maintain stable connection")
    }
    
    private func startConnectionQualityMonitoring() {
        connectionQualityTimer?.invalidate()
        
        // Monitor connection quality every 10 seconds
        connectionQualityTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let timeSinceLastData = Date().timeIntervalSince(self.lastDataReceivedTime)
            
            if timeSinceLastData > 5.0 {
                print("⚠️ No data received for \(Int(timeSinceLastData)) seconds - connection might be weak")
            }
        }
    }
    
    private func stopConnectionQualityMonitoring() {
        connectionQualityTimer?.invalidate()
        connectionQualityTimer = nil
    }
}


