//
//  TokenStore.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation

class TokenStore {

    private let baseURL: String
    private var refreshToken: String
    private var accessToken: String?

    init(authBaseURL: String, tokenResponse: TokenResponse) {
        self.baseURL = authBaseURL
        self.refreshToken = tokenResponse.refreshToken
        self.accessToken = tokenResponse.accessToken
    }

    func fetchAccessToken( completion: @escaping (Result<String, Error>) -> Void) {
        if let token = self.accessToken {
            return completion(.success(token))
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: self.refreshToken),
        ]

        var req = URLRequest(url: URL(string: self.baseURL + "/token")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let data = data else {
                let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -9933, userInfo: [NSLocalizedDescriptionKey: "Invalid refresh token response"])
                return completion(.failure(err))
            }

            let jsonDecoder = JSONDecoder()
            let result = jsonDecoder.decodeResult(TokenResponse.self, from: data)

            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    return completion(.failure(err))
                case .success(let response):
                    self.refreshToken = response.refreshToken
                    self.accessToken = response.accessToken
                    return completion(.success(response.accessToken))
                }
            }
        }.resume()
    }

}
