//
//  CustomTextField.swift
//  Konfort
//
//  Created by Ivano Lu on 24/11/24.
//

import SwiftUI

struct CustomTextField: View {
    var title: String
    var placeholder: String 
    var isSecure: Bool
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.callout)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                    .autocapitalization(.none)
            }
           
                
        }
        .padding(.bottom, 22)
    }
}


