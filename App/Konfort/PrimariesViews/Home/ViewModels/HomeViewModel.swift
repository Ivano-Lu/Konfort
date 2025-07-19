//
//  HomeViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 04/11/24.
//

import Foundation


enum Tab {
    case monitoring, calibration
}

class HomeViewModel: ObservableObject {
    
    @Published var chips: [ChipUIItem] = []
    @Published var selectTab: Tab = .monitoring {
        didSet {
            updateChips() 
        }
    }
    
    
    init() {
        updateChips()
    }
    
    private func updateChips() {
        chips = [ChipUIItem(title: "Monitoring", isSelected: selectTab == .monitoring, action: { [weak self] in
            self?.selectTab = .monitoring
        }),
                 ChipUIItem(title: "Calibration", isSelected: selectTab == .calibration, action: { [weak self] in
            self?.selectTab = .calibration
            
        })]
    }
    

}
