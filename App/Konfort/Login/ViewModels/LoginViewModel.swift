//
//  LoginViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var title: String = "Benvenuto  in KONFORT"
    @Published var insertName = "Inserisci nome utente"
    @Published var insertPassword = "Inserisci password"
    @Published var loginButtonText = "Accedi"
    @Published var signinButtonText = "Registrati"
    
    @Published var placeholderName = "Nome utente"
    @Published var placeholderPassword = "Password"
    
    @Published var alertText = "Inserisci nome utente e password"
    @Published var alertButtonText = "Ok"
    
    @Published var email: String = "A"
    @Published var password: String = "A"
        
    
    @Published var isAuthenticated: Bool? = nil
    @Published var isLoader: Bool = false
    
    @Published var hasTappedSignButton: Bool = false
    
    @Published var navigateToHome = false
    @Published var navigateToRegister = false

    @Published var hasterminatedCallSucc = false

    
    @Published var textLoader: String = "Caricamento..."
    //login
        func login() {
            isLoader = true
            hasterminatedCallSucc = false
            // Chiamata per accesso
            print("Email: \(email), Password: \(password)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        // Verifica se la password è corretta
                if self?.email == "A" {
                            self?.isAuthenticated = true // L'utente è autenticato
                            self?.hasterminatedCallSucc = true
                        } else {
                            self?.isAuthenticated = false // Password errata
                        }
                self?.isLoader = false
            }
        }
    
    func tappedSignin() {
        hasTappedSignButton = true
    }
}
