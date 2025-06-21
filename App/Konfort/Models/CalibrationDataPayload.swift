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
