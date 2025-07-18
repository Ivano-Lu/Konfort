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
        ZStack {
            // Dark background
            Color(red: 0.1, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Welcome section
                VStack(spacing: 8) {
                    Text("WELCOME TO")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("KONFORT")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                    
                    Text("Stay aligned!")
                        .font(.system(size: 16, weight: .medium))
                        .italic()
                        .foregroundColor(.gray)
                }
                
                // Input fields section
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField("Nome", text: $viewModel.name)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.words)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cognome")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField("Cognome", text: $viewModel.lastName)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.words)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField("Email", text: $viewModel.email)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            SecureField("Password", text: $viewModel.password)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Conferma Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            SecureField("Conferma Password", text: $viewModel.confirmPassword)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                // Sign up button
                Button(action: {
                    actionPrimaryButton?()
                }) {
                    Text(buttonPrimaryText.uppercased())
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.4, green: 0.9, blue: 0.7)) // Mint green
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                
                // Login link
                HStack {
                    Spacer()
                    Button(action: {
                        actionSecondaryButton?()
                    }) {
                        Text(buttonSecondaryText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .underline()
                    }
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

   
#Preview {
    SignupView()
}
