//
//  TokenStore.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import KeychainAccess

class TokenStore {

    typealias FetchAccessTokenCompletion = (Result<String, Error>) -> Void

    private let baseURL: URL

    private var refreshToken: String
    private var accessToken: String?

    private var fetchAccessTokenRequests: [FetchAccessTokenCompletion] = []


    init(authBaseURL: URL, tokenResponse: TokenResponse) {
        self.baseURL = authBaseURL
        self.refreshToken = tokenResponse.refreshToken
        self.accessToken = tokenResponse.accessToken
    }

    init(authBaseURL: URL, refreshToken: String) {
        self.baseURL = authBaseURL
        self.refreshToken = refreshToken
    }


    func fetchAccessToken(client: ClientCredentials, keychain: Keychain, completion: @escaping FetchAccessTokenCompletion) {
        if let token = self.accessToken {
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
                    self.refreshToken = response.refreshToken
                    self.accessToken = response.accessToken

                    try? keychain.set(response.refreshToken, key: "refresh_token")

                    res = .success(response.accessToken)
                }

                for request in self.fetchAccessTokenRequests {
                    request(res)
                }

                self.fetchAccessTokenRequests = []
            }
        }
    }

}
