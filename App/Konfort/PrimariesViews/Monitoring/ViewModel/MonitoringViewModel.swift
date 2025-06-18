//
//  MonitoringViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 07/11/24.
//

import Foundation
import SwiftUI

enum StateMonitoring: String {
    case excellent = "Eccellente"
    case good = "Buono"
    case bad = "Cattivo"

    
    var color: Color {
        switch self {
        case .excellent:
            return Color.green
        case .good:
            return Color.yellow
        case .bad:
            return Color.red
        }
    }
    
    static func from(sliderValue: Double) -> StateMonitoring {
        switch sliderValue {
        case 90...100:
            return .excellent
        case 50..<90:
            return .good
        default:
            return .bad
        }
    }
    
    static func color(from value: Double) -> Color {
        switch value {
        case 90...:
            return Color.green
        case 50..<90:
            return Color.yellow
        default:
            return Color.red
        }
    }
    
    static func color(from value: Int) -> Color {
        switch value {
        case 6...:
            return Color.red
        case 0..<6:
            return Color.yellow
        default:
            return Color.green
        }
    }
}

class MonitoringViewModel: ObservableObject {
    
    @Published var sliderValue: Double = 0 {
        didSet {
            updateState()
        }
    }
    
    @Published var description = "Information on current inclination and situation, maybe write about how he's doing or a motivational quote i don't know"
    @Published var isLoader: Bool = false
    @Published var state: StateMonitoring = .bad
    
    init() {
        self.updateSliderInfo()
    }
    
    func updateSliderValue(fromAPI value: Double) {
        self.sliderValue = value
        self.updateState()
    }
    
    private func updateState() {
        self.state = StateMonitoring.from(sliderValue: sliderValue)
    }
    
    private func updateSliderInfo() {
        
        isLoader = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.sliderValue = 80
            self?.isLoader = false
        }
    }
}
