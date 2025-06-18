//
//  HistoryViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 08/11/24.
//

import Foundation
import SwiftUI

enum StateHystortPercents: String {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case bad = "BAD"
    
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
    
    static func from(value: Int) -> StateHystortPercents {
        switch value {
        case 90...100:
            return .excellent
        case 50..<90:
            return .good
        default:
            return .bad
        }
    }
}

enum StateHystortCoordinates {
    case excellent
    case good
    case bad
    
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
    
    static func from(value: Int) -> StateHystortPercents {
        switch value {
        case 3...:
            return .excellent
        case 1..<3:
            return .good
        default:
            return .bad
        }
    }
}

class HistoryViewModel: ObservableObject {
    
    @Published var titleSection = "Posture"
    @Published var days: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @Published var todayScoreText = "Today Score "
    @Published var weeklyScroreText = "Weekly score"
    
    @Published var todayScore = "-"
    @Published var todayScoreColor = Color.red
    
    @Published var weeklyScore = "-"
    @Published var weeklyScoreColor = Color.red
    
    @Published var subTitleSection = "Posture data"
    @Published var xInfoTitle = "X avg"
    @Published var yInfoTitle = "Y avg"
    @Published var zInfoTitle = "Z avg"
    
    @Published var xInfoTitleColor = Color.red
    @Published var yInfoTitleColor = Color.red
    @Published var zInfoTitleColor = Color.red
    
    @Published var xInfoValue = "-°"
    @Published var yInfoValue = "-°"
    @Published var zInfoValue = "-°"
    
    @Published var hystoryPostureInfo = "-"
    @Published var hystoryPostureInfoColor = Color.gray
    
    var subInfo = "The posture data is referenced to your ideal posture angles."
    
    
    init() {
        reloadScores()
        reloadValueCoordinates()
        createTextInfo()
    }
    
    private func reloadScores() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            let todayScorenumber = 90
            let weeklyScoreNumber = 60
            
            let todayScore = StateHystortPercents.from(value: todayScorenumber)
            let weeklyScore = StateHystortPercents.from(value: weeklyScoreNumber)
            
            
            self?.todayScore = String(todayScorenumber).appending("%")
            self?.todayScoreColor = todayScore.color
            
            self?.weeklyScore = String(weeklyScoreNumber).appending("%")
            self?.weeklyScoreColor = weeklyScore.color
        }
    }
    
    private func reloadValueCoordinates() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            let xvalue = -2
            let yvalue = 2
            let zvalue = 6
            
            let x = StateHystortCoordinates.from(value: xvalue)
            let y = StateHystortCoordinates.from(value: yvalue)
            let z = StateHystortCoordinates.from(value: zvalue)
            
            self?.xInfoTitleColor = x.color
            self?.yInfoTitleColor = y.color
            self?.zInfoTitleColor = z.color
            
            // fare il controllo
            self?.xInfoValue = "+\(xvalue)°"
            self?.yInfoValue = "+\(yvalue)°"
            self?.zInfoValue = "+\(zvalue)°"
        }
    }
    
    private func createTextInfo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            var text = "GOOD"
            self?.hystoryPostureInfo = "Based on your history you’re \(text) "
            
            self?.hystoryPostureInfoColor = StateHystortPercents(rawValue: text)?.color ?? Color.gray
            
            
        }
    }
    
    
}

