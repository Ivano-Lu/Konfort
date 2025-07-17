//
//  CalibrationMathTests.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation

// Simple test functions to verify calibration math
struct CalibrationMathTests {
    
    static func testCalibrationComputation() {
        print("🧪 Testing Calibration Computation...")
        
        // Create sample data (simulating sensor readings)
        let sampleData: [[Double]] = [
            [0.1, -0.9, 9.8],   // acc sample 1
            [0.2, -0.8, 9.7],   // acc sample 2
            [0.0, -1.0, 9.9],   // acc sample 3
            [0.15, -0.85, 9.75], // acc sample 4
            [0.05, -0.95, 9.85]  // acc sample 5
        ]
        
        // Compute calibration
        let calibration = CalibrationMath.computeCalibration(from: sampleData)
        
        print("✅ Calibration computed successfully!")
        print("   Mean vector: \(calibration.vMedia)")
        print("   Determinant: \(calibration.det)")
        print("   Threshold: \(calibration.threshold)")
        
        // Test density computation
        let testValue = [0.1, -0.9, 9.8]
        let density = CalibrationMath.computeDensity(
            val: testValue,
            vMedia: calibration.vMedia,
            det: calibration.det,
            mInv: calibration.mInv
        )
        
        print("   Density for test value: \(density)")
        print("   Posture correct: \(density >= calibration.threshold)")
    }
    
    static func testPostureEvaluation() {
        print("🧪 Testing Posture Evaluation...")
        
        // Create sample calibration data
        let accSamples: [[Double]] = [
            [0.1, -0.9, 9.8],
            [0.2, -0.8, 9.7],
            [0.0, -1.0, 9.9]
        ]
        
        let magSamples: [[Double]] = [
            [45.0, -12.0, 18.0],
            [45.5, -12.5, 18.5],
            [44.5, -11.5, 17.5]
        ]
        
        let accCalibration = CalibrationMath.computeCalibration(from: accSamples)
        let magCalibration = CalibrationMath.computeCalibration(from: magSamples)
        
        // Test with good posture
        let goodPosture = CalibrationMath.evaluatePosture(
            accData: [0.1, -0.9, 9.8],
            magData: [45.0, -12.0, 18.0],
            accCalibration: accCalibration,
            magCalibration: magCalibration
        )
        
        // Test with bad posture
        let badPosture = CalibrationMath.evaluatePosture(
            accData: [2.0, 2.0, 5.0], // Very different from calibration
            magData: [100.0, 100.0, 100.0], // Very different from calibration
            accCalibration: accCalibration,
            magCalibration: magCalibration
        )
        
        print("✅ Posture evaluation test completed!")
        print("   Good posture detected: \(goodPosture)")
        print("   Bad posture detected: \(badPosture)")
    }
    
    static func runAllTests() {
        print("🚀 Running Calibration Math Tests...")
        testCalibrationComputation()
        testPostureEvaluation()
        print("✅ All tests completed!")
    }
} 