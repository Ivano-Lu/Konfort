# App Documentation

The mobile app plays a crucial role in receiving, displaying and processing posture data sent from the wearable device via Bluetooth Low Energy (BLE). 
The app not only visualizes the live posture data but also enables more complex analysis by sending the data to an online API. 
To achieve this, the app must handle BLE communication, process the received data and interact with a backend for advanced posture analytics.


## Table of contents
- [Get Started](#get-started)
- [Working Flow](#working-flow)
    - [Login](#login)
    - [Initialization BLE connection](#initialization-ble-connection)
    - [Calibration Phase](#calibration-phase)
    - [Posture Evaluation](#posture evaluation)



## Get Started
TODO: dffsdf


## Working Flow
### Login
When the user open the app, he has to as to log in into the app with his credential.
If he doesn't have an account, he first has to create a personal account and then he can complete the login.

After the login, the app will provide to recover the calibration data of the user from the DB.
```swift
        // Handle calibration data from login response
        if let calibrationData = login["calibrationData"] as? [String: Any] {
            print("📥 Calibration data received during login")
            self?.handleCalibrationDataFromLogin(calibrationData)
        } else {
            print("ℹ️ No calibration data in login response")
        }


private func handleCalibrationDataFromLogin(_ calibrationData: [String: Any]) {
    print("🔄 Processing calibration data from login...")
    
    // Extract all calibration data from backend format
    guard let accMatrix = calibrationData["accMatrix"] as? [[Double]],
            let accInvertedMatrix = calibrationData["accInvertedMatrix"] as? [[Double]],
            let accDeterminant = calibrationData["accDeterminant"] as? Double,
            let magMatrix = calibrationData["magMatrix"] as? [[Double]],
            let magInvertedMatrix = calibrationData["magInvertedMatrix"] as? [[Double]],
            let magDeterminant = calibrationData["magDeterminant"] as? Double else {
        print("❌ Invalid calibration data format from login")
        return
    }
    
    // Handle optional fields with default values
    let accVMedia = calibrationData["accVMedia"] as? [Double] ?? [0.0, 0.0, 0.0]
    let accSigma = calibrationData["accSigma"] as? [Double] ?? [0.0, 0.0, 0.0]
    let accThreshold = calibrationData["accThreshold"] as? Double ?? 0.0
    let magVMedia = calibrationData["magVMedia"] as? [Double] ?? [0.0, 0.0, 0.0]
    let magSigma = calibrationData["magSigma"] as? [Double] ?? [0.0, 0.0, 0.0]
    let magThreshold = calibrationData["magThreshold"] as? Double ?? 0.0
    
    // Convert to CalibrationResult format with all fields
    let accCalibration = CalibrationResult(
        vMedia: accVMedia,
        mCov: accMatrix,
        det: accDeterminant,
        mInv: accInvertedMatrix,
        sigma: accSigma,
        threshold: accThreshold
    )
    
    let magCalibration = CalibrationResult(
        vMedia: magVMedia,
        mCov: magMatrix,
        det: magDeterminant,
        mInv: magInvertedMatrix,
        sigma: magSigma,
        threshold: magThreshold
    )
    
    // Save to calibration store
    CalibrationDataStore.shared.setAccCalibration(accCalibration)
    CalibrationDataStore.shared.setMagCalibration(magCalibration)
    
    print("✅ Calibration data loaded from login response with all fields")
}
```


### Initialization BLE connection
After the login, the app will automatically try to establish a connection with any device named "Arduino" it can find.
```swift
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let name = peripheral.name ?? "🕵️‍♂️ Nessun nome"
        print("🔍 Trovato dispositivo: \(name)")
    
    if peripheral.name?.contains("Arduino") == true {
        print("✅ Trovato dispositivo Konfort")
        targetPeripheral = peripheral
        stopScanning()
        centralManager.connect(peripheral, options: nil)
    }
}
```

Then, the user can perform different action, depending on what he/she need.


### Calibration Phase
Normally, when the user logs into the app, he should first perform the calibration phase, in order to calibrate the device to have valid posture evaluation.

The data will be received by the BLE Manager
```swift
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
```

and then they will be collected.
```swift
if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let calibData = dataDict["fetchCalibrationData"] as? [String: Any] {

                    let id = calibData["id"] as? String ?? ""
                    let accDeterminant = calibData["accDeterminant"] as? Double ?? 0.0
                    let accMatrix = calibData["accMatrix"] as? [[Double]] ?? []
                    let accInvertedMatrix = calibData["accInvertedMatrix"] as? [[Double]] ?? []
                    let accVMedia = calibData["accVMedia"] as? [Double] ?? [0.0, 0.0, 0.0]
                    let accSigma = calibData["accSigma"] as? [Double] ?? [0.0, 0.0, 0.0]
                    let accThreshold = calibData["accThreshold"] as? Double ?? 0.0
                    let magDeterminant = calibData["magDeterminant"] as? Double ?? 0.0
                    let magMatrix = calibData["magMatrix"] as? [[Double]] ?? []
                    let magInvertedMatrix = calibData["magInvertedMatrix"] as? [[Double]] ?? []
                    let magVMedia = calibData["magVMedia"] as? [Double] ?? [0.0, 0.0, 0.0]
                    let magSigma = calibData["magSigma"] as? [Double] ?? [0.0, 0.0, 0.0]
                    let magThreshold = calibData["magThreshold"] as? Double ?? 0.0

                    let calibrationData = CalibrationDataPayload(
                        id: id,
                        accMatrix: accMatrix,
                        accInvertedMatrix: accInvertedMatrix,
                        accDeterminant: accDeterminant,
                        accVMedia: accVMedia,
                        accSigma: accSigma,
                        accThreshold: accThreshold,
                        magMatrix: magMatrix,
                        magInvertedMatrix: magInvertedMatrix,
                        magDeterminant: magDeterminant,
                        magVMedia: magVMedia,
                        magSigma: magSigma,
                        magThreshold: magThreshold
                    )

                    // ✅ Salva internamente nel service
                    self.setCalibrationData(calibrationData)

                    completion(true)
```

Once the user calibration phase is complete, the app uses the collected data to calculate various statistical data for each sensor, including the mean vector, covariance matrix, eigenvalues, etc...
```swift
// 1. Calculate mean vector
var vMedia = [Double](repeating: 0, count: dim)
for sample in samples {
    for i in 0..<dim {
        vMedia[i] += sample[i]
    }
}
vMedia = vMedia.map { $0 / N }

// 2. Calculate covariance matrix
var mCov = Array(repeating: Array(repeating: 0.0, count: dim), count: dim)
for sample in samples {
    let vDiff = zip(sample, vMedia).map(-)
    for j in 0..<dim {
        for k in 0..<dim {
            mCov[j][k] += vDiff[j] * vDiff[k]
        }
    }
}
for j in 0..<dim {
    for k in 0..<dim {
        mCov[j][k] /= (N - 1)
    }
}

// 3. Validate covariance matrix
if !isValidCovarianceMatrix(mCov) {
    print("❌ Invalid covariance matrix detected, using default calibration")
    return createDefaultCalibration()
}

// 4. Calculate determinant
let det = mCov[0][0] * (mCov[1][1]*mCov[2][2] - mCov[1][2]*mCov[2][1])
        - mCov[0][1] * (mCov[1][0]*mCov[2][2] - mCov[1][2]*mCov[2][0])
        + mCov[0][2] * (mCov[1][0]*mCov[2][1] - mCov[1][1]*mCov[2][0])

// 5. Validate determinant
if det <= 0 || det.isNaN || det.isInfinite {
    print("❌ Invalid determinant: \(det), using default calibration")
    return createDefaultCalibration()
}

// 6. Calculate inverse covariance matrix
var mInv = Array(repeating: Array(repeating: 0.0, count: dim), count: dim)
let invDet = 1.0 / det
mInv[0][0] =  (mCov[1][1]*mCov[2][2] - mCov[1][2]*mCov[2][1]) * invDet
mInv[0][1] = -(mCov[0][1]*mCov[2][2] - mCov[0][2]*mCov[2][1]) * invDet
mInv[0][2] =  (mCov[0][1]*mCov[1][2] - mCov[0][2]*mCov[1][1]) * invDet
mInv[1][0] = -(mCov[1][0]*mCov[2][2] - mCov[1][2]*mCov[2][0]) * invDet
mInv[1][1] =  (mCov[0][0]*mCov[2][2] - mCov[0][2]*mCov[2][0]) * invDet
mInv[1][2] = -(mCov[0][0]*mCov[1][2] - mCov[0][2]*mCov[1][0]) * invDet
mInv[2][0] =  (mCov[1][0]*mCov[2][1] - mCov[1][1]*mCov[2][0]) * invDet
mInv[2][1] = -(mCov[0][0]*mCov[2][1] - mCov[0][1]*mCov[2][0]) * invDet
mInv[2][2] =  (mCov[0][0]*mCov[1][1] - mCov[0][1]*mCov[1][0]) * invDet

// 7. Validate inverse matrix
if !isValidInverseMatrix(mInv) {
    print("❌ Invalid inverse matrix detected, using default calibration")
    return createDefaultCalibration()
}

// 8. Calculate eigenvalues (simplified for symmetric matrix)
var eigenvalues = [Double](repeating: 0, count: dim)
computeEigenvalues(matrix: mCov, eigenvalues: &eigenvalues)
```

Finally, the app calculates a threshold value, which will then be used for the posture evaluation.
```swift
// 11. Calculate threshold with validation
let vet = zip(adjustedSigma, vMedia).map(+)
let threshold = computeDensity(val: vet, vMedia: vMedia, det: det, mInv: mInv)

static func computeDensity(val: [Double], vMedia: [Double], det: Double, mInv: [[Double]]) -> Double {
        // Validate inputs
        guard det > 0 && !det.isNaN && !det.isInfinite else {
            print("❌ Invalid determinant in density calculation: \(det)")
            return 1e-10
        }
        
        let vDiff = zip(val, vMedia).map(-)
        
        // Check for extreme differences that might cause numerical issues
        let maxDiff = vDiff.map(abs).max() ?? 0
        if maxDiff > 1e6 {
            if enableDetailedLogging {
                print("📊 Warning: Very large difference detected (\(maxDiff)), this may cause numerical issues")
            }
            return 1e-10
        }
        
        // Calculate tmp = mInv * vDiff
        var tmp = [Double](repeating: 0, count: 3)
        for i in 0..<3 {
            for j in 0..<3 {
                tmp[i] += mInv[i][j] * vDiff[j]
            }
        }
        
        // Validate matrix product
        for element in tmp {
            if element.isNaN || element.isInfinite {
                print("❌ Invalid matrix product in density calculation")
                return 1e-10
            }
        }
        
        // Calculate exponent = -0.5 * vDiff^T * tmp
        var exponent = 0.0
        for i in 0..<3 {
            exponent += vDiff[i] * tmp[i]
        }
        exponent *= -0.5
        
        // Check for extreme exponent values
        if exponent < -100 {
            if enableDetailedLogging {
                print("📊 Warning: Very negative exponent (\(exponent)), density will be extremely small")
            }
            // Return a very small but non-zero value instead of exp(-100) which is practically zero
            return 1e-50
        }
        
        if exponent > 100 {
            if enableDetailedLogging {
                print("📊 Warning: Very positive exponent (\(exponent)), density will be extremely large")
            }
            // Return a reasonable upper bound
            return 1e-3
        }
        
        // Calculate density = (2π)^(-3/2) * det^(-1/2) * e^exponent
        let normalizationFactor = pow(2 * .pi, -1.5) * pow(det, -0.5)
        let ret = normalizationFactor * exp(exponent)
        
        // Final validation
        if ret.isNaN || ret.isInfinite {
            print("❌ Invalid density result: \(ret), using fallback value")
            return 1e-10
        }
        
        // Log intermediate calculations only when detailed logging is enabled
        if enableDetailedLogging {
            print("📊 Density calculation details:")
            print("   Input value: [\(String(format: "%.6f", val[0])), \(String(format: "%.6f", val[1])), \(String(format: "%.6f", val[2]))]")
            print("   Mean vector: [\(String(format: "%.6f", vMedia[0])), \(String(format: "%.6f", vMedia[1])), \(String(format: "%.6f", vMedia[2]))]")
            print("   Difference: [\(String(format: "%.6f", vDiff[0])), \(String(format: "%.6f", vDiff[1])), \(String(format: "%.6f", vDiff[2]))]")
            print("   Max difference: \(String(format: "%.6e", maxDiff))")
            print("   Matrix product: [\(String(format: "%.6e", tmp[0])), \(String(format: "%.6e", tmp[1])), \(String(format: "%.6e", tmp[2]))]")
            print("   Exponent: \(String(format: "%.6f", exponent))")
            print("   Determinant: \(String(format: "%.6e", det))")
            print("   Normalization factor: \(String(format: "%.6e", normalizationFactor))")
            print("   Final density: \(String(format: "%.6e", ret))")
        }
        
        return ret
    }
```

### Posture Evaluation
Then, if the user selects the Monitor view, the app will start collecting user data using computeDensity to extract a value, which is compared to the threshold of the respective sensor. 
If the value is greater than the threshold, then the posture is assessed as correct by that sensor.

The posture is considered correct if at least one of the two sensors assesses it as correct.
```swift
static func evaluatePosture(accData: [Double], magData: [Double], 
                               accCalibration: CalibrationResult, 
                               magCalibration: CalibrationResult) -> Bool {
        // Compute density for accelerometer
        let accDensity = computeDensity(
            val: accData,
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        
        // Compute density for magnetometer
        let magDensity = computeDensity(
            val: magData,
            vMedia: magCalibration.vMedia,
            det: magCalibration.det,
            mInv: magCalibration.mInv
        )
        
        // Log density calculations only when detailed logging is enabled
        if enableDetailedLogging {
            print("📊 Density calculations:")
            print("   Accelerometer density: \(String(format: "%.6e", accDensity))")
            print("   Accelerometer threshold: \(String(format: "%.6e", accCalibration.threshold))")
            print("   Accelerometer correct: \(accDensity >= accCalibration.threshold)")
            print("   Magnetometer density: \(String(format: "%.6e", magDensity))")
            print("   Magnetometer threshold: \(String(format: "%.6e", magCalibration.threshold))")
            print("   Magnetometer correct: \(magDensity >= magCalibration.threshold)")
        }
        
        // Posture is correct if at least one sensor gives correct posture
        let accCorrect = accDensity >= accCalibration.threshold
        let magCorrect = magDensity >= magCalibration.threshold
        
        let finalResult = accCorrect || magCorrect
        if enableDetailedLogging {
            print("📊 Final posture result: \(finalResult ? "CORRECT" : "INCORRECT") (Acc: \(accCorrect), Mag: \(magCorrect))")
        }
        
        return finalResult
    }
```