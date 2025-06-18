//
//  SigninViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 30/10/24.
//

import Foundation

struct InfoFieldUIItem {
    var id = UUID()
    var title: String
    var placeholder: String
    var text: String
    var isSecure: Bool
}

class SigninViewModel: ObservableObject {
    @Published var title: String = "Benvenuto  in KONFORT"
    
    var insertNameText = "Inserisci nome utente"
    var insertLastNameText = "Inserisci cognome"
    var insertEmailText = "Inserisci email"
    var insertPasswordText = "Inserisci password"
    var insertConfirmPasswordtext = "Conferma password"
   
    @Published var signinButtonText = "Registrati"
    @Published var loginButtonText = "Ti sei già regosrato? Accedi"
    
    var placeholderName = "Inserisci nome"
    var placeholderLastName = "Inserisci cognome"
    var placeholderEmail = "Inserisci email"
    var placeholderPassword = "Inserisci password"
    var placeholderConfirmPassword = "Conferma password"
    
    
    @Published var inputInfo: [InfoFieldUIItem] = []
    
    @Published var errorEmptyFields = "Compila tutti i campi"
    @Published var alertErrorButtonText = "Ok"
    
    @Published var name: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
        
    
    @Published var isLoader: Bool = false
    
    @Published var hasTappedLoginButton: Bool = false
    
    @Published var navigateToHome = false
    @Published var navigateToRegister = false
    
    @Published var isRegistrated: Bool = false
    @Published var showAlert: Bool = false

    
    @Published var textLoader: String = "Caricamento..."
    
    init() {
        addInputInfo()
    }
    
//        func login() {
//            isLoader = true
//            // Chiamata per accesso
//            print("Email: \(email), Password: \(password)")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
//                        // Verifica se la password è corretta
//                if self?.email == "A" {
//                            self?.isAuthenticated = true // L'utente è autenticato
//                        } else {
//                            self?.isAuthenticated = false // Password errata
//                        }
//                self?.isLoader = false
//            }
//        }

    
    private func addInputInfo() {

        inputInfo = [
            InfoFieldUIItem(title: insertNameText, placeholder: placeholderName, text: name, isSecure: false),
            InfoFieldUIItem(title: insertLastNameText, placeholder: placeholderLastName, text: lastName, isSecure: false),
            InfoFieldUIItem(title: insertEmailText, placeholder: placeholderEmail, text: email, isSecure: false),
            InfoFieldUIItem(title: insertPasswordText, placeholder: placeholderPassword, text: password, isSecure: true),
            InfoFieldUIItem(title: insertConfirmPasswordtext, placeholder: placeholderConfirmPassword, text: confirmPassword, isSecure: true)
        ]
    }
    
    func signinTapped() {
        
        showAlert = false
        inputInfo.forEach { fied in
            
            if fied.text.isEmpty{
                showAlert = true
            }
            
        }
                    
      //  openView = !showAlert
    }
    
    func showLoginView() {
        hasTappedLoginButton = true
    }
}
