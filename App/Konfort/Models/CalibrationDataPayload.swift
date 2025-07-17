//
//  CalibrationDataPayload.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation

struct CalibrationDataPayload {
    let id: String
    let matrix: [[Double]]
    let invertedMatrix: [[Double]]
    let determinant: Double
}

// MARK: - New Calibration Types
struct CalibrationResult: Codable {
    var vMedia: [Double]         // Mean vector [3]
    var mCov: [[Double]]         // Covariance matrix [3][3]
    var det: Double              // Determinant
    var mInv: [[Double]]         // Inverse covariance matrix [3][3]
    var sigma: [Double]          // Sigma vector [3]
    var threshold: Double        // Threshold
}

// MARK: - Sensor Data Structures
struct SensorVector: Codable {
    let x: Double
    let y: Double
    let z: Double
    
    func toArray() -> [Double] {
        return [x, y, z]
    }
}

struct SensorData: Codable {
    let acc: SensorVector
    let mag: SensorVector
    
    func toArrays() -> (acc: [Double], mag: [Double]) {
        return (acc: acc.toArray(), mag: mag.toArray())
    }
}
