//
//  SignupContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 30/10/24.
//

import SwiftUI


struct SignupContentView: View {
    @ObservedObject var viewModel: SigninViewModel

    let title: String
    let buttonPrimaryText: String
    let buttonSecondaryText: String

    let actionPrimaryButton: (() -> Void)?
    let actionSecondaryButton: (() -> Void)?

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .multilineTextAlignment(.center)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Nome", text: $viewModel.name)
                    TextField("Cognome", text: $viewModel.lastName)
                    TextField("Email", text: $viewModel.email)
                    SecureField("Password", text: $viewModel.password)
                    SecureField("Conferma Password", text: $viewModel.confirmPassword)

                    Button(action: {
                        actionSecondaryButton?()
                    }) {
                        Text(buttonSecondaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                            .foregroundColor(.blue)
                            .underline()
                    }

                    Button(action: {
                        actionPrimaryButton?()
                    }) {
                        Text(buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding()
            }
        }
    }
}

   
#Preview {
    SignupView()
}
