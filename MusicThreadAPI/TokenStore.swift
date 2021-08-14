//
//  TokenStore.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import KeychainAccess
import JWTDecode

public actor TokenStore {

    typealias FetchAccessTokenCompletion = (Result<String, Error>) -> Void

    private let baseURL: URL
    private let keychain: Keychain

    private var accessToken: String? {
        return try? self.keychain.getString("access_token")
    }

    private var refreshToken: String? {
        return try? self.keychain.getString("refresh_token")
    }

    private var isAccessTokenExpired: Bool {
        guard let tok = self.accessToken, let jwt = try? decode(jwt: tok) else {
            return true
        }
        return jwt.expired
    }

    var isAuthenticated: Bool {
        return self.refreshToken != nil
    }

    private var fetchAccessTokenRequests: Task<String, Error>?


    public init(authBaseURL: URL, keychain: Keychain) {
        self.baseURL = authBaseURL
        self.keychain = keychain
    }

    public func setAuth(_ authResposne: TokenResponse) throws {
        try self.keychain.set(authResposne.accessToken, key: "access_token")
        try self.keychain.set(authResposne.refreshToken, key: "refresh_token")
    }


    func fetchAccessToken(client: ClientCredentials) async throws -> String {
        if let token = self.accessToken, self.isAccessTokenExpired == false {
            return token
        }

        guard let refreshToken = self.refreshToken else {
            let error = NSError(domain: "co.brushedtype.musicthread", code: -2222, userInfo: [NSLocalizedDescriptionKey: "No refreshToken set"])
            throw error
        }

        if let activeRequest = self.fetchAccessTokenRequests {
            return try await activeRequest.value
        }

        let task = Task<String, Error> {
            self.fetchAccessTokenRequests = nil

            do {
                let response = try await client.refreshToken(refreshToken: refreshToken)
                try? self.setAuth(response)
                return response.accessToken
            } catch {
                try? self.keychain.remove("refresh_token")
                throw error
            }
        }

        self.fetchAccessTokenRequests = task

        return try await task.value
    }

}
