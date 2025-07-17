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
                VStack {
                    
                    Text(title)
                        .font(.largeTitle)
                        .padding(.horizontal, 28)
                        .padding(.top, 28)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading) {
                        
                        Text(firstText)
                            .font(.callout)
                        
                        TextField(firstPlaceHolder, text: $firstInputText)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .autocapitalization(.none)
                            .padding(.bottom, 22)
                        
                        Text(secondText)
                            .font(.callout)
                        SecureField(secondPlaceHolder, text: $secondInputText)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                        
                        
                        HStack {
                            
//                            Button(buttonSecondaryText) {
//                                actionSecondaryButton?()
//                            }
//                            .frame(alignment: .trailing)
//                            .padding()
//                            .foregroundColor(.white)
//                            .underline()
                            
                            
                            
                            // VEDERE SE SI PUO FARE MEGLIO
                            NavigationLink {
                                SignupView()
                            } label: {
                                Text(buttonSecondaryText)
                                    
                                    .frame(alignment: .trailing)
                                    .padding()
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 20)
                        
                        
                        Button(action: {
                            
//                            if firstInputText.isEmpty || secondInputText.isEmpty {
//                                //showAlert = true
//                            } else {
//                              //  showAlert = false
//                            }
                            actionPrimaryButton?()
                          //  openView = !showAlert
                        }) {
                            Text(buttonPrimaryText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .navigationDestination(isPresented: $openView, destination: {
                            HomeView()
                                .navigationBarBackButtonHidden(true)
                        })
                        
                        Spacer()
                        
                        
                    }
                    .padding()
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
