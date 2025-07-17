//
//  CalibrationResult.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation

struct CalibrationResult: Codable {
    var vMedia: [Double]         // Mean vector [3]
    var mCov: [[Double]]         // Covariance matrix [3][3]
    var det: Double              // Determinant
    var mInv: [[Double]]         // Inverse covariance matrix [3][3]
    var sigma: [Double]          // Sigma vector [3]
    var threshold: Double        // Threshold
}

struct SensorData: Codable {
    let acc: [Double]  // [x, y, z]
    let mag: [Double]  // [x, y, z]
} 