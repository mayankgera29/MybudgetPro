//
//  ExchangeRateService.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 30/01/26.
//
import Foundation

struct ExchangeRateResponse: Decodable {
    let rates: [String: Double]
}

final class ExchangeRateService {

    func fetchINRtoUSD() async throws -> Double {
        let url = URL(string: "https://open.er-api.com/v6/latest/INR")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)

        guard let usd = decoded.rates["USD"] else {
            throw URLError(.badServerResponse)
        }
        return usd
    }
}
