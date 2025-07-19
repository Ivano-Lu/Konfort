//
//  LoginViewModel.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import Foundation
import SwiftUI

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
    
    @ObservedObject var calibrationData = CalibrationDataStore.shared;

    //login
    func login() {
        isLoader = true
        hasterminatedCallSucc = false

        guard let url = URL(string: "http://172.20.10.10:8080/graphql") else {
            print("❌ URL non valido")
            self.isLoader = false
            return
        }

        let query = """
        mutation login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
                token
                refreshToken
                userId
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
                        print("📦 JSON ricevuto: \(json)") // Log completo per debug

                        if let dataDict = json["data"] as? [String: Any],
                           let login = dataDict["login"] as? [String: Any],
                           let token = login["token"] as? String,
                           let refreshToken = login["refreshToken"] as? String,
                           let userId = login["userId"] as? Int ?? (login["userId"] as? String).flatMap({ Int($0) }) {


                            print("✅ Login riuscito, token: \(token), userId: \(userId)")
                            self?.isAuthenticated = true
                            self?.hasterminatedCallSucc = true
                            
                            // Save token and userId
                            UserDefaults.standard.set(token, forKey: "authToken")
                            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                            UserDefaults.standard.set(userId, forKey: "userId")
                            
                            // Fetch user data
                            self?.fetchUserData(userId: userId, token: token)

                            // Esegui la richiesta per la matrice di calibrazione
                            CalibrationService.shared.fetchCalibrationData(userId: userId) { success in
                                DispatchQueue.main.async {
                                    if success, let calibData = CalibrationService.shared.getCalibrationData() {
                                        print("✅ Matrice caricata: \(calibData.matrix)")
                                    } else {
                                        print("❌ Errore nel caricamento dati di calibrazione")
                                    }
                                }
                            }


                            // (Opzionale) Salva token e userId localmente
                            UserDefaults.standard.set(token, forKey: "authToken")
                            UserDefaults.standard.set(userId, forKey: "userId")

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
    
    private func fetchUserData(userId: Int, token: String) {
        guard let url = URL(string: "http://172.20.10.10:8080/graphql") else {
            print("❌ URL non valido per fetchUserData")
            return
        }

        let query = """
        query getUserById($id: Int!) {
            getUserById(id: $id) {
                id
                name
                surname
                email
            }
        }
        """

        let requestBody: [String: Any] = [
            "query": query,
            "variables": [
                "id": userId
            ],
            "operationName": "getUserById"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Errore nel serializzare il body JSON per fetchUserData: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Errore di rete per fetchUserData: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ Nessun dato ricevuto per fetchUserData")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("📦 JSON ricevuto per fetchUserData: \(json)")

                        if let dataDict = json["data"] as? [String: Any],
                           let user = dataDict["getUserById"] as? [String: Any],
                           let userName = user["name"] as? String,
                           let userSurname = user["surname"] as? String,
                           let userEmail = user["email"] as? String {
                            
                            let fullName = "\(userName) \(userSurname)"
                            print("✅ User data fetched: \(fullName), email: \(userEmail)")
                            
                            // Save user data
                            UserDataStore.shared.saveUserData(name: fullName, email: userEmail, userId: userId)
                            
                        } else if let errors = json["errors"] as? [[String: Any]] {
                            print("❌ Errore GraphQL per fetchUserData: \(errors)")
                        } else {
                            print("❌ Risposta sconosciuta per fetchUserData: \(json)")
                        }
                    }
                } catch {
                    print("❌ Errore nel parsing JSON per fetchUserData: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }
}
