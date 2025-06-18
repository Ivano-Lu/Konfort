//
//  AlertView.swift
//  Konfort
//
//  Created by LIvano Lu on 27/10/24.
//

import SwiftUI

struct AlertView: View {
    let message: String
    let textButton: String
    let onDismiss: (() -> Void)?
    

        var body: some View {
            VStack(spacing: 20) {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.black)
                
                Button(action: {
                    onDismiss?()
                }) {
                    Text(textButton)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .frame(maxWidth: 300)   
        }
}

#Preview {
    AlertView(message: "Prova", textButton: "Ok", onDismiss: nil)
}
