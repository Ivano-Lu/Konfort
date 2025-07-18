//
//  LoginContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import SwiftUI

struct LoginContentView: View {
    
    @Binding var firstInputText: String
    @Binding var secondInputText: String
    
    @State private var showAlert: Bool = false
    
    @Binding var openView: Bool
    
    let title: String
    let firstText: String
    let secondText: String
    
    let buttonPrimaryText: String
    let buttonSecondaryText: String
    
    let firstPlaceHolder: String
    let secondPlaceHolder: String
    
    let actionPrimaryButton: (() -> Void)?
    let actionSecondaryButton: (() -> Void)?
    
    let alertMessage: String
    let alertButtonText: String

    var body: some View {
        NavigationStack {
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
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(firstText)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            TextField(firstPlaceHolder, text: $firstInputText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(secondText)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            SecureField(secondPlaceHolder, text: $secondInputText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.17))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Login button
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
                    .navigationDestination(isPresented: $openView, destination: {
                        HomeView()
                            .navigationBarBackButtonHidden(true)
                    })
                    
                    // Sign up link
                    HStack {
                        Spacer()
                        NavigationLink {
                            SignupView()
                        } label: {
                            Text(buttonSecondaryText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .underline()
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                if showAlert {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    AlertView(message: alertMessage, textButton: alertButtonText) {
                        showAlert = false
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
