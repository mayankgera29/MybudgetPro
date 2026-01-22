//
//  FileStorageService.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import Foundation

final class FileStorageService {

    static let shared = FileStorageService()
    private init() {}

    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("expenses.json")
    }

    func save<T: Codable>(_ data: T) {
        guard let url = fileURL else { return }
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)
        } catch {
            print("File save error:", error.localizedDescription)
        }
    }

    func load<T: Codable>() -> T? {
        guard
            let url = fileURL,
            FileManager.default.fileExists(atPath: url.path)
        else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("File load error:", error.localizedDescription)
            return nil
        }
    }
}
