//
//  LoginView.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var navigateToHome = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                LoginContentView(
                    firstInputText: $viewModel.email,
                    secondInputText: $viewModel.password, 
                    openView: $viewModel.hasterminatedCallSucc,
                    title: viewModel.title,
                    firstText: viewModel.insertName,
                    secondText: viewModel.insertPassword,
                    buttonPrimaryText: viewModel.loginButtonText,
                    buttonSecondaryText: viewModel.signinButtonText,
                    firstPlaceHolder: viewModel.placeholderName,
                    secondPlaceHolder: viewModel.placeholderPassword,
                    actionPrimaryButton: viewModel.login,
                    actionSecondaryButton: viewModel.tappedSignin,
                    alertMessage: viewModel.alertText,
                    alertButtonText: viewModel.alertButtonText
                )
                
                if viewModel.isLoader {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    LoaderView(text: viewModel.textLoader)
                    
                }
                
                if viewModel.isAuthenticated == false {
                    AlertView(message: viewModel.alertText, textButton: viewModel.alertButtonText) {
                        viewModel.isAuthenticated = nil
                    }
                }
            }
        }
    }
    
}

#Preview {
    LoginView()
}
