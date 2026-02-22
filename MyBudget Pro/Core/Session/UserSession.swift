//
//  UserSession.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 30/01/26.
//


import Foundation

final class UserSession {

    private static let nameKey = "user_name"

    static var userName: String? {
        get {
            UserDefaults.standard.string(forKey: nameKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: nameKey)
        }
    }

    static var isUserLoggedIn: Bool {
        userName != nil
    }
}