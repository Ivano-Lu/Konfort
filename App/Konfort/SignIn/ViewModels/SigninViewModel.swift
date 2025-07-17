//
//  SigninViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 30/10/24.
//

import Foundation
import SwiftUI

struct InfoFieldUIItem: Identifiable {
    let id = UUID()
    let title: String
    let placeholder: String
    let isSecure: Bool
    var binding: Binding<String>
}

class SigninViewModel: ObservableObject {
    @Published var title: String = "Benvenuto  in KONFORT"
    
    var insertNameText = "Inserisci nome utente"
    var insertLastNameText = "Inserisci cognome"
    var insertEmailText = "Inserisci email"
    var insertPasswordText = "Inserisci password"
    var insertConfirmPasswordtext = "Conferma password"
   
    @Published var signinButtonText = "Registrati"
    @Published var loginButtonText = "Ti sei già registrato? Accedi"
    
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

    
    func addInputInfo() {
        inputInfo = [
            InfoFieldUIItem(title: insertNameText, placeholder: placeholderName, isSecure: false, binding: Binding(get: { self.name }, set: { self.name = $0 })),
            InfoFieldUIItem(title: insertLastNameText, placeholder: placeholderLastName, isSecure: false, binding: Binding(get: { self.lastName }, set: { self.lastName = $0 })),
            InfoFieldUIItem(title: insertEmailText, placeholder: placeholderEmail, isSecure: false, binding: Binding(get: { self.email }, set: { self.email = $0 })),
            InfoFieldUIItem(title: insertPasswordText, placeholder: placeholderPassword, isSecure: true, binding: Binding(get: { self.password }, set: { self.password = $0 })),
            InfoFieldUIItem(title: insertConfirmPasswordtext, placeholder: placeholderConfirmPassword, isSecure: true, binding: Binding(get: { self.confirmPassword }, set: { self.confirmPassword = $0 }))
        ]
    }

    
    func signinTapped() {
        
        showAlert = false
        
        registerUser()
        
      //  openView = !showAlert
    }
    
    func registerUser() {
        showAlert = false

        guard password == confirmPassword else {
            errorEmptyFields = "Le password non combaciano"
            showAlert = true
            return
        }

        isLoader = true

        let query = """
        mutation AddUser($name: String!, $surname: String!, $email: String!, $password: String!) {
            addUser(name: $name, surname: $surname, email: $email, password: $password) {
                id
            }
        }
        """

        let variables: [String: String] = [
            "name": self.name,
            "surname": self.lastName,
            "email": self.email,
            "password": self.password
        ]

        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "AddUser"
        ]

        guard let url = URL(string: "http://172.20.10.10:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("❌ URL o body invalido")
            isLoader = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoader = false
            }

            if let error = error {
                print("❌ Errore richiesta: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert = true
                }
                return
            }

            guard let data = data else {
                print("❌ Nessun dato ricevuto")
                DispatchQueue.main.async {
                    self?.showAlert = true
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                print("📦 JSON ricevuto: \(json ?? [:])") // LOG COMPLETO DELLA RISPOSTA

                if let errors = json?["errors"] as? [[String: Any]],
                   let message = errors.first?["message"] as? String {
                    print("❌ Errore GraphQL: \(message)")
                    DispatchQueue.main.async {
                        self?.errorEmptyFields = message
                        self?.showAlert = true
                    }
                    return
                }

                if let data = json?["data"] as? [String: Any],
                   let addUser = data["addUser"] as? [String: Any],
                   let id = addUser["id"] as? Int {
                    print("✅ Registrazione avvenuta con successo. ID: \(id)")
                    DispatchQueue.main.async {
                                        self?.isRegistrated = true
                                        self?.loginAfterRegistration()
                                    }
                } else {
                    print("❌ Risposta inattesa dal server: \(json ?? [:])") // STAMPA ANCHE QUI PER SICUREZZA
                    DispatchQueue.main.async {
                        self?.showAlert = true
                    }
                }
            } catch {
                print("❌ Errore parsing JSON: \(error)")
                DispatchQueue.main.async {
                    self?.showAlert = true
                }
            }

        }.resume()
    }
    
    func loginAfterRegistration() {
        let query = """
        mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
                token
                refreshToken
            }
        }
        """

        let variables: [String: String] = [
            "email": email,
            "password": password
        ]

        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "Login"
        ]

        guard let url = URL(string: "http://172.20.10.10:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("❌ URL o body invalido (login)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Errore richiesta login: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ Nessun dato ricevuto dal login")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("📦 JSON login: \(json ?? [:])")

                if let errors = json?["errors"] as? [[String: Any]],
                   let message = errors.first?["message"] as? String {
                    print("❌ Errore login GraphQL: \(message)")
                    return
                }

                if let data = json?["data"] as? [String: Any],
                   let login = data["login"] as? [String: Any],
                   let token = login["token"] as? String,
                   let refreshToken = login["refreshToken"] as? String {
                    print("✅ Login effettuato. Token: \(token), RefreshToken: \(refreshToken)")
                    DispatchQueue.main.async {
                        self?.navigateToHome = true
                    }
                } else {
                    print("❌ Risposta inattesa dal login")
                }

            } catch {
                print("❌ Errore parsing JSON login: \(error)")
            }
        }.resume()
    }


    
    func showLoginView() {
        hasTappedLoginButton = true
    }
}
