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

    private var fetchAccessTokenRequests: [FetchAccessTokenCompletion] = []


    public init(authBaseURL: URL, keychain: Keychain) {
        self.baseURL = authBaseURL
        self.keychain = keychain
    }

    public func setAuth(_ authResposne: TokenResponse) throws {
        try self.keychain.set(authResposne.accessToken, key: "access_token")
        try self.keychain.set(authResposne.refreshToken, key: "refresh_token")
    }


    func fetchAccessToken(client: ClientCredentials, completion: @escaping FetchAccessTokenCompletion) {
        if let token = self.accessToken, self.isAccessTokenExpired == false {
            return completion(.success(token))
        }

        DispatchQueue.main.async {
            guard let refreshToken = self.refreshToken else {
                let error = NSError(domain: "co.brushedtype.musicthread", code: -2222, userInfo: [NSLocalizedDescriptionKey: "No refreshToken set"])
                return completion(.failure(error))
            }

            guard self.fetchAccessTokenRequests.isEmpty else {
                self.fetchAccessTokenRequests.append(completion)
                return
            }

            self.fetchAccessTokenRequests.append(completion)

            client.refreshToken(refreshToken: refreshToken) { (result) in
                let res: Result<String, Error>

                switch result {
                case .failure(let err):
                    try? self.keychain.remove("refresh_token")

                    res = .failure(err)

                case .success(let response):
                    try? self.setAuth(response)

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
