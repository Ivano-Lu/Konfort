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
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(item.isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(item.isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}
