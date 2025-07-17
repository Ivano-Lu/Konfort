//
//  CalibrationDataStore.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation

class CalibrationDataStore: ObservableObject {
    @Published var accCalibration: CalibrationResult?
    @Published var magCalibration: CalibrationResult?
    
    // Legacy properties for backward compatibility
    @Published var matrix: [[Double]] = []
    @Published var invertedMatrix: [[Double]] = []
    @Published var determinant: Double = 0.0

    static let shared = CalibrationDataStore()

    private init() {}
    
    // MARK: - Calibration Data Management
    func setAccCalibration(_ calibration: CalibrationResult) {
        self.accCalibration = calibration
    }
    
    func setMagCalibration(_ calibration: CalibrationResult) {
        self.magCalibration = calibration
    }
    
    func getAccCalibration() -> CalibrationResult? {
        return self.accCalibration
    }
    
    func getMagCalibration() -> CalibrationResult? {
        return self.magCalibration
    }
    
    func hasCalibrationData() -> Bool {
        return accCalibration != nil && magCalibration != nil
    }
    
    func clearCalibrationData() {
        accCalibration = nil
        magCalibration = nil
        matrix = []
        invertedMatrix = []
        determinant = 0.0
    }
}
