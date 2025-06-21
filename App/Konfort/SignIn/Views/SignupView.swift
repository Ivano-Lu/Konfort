//
//  SignupView.swift
//  Konfort
//
//  Created by Ivano Lu on 28/10/24.

import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SigninViewModel()
    @State var showAlert: Bool = false
    
    var body: some View {
        
      
        
        ZStack {
            SignupContentView(
                viewModel: viewModel,
                title: viewModel.title,
                buttonPrimaryText: viewModel.signinButtonText,
                buttonSecondaryText: viewModel.loginButtonText,
                actionPrimaryButton: viewModel.signinTapped,
                actionSecondaryButton: viewModel.showLoginView)
            
            if viewModel.showAlert {
                AlertView(message: viewModel.errorEmptyFields, textButton: viewModel.alertErrorButtonText) {
                    viewModel.showAlert = false
                }
            }
            
            if viewModel.hasTappedLoginButton {
                LoginView()
                      .transition(.opacity) // Opzionale: transizione fluida
                      .zIndex(1)
            }
            
        }

    }
    
}

#Preview {
    SignupView()
}
