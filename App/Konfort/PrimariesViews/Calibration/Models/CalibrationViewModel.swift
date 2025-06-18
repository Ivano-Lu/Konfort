//
//  CalibrationViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 18/11/24.
//

import SwiftUI

struct Coordinates {
    var id = UUID()
    var name: String
    var x: Int
    var y: Int
    var z: Int
}

class CalibrationViewModel: ObservableObject {
    
    var title = "Calibrating the device is essential to ensure that the data accurately reflects your unique posture!"
    
    var subtitle = "Your current calibration"
    
    var titleButton = "Start calibration"
    
    @Published var coordinates: [Coordinates] = []
    
    
    init() {
        calculateValues()
    }
    
    private func calculateValues() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.coordinates.append(Coordinates(name: "Accellerometers", x: 2, y: 5, z: -6))
            self?.coordinates.append(Coordinates(name: "Magnetometers", x: 2, y: 5, z: 10))
            self?.coordinates.append(Coordinates(name: "Gyroscope", x: 2, y: 0, z: 6))
        }
        
    }
}
