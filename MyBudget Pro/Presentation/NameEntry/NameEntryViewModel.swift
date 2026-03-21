//
//  NameEntryViewModel.swift
//  MyBudget Pro
//

import Foundation

final class NameEntryViewModel {

    func isValid(name: String?) -> Bool {
        guard let name = name?.trimmingCharacters(in: .whitespaces) else { return false }
        return !name.isEmpty
    }

    func saveName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        UserSession.userName = trimmed
    }
}
