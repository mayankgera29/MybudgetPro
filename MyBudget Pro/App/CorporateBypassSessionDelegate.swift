//
//  CorporateBypassSessionDelegate.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 30/01/26.
//


import Foundation

final class CorporateBypassSessionDelegate: NSObject, URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // ⚠️ DEV ONLY – accept corporate SSL cert
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}