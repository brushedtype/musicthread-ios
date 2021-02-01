//
//  TokenStore.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import KeychainAccess
import JWTDecode

public class TokenStore {

    typealias FetchAccessTokenCompletion = (Result<String, Error>) -> Void

    private let baseURL: URL

    private var refreshToken: String
    private var accessToken: String?

    private var tokenExpirationDate: Date = .distantPast

    private var fetchAccessTokenRequests: [FetchAccessTokenCompletion] = []


    public init(authBaseURL: URL, tokenResponse: TokenResponse) {
        self.baseURL = authBaseURL
        self.refreshToken = tokenResponse.refreshToken
        self.accessToken = tokenResponse.accessToken
    }

    public init(authBaseURL: URL, refreshToken: String) {
        self.baseURL = authBaseURL
        self.refreshToken = refreshToken
    }


    private func isTokenExpired() -> Bool {
        guard self.accessToken != nil else {
            return true
        }

        let leeway: TimeInterval = 120 // refresh token 2 minutes before real expiry
        let remainingTime = self.tokenExpirationDate.timeIntervalSinceNow

        return remainingTime <= leeway
    }

    func fetchAccessToken(client: ClientCredentials, keychain: Keychain, completion: @escaping FetchAccessTokenCompletion) {
        if let token = self.accessToken, self.isTokenExpired() == false {
            return completion(.success(token))
        }

        DispatchQueue.main.async {
            guard self.fetchAccessTokenRequests.isEmpty else {
                self.fetchAccessTokenRequests.append(completion)
                return
            }

            self.fetchAccessTokenRequests.append(completion)

            client.refreshToken(refreshToken: self.refreshToken) { (result) in
                let res: Result<String, Error>

                switch result {
                case .failure(let err):
                    try? keychain.remove("refresh_token")

                    res = .failure(err)

                case .success(let response):
                    let jwtResult = Result(catching: { try decode(jwt: response.accessToken) })

                    switch jwtResult {
                    case .failure(let err):
                        try? keychain.remove("refresh_token")
                        res = .failure(err)

                    case .success(let jwt):
                        self.refreshToken = response.refreshToken
                        self.accessToken = response.accessToken
                        self.tokenExpirationDate = jwt.expiresAt ?? Date().addingTimeInterval(60 * 60)

                        try? keychain.set(response.refreshToken, key: "refresh_token")

                        res = .success(response.accessToken)
                    }
                }

                for request in self.fetchAccessTokenRequests {
                    request(res)
                }

                self.fetchAccessTokenRequests = []
            }
        }
    }

}
