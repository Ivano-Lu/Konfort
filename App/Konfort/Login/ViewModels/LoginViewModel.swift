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
    
    @Published var alertText = "Username or password not valid"
    @Published var alertButtonText = "Ok"
    
    @Published var email: String = ""
    @Published var password: String = ""
        
    
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

        guard let url = URL(string: "http://192.168.88.40:8080/graphql") else {
            print("❌ URL non valido")
            self.isLoader = false
            return
        }

        let query = """
        mutation login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
                token
            }
        }
        """

        let requestBody: [String: Any] = [
            "query": query,
            "variables": [
                "email": email,
                "password": password
            ],
            "operationName": "login"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Errore nel serializzare il body JSON: \(error)")
            self.isLoader = false
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoader = false

                if let error = error {
                    print("❌ Errore di rete: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                guard let data = data else {
                    print("❌ Nessun dato ricevuto")
                    self?.isAuthenticated = false
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let dataDict = json["data"] as? [String: Any],
                           let login = dataDict["login"] as? [String: Any],
                           let token = login["token"] as? String {
                            print("✅ Login riuscito, token: \(token)")
                            self?.isAuthenticated = true
                            self?.hasterminatedCallSucc = true
                            // Salva il token se necessario
                        } else if let errors = json["errors"] as? [[String: Any]] {
                            print("❌ Errore GraphQL: \(errors)")
                            self?.isAuthenticated = false
                        } else {
                            print("❌ Risposta sconosciuta: \(json)")
                            self?.isAuthenticated = false
                        }
                    }
                } catch {
                    print("❌ Errore nel parsing JSON: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                }
            }
        }

        task.resume()
    }

    
    func tappedSignin() {
        hasTappedSignButton = true
    }
}
