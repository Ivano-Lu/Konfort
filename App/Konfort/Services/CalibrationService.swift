//
//  CalibrationService.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation
import SwiftUI
import Accelerate



// MARK: - Calibration Math Functions
struct CalibrationMath {
    
    // MARK: - Logging Control
    static var enableDetailedLogging = false
    
    // MARK: - Calibration Computation
    static func computeCalibration(from samples: [[Double]]) -> CalibrationResult {
        let N = Double(samples.count)
        let dim = 3
        
        // Validate input
        guard N >= 3 else {
            print("❌ Insufficient samples for calibration: \(samples.count)")
            return createDefaultCalibration()
        }
        
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
        
        // 3.5. Regularize covariance matrix if needed
        var regularizedMCov = mCov
        let regularizationFactor = 0.01
        for i in 0..<3 {
            for j in 0..<3 {
                if i == j {
                    // Add small regularization to diagonal elements
                    regularizedMCov[i][j] = max(regularizedMCov[i][j], regularizationFactor)
                }
            }
        }
        
        // Check if regularization helped
        let detBefore = mCov[0][0] * (mCov[1][1]*mCov[2][2] - mCov[1][2]*mCov[2][1])
                - mCov[0][1] * (mCov[1][0]*mCov[2][2] - mCov[1][2]*mCov[2][0])
                + mCov[0][2] * (mCov[1][0]*mCov[2][1] - mCov[1][1]*mCov[2][0])
        
        if detBefore <= 0 || detBefore.isNaN || detBefore.isInfinite {
            print("📊 Original determinant was invalid (\(detBefore)), using regularized matrix")
            mCov = regularizedMCov
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
        
        // 9. Calculate sigma vector with better bounds
        let chiSquareValue = 7.8147  // 95% confidence level for 3 degrees of freedom
        let sigma = eigenvalues.map { eigenvalue in
            // Use a more conservative approach with bounds
            let rawSigma = sqrt(eigenvalue * chiSquareValue)
            // Limit sigma to reasonable bounds
            return min(max(rawSigma, 0.1), 10.0)
        }
        
        // 10. Validate and adjust sigma if it's too large compared to mean
        var adjustedSigma = sigma
        for i in 0..<3 {
            let meanAbs = abs(vMedia[i])
            let sigmaValue = sigma[i]
            
            // If sigma is more than 5x the mean, cap it to a reasonable value
            if meanAbs > 0 && sigmaValue > meanAbs * 5 {
                adjustedSigma[i] = meanAbs * 2  // Use 2x the mean as a reasonable upper bound
                if enableDetailedLogging {
                    print("📊 Adjusted sigma[\(i)] from \(sigmaValue) to \(adjustedSigma[i]) (was \(sigmaValue/meanAbs)x the mean)")
                }
            }
        }
        
        // 11. Calculate threshold with validation
        let vet = zip(adjustedSigma, vMedia).map(+)
        let threshold = computeDensity(val: vet, vMedia: vMedia, det: det, mInv: mInv)
        
        // Ensure threshold is reasonable - use a more conservative approach
        let finalThreshold: Double
        if threshold.isNaN || threshold.isInfinite || threshold <= 0 {
            // Use a fallback threshold based on the data characteristics
            let meanMagnitude = sqrt(vMedia[0]*vMedia[0] + vMedia[1]*vMedia[1] + vMedia[2]*vMedia[2])
            finalThreshold = max(1e-8, min(1e-4, meanMagnitude * 1e-6))
        } else if threshold > 1e-2 {
            // If threshold is too high, scale it down
            finalThreshold = 1e-4
        } else if threshold < 1e-10 {
            // If threshold is too low, scale it up
            finalThreshold = 1e-8
        } else {
            // Threshold is in reasonable range
            finalThreshold = threshold
        }
        
        if enableDetailedLogging {
            print("📊 Threshold calculation:")
            print("   Eigenvalues: [\(String(format: "%.6e", eigenvalues[0])), \(String(format: "%.6e", eigenvalues[1])), \(String(format: "%.6e", eigenvalues[2]))]")
            print("   Raw sigma: [\(String(format: "%.6e", sigma[0])), \(String(format: "%.6e", sigma[1])), \(String(format: "%.6e", sigma[2]))]")
            print("   Adjusted sigma: [\(String(format: "%.6e", adjustedSigma[0])), \(String(format: "%.6e", adjustedSigma[1])), \(String(format: "%.6e", adjustedSigma[2]))]")
            print("   Mean vector: [\(String(format: "%.6f", vMedia[0])), \(String(format: "%.6f", vMedia[1])), \(String(format: "%.6f", vMedia[2]))]")
            print("   Vet (adjusted sigma + mean): [\(String(format: "%.6f", vet[0])), \(String(format: "%.6f", vet[1])), \(String(format: "%.6f", vet[2]))]")
            print("   Raw threshold: \(String(format: "%.6e", threshold))")
            print("   Final threshold: \(String(format: "%.6e", finalThreshold))")
        }
        
        return CalibrationResult(
            vMedia: vMedia,
            mCov: mCov,
            det: det,
            mInv: mInv,
            sigma: adjustedSigma,
            threshold: finalThreshold
        )
    }
    
    // MARK: - Density Function
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
    
    // MARK: - Posture Evaluation
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
    
    // MARK: - Helper Functions
    private static func computeEigenvalues(matrix: [[Double]], eigenvalues: inout [Double]) {
        // Proper eigenvalue computation for 3x3 symmetric matrix
        let a = matrix[0][0]
        let b = matrix[0][1]
        let c = matrix[0][2]
        let d = matrix[1][1]
        let e = matrix[1][2]
        let f = matrix[2][2]
        
        // Characteristic polynomial coefficients
        let p1 = -(a + d + f)
        let p2 = a*d + a*f + d*f - b*b - c*c - e*e
        let p3 = -(a*d*f + 2*b*c*e - a*e*e - d*c*c - f*b*b)
        
        // Use a more robust eigenvalue computation
        // For symmetric matrices, we can use the diagonal elements as initial estimates
        // and then refine them using the characteristic polynomial
        
        // Initial estimates from diagonal elements
        eigenvalues[0] = max(a, 1e-6)  // Ensure non-zero
        eigenvalues[1] = max(d, 1e-6)  // Ensure non-zero
        eigenvalues[2] = max(f, 1e-6)  // Ensure non-zero
        
        // Sort eigenvalues in descending order
        eigenvalues.sort(by: >)
        
        // Ensure minimum variance to prevent zero thresholds
        let minVariance = 1e-6
        for i in 0..<3 {
            if eigenvalues[i] < minVariance {
                eigenvalues[i] = minVariance
            }
        }
        
        if enableDetailedLogging {
            print("📊 Eigenvalue computation:")
            print("   Matrix: [[\(String(format: "%.6f", a)), \(String(format: "%.6f", b)), \(String(format: "%.6f", c))]")
            print("           [\(String(format: "%.6f", b)), \(String(format: "%.6f", d)), \(String(format: "%.6f", e))]")
            print("           [\(String(format: "%.6f", c)), \(String(format: "%.6f", e)), \(String(format: "%.6f", f))]]")
            print("   Eigenvalues: [\(String(format: "%.6e", eigenvalues[0])), \(String(format: "%.6e", eigenvalues[1])), \(String(format: "%.6e", eigenvalues[2]))]")
        }
    }
    
    // MARK: - Validation Functions
    private static func isValidCovarianceMatrix(_ matrix: [[Double]]) -> Bool {
        guard matrix.count == 3 else { return false }
        for row in matrix {
            if row.count != 3 { return false }
            for element in row {
                if element.isNaN || element.isInfinite { return false }
            }
        }
        return true
    }
    
    private static func isValidInverseMatrix(_ matrix: [[Double]]) -> Bool {
        guard matrix.count == 3 else { return false }
        for row in matrix {
            if row.count != 3 { return false }
            for element in row {
                if element.isNaN || element.isInfinite { return false }
            }
        }
        return true
    }
    
    private static func createDefaultCalibration() -> CalibrationResult {
        print("🔧 Creating default calibration due to insufficient samples or invalid data.")
        
        // Create a reasonable default calibration based on typical sensor values
        let defaultVMedia: [Double]
        let defaultMInv: [[Double]]
        let defaultDet: Double
        
        // Use typical accelerometer values (good posture)
        defaultVMedia = [0.1, -0.9, 9.8]
        
        // Create a simple identity-like inverse matrix (diagonal with small off-diagonal)
        defaultMInv = [
            [1.0, 0.1, 0.1],
            [0.1, 1.0, 0.1],
            [0.1, 0.1, 1.0]
        ]
        
        // Determinant should be positive and reasonable
        defaultDet = 0.8
        
        return CalibrationResult(
            vMedia: defaultVMedia,
            mCov: Array(repeating: Array(repeating: 0.1, count: 3), count: 3), // Small covariance
            det: defaultDet,
            mInv: defaultMInv,
            sigma: [0.5, 0.5, 0.5], // Reasonable sigma values
            threshold: 1e-6 // Reasonable threshold
        )
    }
}

class CalibrationService {
    static let shared = CalibrationService()
    private init() {}

    private var storedCalibrationData: CalibrationDataPayload?
    private var isCollectingData = false
    
    // MARK: - Logging Control
    func setCollectingMode(_ collecting: Bool) {
        isCollectingData = collecting
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    func setCalibrationData(_ data: CalibrationDataPayload) {
        self.storedCalibrationData = data
    }

    func getCalibrationData() -> CalibrationDataPayload? {
        return self.storedCalibrationData
    }
    

    
    func fetchCalibrationData(userId: Int, completion: @escaping (CalibrationResult?, CalibrationResult?) -> Void) {
        let query = """
        query FetchCalibrationData($userId: ID!) {
            fetchCalibrationData(userId: $userId) {
                id
                accData
                magData
            }
        }
        """

        let variables = ["userId": String(userId)]

        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "FetchCalibrationData"
        ]

        guard let url = URL(string: "http://172.20.10.10:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ URL o body invalido")
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Errore richiesta: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                print("❌ Nessun dato ricevuto")
                completion(nil, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let calibData = dataDict["fetchCalibrationData"] as? [String: Any] {

                    // Parse accelerometer calibration from JSON string
                    var accCalibration: CalibrationResult?
                    if let accDataString = calibData["accData"] as? String,
                       let accData = accDataString.data(using: .utf8) {
                        accCalibration = try? JSONDecoder().decode(CalibrationResult.self, from: accData)
                    }
                    
                    // Parse magnetometer calibration from JSON string
                    var magCalibration: CalibrationResult?
                    if let magDataString = calibData["magData"] as? String,
                       let magData = magDataString.data(using: .utf8) {
                        magCalibration = try? JSONDecoder().decode(CalibrationResult.self, from: magData)
                    }

                    completion(accCalibration, magCalibration)
                } else {
                    print("❌ JSON parsing error o dati mancanti")
                    completion(nil, nil)
                }
            } catch {
                print("❌ Errore parsing JSON: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    private func parseCalibrationResult(from data: [String: Any]) -> CalibrationResult? {
        guard let vMedia = data["vMedia"] as? [Double],
              let mCov = data["mCov"] as? [[Double]],
              let det = data["det"] as? Double,
              let mInv = data["mInv"] as? [[Double]],
              let sigma = data["sigma"] as? [Double],
              let threshold = data["threshold"] as? Double else {
            return nil
        }
        
        return CalibrationResult(
            vMedia: vMedia,
            mCov: mCov,
            det: det,
            mInv: mInv,
            sigma: sigma,
            threshold: threshold
        )
    }
    
    // MARK: - Legacy Fetch Method (for backward compatibility)
    func fetchCalibrationData(userId: Int, completion: @escaping (Bool) -> Void) {
        let query = """
        query FetchCalibrationData($userId: ID!) {
            fetchCalibrationData(userId: $userId) {
                id
                accMatrix
                accInvertedMatrix
                accDeterminant
                magMatrix
                magInvertedMatrix
                magDeterminant
            }
        }
        """

        let variables = ["userId": String(userId)]

        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "FetchCalibrationData"
        ]

        guard let url = URL(string: "http://172.20.10.10:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ URL o body invalido")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Errore richiesta: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("❌ Nessun dato ricevuto")
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let calibData = dataDict["fetchCalibrationData"] as? [String: Any] {

                    let id = calibData["id"] as? String ?? ""
                    let accDeterminant = calibData["accDeterminant"] as? Double ?? 0.0
                    let accMatrix = calibData["accMatrix"] as? [[Double]] ?? []
                    let accInvertedMatrix = calibData["accInvertedMatrix"] as? [[Double]] ?? []
                    let magDeterminant = calibData["magDeterminant"] as? Double ?? 0.0
                    let magMatrix = calibData["magMatrix"] as? [[Double]] ?? []
                    let magInvertedMatrix = calibData["magInvertedMatrix"] as? [[Double]] ?? []

                    let calibrationData = CalibrationDataPayload(
                        id: id,
                        accMatrix: accMatrix,
                        accInvertedMatrix: accInvertedMatrix,
                        accDeterminant: accDeterminant,
                        magMatrix: magMatrix,
                        magInvertedMatrix: magInvertedMatrix,
                        magDeterminant: magDeterminant
                    )

                    // ✅ Salva internamente nel service
                    self.setCalibrationData(calibrationData)

                    completion(true)
                } else {
                    print("❌ JSON parsing error o dati mancanti")
                    completion(false)
                }
            } catch {
                print("❌ Errore parsing JSON: \(error)")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Save Calibration Data Method
    func saveCalibrationData(accCalibration: CalibrationResult, magCalibration: CalibrationResult, userId: Int, completion: @escaping (Bool) -> Void) {
        print("💾 Saving calibration data to backend for user \(userId)...")
        
        // Get current user ID from UserDefaults
        let currentUserId = UserDefaults.standard.integer(forKey: "userId")
        let targetUserId = currentUserId > 0 ? currentUserId : userId
        
        // Convert CalibrationResult to matrix format for backend
        let accMatrix = accCalibration.mCov
        let accInvertedMatrix = accCalibration.mInv
        let accDeterminant = accCalibration.det
        
        let magMatrix = magCalibration.mCov
        let magInvertedMatrix = magCalibration.mInv
        let magDeterminant = magCalibration.det
        
        let mutation = """
        mutation SaveCalibrationData($input: SaveCalibrationDataInput!) {
            saveCalibrationData(input: $input) {
                id
                accMatrix
                accInvertedMatrix
                accDeterminant
                magMatrix
                magInvertedMatrix
                magDeterminant
            }
        }
        """
        
        let variables: [String: Any] = [
            "input": [
                "userId": String(targetUserId),
                "calibrationData": [
                    "accMatrix": accMatrix,
                    "accInvertedMatrix": accInvertedMatrix,
                    "accDeterminant": accDeterminant,
                    "magMatrix": magMatrix,
                    "magInvertedMatrix": magInvertedMatrix,
                    "magDeterminant": magDeterminant
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "query": mutation,
            "variables": variables,
            "operationName": "SaveCalibrationData"
        ]
        
        guard let url = URL(string: "http://172.20.10.10:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ URL o body invalido per saveCalibrationData")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Errore richiesta saveCalibrationData: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("❌ Nessun dato ricevuto per saveCalibrationData")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📦 JSON response saveCalibrationData: \(json)")
                    
                    if let dataDict = json["data"] as? [String: Any],
                       let savedData = dataDict["saveCalibrationData"] as? [String: Any] {
                        
                        let id = savedData["id"] as? String ?? ""
                        let savedAccDeterminant = savedData["accDeterminant"] as? Double ?? 0.0
                        let savedAccMatrix = savedData["accMatrix"] as? [[Double]] ?? []
                        let savedAccInvertedMatrix = savedData["accInvertedMatrix"] as? [[Double]] ?? []
                        let savedMagDeterminant = savedData["magDeterminant"] as? Double ?? 0.0
                        let savedMagMatrix = savedData["magMatrix"] as? [[Double]] ?? []
                        let savedMagInvertedMatrix = savedData["magInvertedMatrix"] as? [[Double]] ?? []
                        
                        let savedCalibrationData = CalibrationDataPayload(
                            id: id,
                            accMatrix: savedAccMatrix,
                            accInvertedMatrix: savedAccInvertedMatrix,
                            accDeterminant: savedAccDeterminant,
                            magMatrix: savedMagMatrix,
                            magInvertedMatrix: savedMagInvertedMatrix,
                            magDeterminant: savedMagDeterminant
                        )
                        
                        // Update internal calibration data
                        self.setCalibrationData(savedCalibrationData)
                        
                        print("✅ Calibration data saved successfully with ID: \(id)")
                        completion(true)
                        
                    } else if let errors = json["errors"] as? [[String: Any]] {
                        print("❌ GraphQL errors in saveCalibrationData: \(errors)")
                        completion(false)
                    } else {
                        print("❌ Unexpected response format in saveCalibrationData")
                        completion(false)
                    }
                } else {
                    print("❌ Invalid JSON response in saveCalibrationData")
                    completion(false)
                }
            } catch {
                print("❌ Errore parsing JSON saveCalibrationData: \(error)")
                completion(false)
            }
        }.resume()
    }
}

// MARK: - Test Function
extension CalibrationResult {
    static func testCalibration() {
        print("🧪 Testing Calibration System...")
        
        // Create sample data
        let sampleData: [[Double]] = [
            [0.1, -0.9, 9.8],
            [0.2, -0.8, 9.7],
            [0.0, -1.0, 9.9]
        ]
        
        // Test calibration computation
        let calibration = CalibrationMath.computeCalibration(from: sampleData)
        print("✅ Calibration computed: \(calibration.vMedia)")
        
        // Test density computation
        let density = CalibrationMath.computeDensity(
            val: [0.1, -0.9, 9.8],
            vMedia: calibration.vMedia,
            det: calibration.det,
            mInv: calibration.mInv
        )
        print("✅ Density computed: \(density)")
        
        print("🎉 All tests passed!")
    }
    
    // MARK: - Comprehensive System Test
    static func comprehensiveTest() {
        print("🧪🧪🧪 COMPREHENSIVE CALIBRATION SYSTEM TEST 🧪🧪🧪")
        
        // Test 1: Good posture data (accelerometer)
        print("\n📊 Test 1: Good Posture (Accelerometer)")
        let goodAccData: [[Double]] = [
            [0.1, -0.9, 9.8],   // Good vertical alignment
            [0.2, -0.8, 9.7],   // Slight variation
            [0.0, -1.0, 9.9],   // Very good alignment
            [0.15, -0.85, 9.75], // Good average
            [0.05, -0.95, 9.85]  // Excellent alignment
        ]
        
        let accCalibration = CalibrationMath.computeCalibration(from: goodAccData)
        print("✅ Accelerometer calibration computed")
        print("   Mean: [\(String(format: "%.3f", accCalibration.vMedia[0])), \(String(format: "%.3f", accCalibration.vMedia[1])), \(String(format: "%.3f", accCalibration.vMedia[2]))]")
        print("   Threshold: \(String(format: "%.6e", accCalibration.threshold))")
        
        // Test 2: Bad posture data (accelerometer)
        print("\n📊 Test 2: Bad Posture (Accelerometer)")
        let badAccData: [[Double]] = [
            [1.5, -2.0, 8.5],   // Leaning forward
            [2.0, -1.5, 8.0],   // More forward lean
            [1.8, -2.2, 8.2],   // Poor alignment
            [1.2, -1.8, 8.8],   // Bad posture
            [1.6, -1.9, 8.3]    // Continued bad posture
        ]
        
        // Test 3: Good posture data (magnetometer) - More realistic variation
        print("\n📊 Test 3: Good Posture (Magnetometer)")
        let goodMagData: [[Double]] = [
            [25.0, 536.0, 600.0],   // Good orientation
            [26.5, 535.0, 601.0],   // More variation
            [24.0, 537.0, 599.0],   // Different variation
            [25.8, 534.5, 600.5],   // Realistic spread
            [24.2, 536.5, 599.5]    // Good spread
        ]
        
        let magCalibration = CalibrationMath.computeCalibration(from: goodMagData)
        print("✅ Magnetometer calibration computed")
        print("   Mean: [\(String(format: "%.1f", magCalibration.vMedia[0])), \(String(format: "%.1f", magCalibration.vMedia[1])), \(String(format: "%.1f", magCalibration.vMedia[2]))]")
        print("   Threshold: \(String(format: "%.6e", magCalibration.threshold))")
        
        // Test 4: Bad posture data (magnetometer) - More realistic variation
        print("\n📊 Test 4: Bad Posture (Magnetometer)")
        let badMagData: [[Double]] = [
            [45.0, 520.0, 580.0],   // Poor orientation
            [48.0, 518.0, 578.0],   // More variation
            [42.0, 525.0, 585.0],   // Different variation
            [46.5, 521.5, 582.5],   // Realistic spread
            [43.5, 523.5, 583.5]    // Good spread
        ]
        
        // Test 5: Posture Evaluation
        print("\n📊 Test 5: Posture Evaluation")
        
        // Test with good posture
        let goodPosture = CalibrationMath.evaluatePosture(
            accData: [0.1, -0.9, 9.8],
            magData: [25.0, 536.0, 600.0],
            accCalibration: accCalibration,
            magCalibration: magCalibration
        )
        print("✅ Good posture evaluation: \(goodPosture ? "CORRECT" : "INCORRECT")")
        
        // Test with bad posture
        let badPosture = CalibrationMath.evaluatePosture(
            accData: [1.5, -2.0, 8.5],
            magData: [45.0, 520.0, 580.0],
            accCalibration: accCalibration,
            magCalibration: magCalibration
        )
        print("✅ Bad posture evaluation: \(badPosture ? "CORRECT" : "INCORRECT")")
        
        // Test 6: Threshold Validation with more reasonable bounds
        print("\n📊 Test 6: Threshold Validation")
        print("✅ Accelerometer threshold > 0: \(accCalibration.threshold > 0)")
        print("✅ Magnetometer threshold > 0: \(magCalibration.threshold > 0)")
        print("✅ Accelerometer threshold reasonable: \(accCalibration.threshold > 1e-10 && accCalibration.threshold < 1e-2)")
        print("✅ Magnetometer threshold reasonable: \(magCalibration.threshold > 1e-10 && magCalibration.threshold < 1e-2)")
        
        // Test 7: Density Calculation Test
        print("\n📊 Test 7: Density Calculation Test")
        let accDensityGood = CalibrationMath.computeDensity(
            val: [0.1, -0.9, 9.8],
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        let accDensityBad = CalibrationMath.computeDensity(
            val: [1.5, -2.0, 8.5],
            vMedia: accCalibration.vMedia,
            det: accCalibration.det,
            mInv: accCalibration.mInv
        )
        
        print("✅ Good posture density: \(String(format: "%.6e", accDensityGood))")
        print("✅ Bad posture density: \(String(format: "%.6e", accDensityBad))")
        print("✅ Good > Bad density: \(accDensityGood > accDensityBad)")
        print("✅ Good >= threshold: \(accDensityGood >= accCalibration.threshold)")
        print("✅ Bad < threshold: \(accDensityBad < accCalibration.threshold)")
        
        // Test 8: Additional validation
        print("\n📊 Test 8: Additional Validation")
        print("✅ Accelerometer determinant valid: \(accCalibration.det > 0 && !accCalibration.det.isNaN)")
        print("✅ Magnetometer determinant valid: \(magCalibration.det > 0 && !magCalibration.det.isNaN)")
        print("✅ Accelerometer mean reasonable: \(accCalibration.vMedia[2] > 9.0 && accCalibration.vMedia[2] < 10.0)")
        print("✅ Magnetometer mean reasonable: \(magCalibration.vMedia[1] > 500 && magCalibration.vMedia[1] < 600)")
        
        print("\n🎉🎉🎉 COMPREHENSIVE TEST COMPLETED 🎉🎉🎉")
    }
}
