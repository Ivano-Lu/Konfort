//
//  ChipView.swift
//  Konfort
//
//  Created by Ledda, Silvia on 03/11/24.
//

import SwiftUI

struct ChipUIItem {
    var title: String
    var isSelected: Bool
    var action: () -> Void
}

struct ChipView: View {
   
    var item: ChipUIItem

    var body: some View {
        Button(action: item.action) {
            Text(item.title)
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(item.isSelected ? Color(red: 0.2, green: 0.2, blue: 0.22) : Color(red: 0.15, green: 0.15, blue: 0.17))
                .foregroundColor(item.isSelected ? .white : .gray)
                .cornerRadius(12)
        }
    }
}
