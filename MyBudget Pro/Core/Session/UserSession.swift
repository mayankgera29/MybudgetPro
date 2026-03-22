//
//  UserSession.swift
//  MyBudget Pro
//

import Foundation

final class UserSession {

    private static let nameKey    = "user_name"
    private static let avatarKey  = "user_avatar_color"
    private static let meIdKey    = "user_me_id"

    // MARK: - Name
    static var userName: String? {
        get { UserDefaults.standard.string(forKey: nameKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: nameKey) }
    }

    // MARK: - Avatar color (hex)
    static var avatarColor: String {
        get { UserDefaults.standard.string(forKey: avatarKey) ?? "#6366F1" }
        set { UserDefaults.standard.setValue(newValue, forKey: avatarKey) }
    }

    // MARK: - Stable UUID for "me" in split expenses
    static var meId: UUID {
        if let stored = UserDefaults.standard.string(forKey: meIdKey),
           let uuid = UUID(uuidString: stored) {
            return uuid
        }
        let new = UUID()
        UserDefaults.standard.setValue(new.uuidString, forKey: meIdKey)
        return new
    }

    // MARK: - "Me" as a Person
    static var mePerson: Person {
        Person(id: meId, name: userName ?? "Me", avatarColor: avatarColor)
    }

    static var isUserLoggedIn: Bool { userName != nil }
}
