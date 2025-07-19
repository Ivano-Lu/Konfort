//
//  UserDataStore.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import Foundation

class UserDataStore: ObservableObject {
    static let shared = UserDataStore()
    
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userId: Int = 0
    @Published var isLoggedIn: Bool = false
    
    private init() {
        loadUserData()
    }
    
    func saveUserData(name: String, email: String, userId: Int) {
        self.userName = name
        self.userEmail = email
        self.userId = userId
        self.isLoggedIn = true
        
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    
    func loadUserData() {
        if let name = UserDefaults.standard.string(forKey: "userName") {
            self.userName = name
        }
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.userEmail = email
        }
        self.userId = UserDefaults.standard.integer(forKey: "userId")
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func clearUserData() {
        self.userName = ""
        self.userEmail = ""
        self.userId = 0
        self.isLoggedIn = false
        
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
} 