//
//  CalibrationDataStore.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation

class CalibrationDataStore: ObservableObject {
    @Published var matrix: [[Double]] = []
    @Published var invertedMatrix: [[Double]] = []
    @Published var determinant: Double = 0.0

    static let shared = CalibrationDataStore()

    private init() {}
}
