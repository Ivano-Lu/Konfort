//
//  SignupContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 30/10/24.
//

import SwiftUI


struct SignupContentView: View {
    
   
    @State private var openView: Bool = false
    
    @Binding var inputInfo: [InfoFieldUIItem]
    
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
                ZStack {
                    VStack {
                        
                        VStack {
                            
                            ForEach(inputInfo.indices, id: \.self) { index in
                                CustomTextField(
                                    title: inputInfo[index].title,
                                    placeholder: inputInfo[index].placeholder,
                                    isSecure: inputInfo[index].isSecure,
                                    text: $inputInfo[index].text
                                )
                            }
                          
                                Button(action: {
                                    actionSecondaryButton?()
                                }) {
                                    Text(buttonSecondaryText)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding()
                                        .foregroundColor(.white)
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
                            
                            
                            .fullScreenCover(isPresented: $openView, content: {
                                SignupView()
                            })
                            
                            Spacer()
                            
                            
                        }
                        .padding()
                    }
                    
//                    if showAlert {
//                        Color.black.opacity(0.4)
//                            .edgesIgnoringSafeArea(.all)
//                        
//                        AlertView(message: alertMessage, textButton: alertButtonText) {
//                            showAlert = false
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                    }
                }
            }
        }
    }
}
   
#Preview {
    SignupView()
}
