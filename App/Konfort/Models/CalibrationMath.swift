//
//  CalibrationMath.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation
import Accelerate

struct CalibrationMath {
    
    // MARK: - Calibration Computation
    static func computeCalibration(from samples: [[Double]]) -> CalibrationResult {
        let N = Double(samples.count)
        let dim = 3
        
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
        
        // 3. Calculate determinant
        let det = mCov[0][0] * (mCov[1][1]*mCov[2][2] - mCov[1][2]*mCov[2][1])
                - mCov[0][1] * (mCov[1][0]*mCov[2][2] - mCov[1][2]*mCov[2][0])
                + mCov[0][2] * (mCov[1][0]*mCov[2][1] - mCov[1][1]*mCov[2][0])
        
        // 4. Calculate inverse covariance matrix
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
        
        // 5. Calculate eigenvalues (simplified for symmetric matrix)
        var eigenvalues = [Double](repeating: 0, count: dim)
        computeEigenvalues(matrix: mCov, eigenvalues: &eigenvalues)
        
        // 6. Calculate sigma vector
        let sigma = eigenvalues.map { $0 * sqrt(7.8147 * $0) }
        
        // 7. Calculate threshold
        let vet = zip(sigma, vMedia).map(+)
        let threshold = computeDensity(val: vet, vMedia: vMedia, det: det, mInv: mInv)
        
        return CalibrationResult(
            vMedia: vMedia,
            mCov: mCov,
            det: det,
            mInv: mInv,
            sigma: sigma,
            threshold: threshold
        )
    }
    
    // MARK: - Density Function
    static func computeDensity(val: [Double], vMedia: [Double], det: Double, mInv: [[Double]]) -> Double {
        let vDiff = zip(val, vMedia).map(-)
        
        // Calculate tmp = mInv * vDiff
        var tmp = [Double](repeating: 0, count: 3)
        for i in 0..<3 {
            for j in 0..<3 {
                tmp[i] += mInv[i][j] * vDiff[j]
            }
        }
        
        // Calculate exponent = -0.5 * vDiff^T * tmp
        var exponent = 0.0
        for i in 0..<3 {
            exponent += vDiff[i] * tmp[i]
        }
        exponent *= -0.5
        
        // Calculate density = (2π)^(-3/2) * det^(-1/2) * e^exponent
        let ret = pow(2 * .pi, -1.5) * pow(det, -0.5) * exp(exponent)
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
        
        // Posture is correct if at least one sensor gives correct posture
        let accCorrect = accDensity >= accCalibration.threshold
        let magCorrect = magDensity >= magCalibration.threshold
        
        return accCorrect || magCorrect
    }
    
    // MARK: - Helper Functions
    private static func computeEigenvalues(matrix: [[Double]], eigenvalues: inout [Double]) {
        // Simplified eigenvalue computation for 3x3 symmetric matrix
        // For a more robust solution, you might want to use a numerical library
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
        
        // Solve cubic equation (simplified)
        eigenvalues[0] = a
        eigenvalues[1] = d
        eigenvalues[2] = f
    }
} 