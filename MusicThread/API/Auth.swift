//
//  Auth.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 25/01/2021.
//

import Foundation
import CryptoKit
import Security

fileprivate func randomBytes(length: Int) -> Data {
    var data = Data(count: length)
    _ = data.withUnsafeMutableBytes {
      SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
    }
    return data
}

fileprivate func generateCodeVerifier() -> String {
    return randomBytes(length: 32).urlBase64Encode()
}

fileprivate func generateCodeChallenge(codeVerifier: String) -> String {
    var sha256 = CryptoKit.SHA256()
    sha256.update(data: codeVerifier.data(using: .utf8)!)

    let hash = sha256.finalize()
    return Data(hash).urlBase64Encode()
}

extension Data {
    func urlBase64Encode() -> String {
        return self
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

extension JSONDecoder {

    func decodeResult<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, Error> {
        return Result {
            return try self.decode(type, from: data)
        }
    }

}

struct TokenResponse: Decodable {
    let accessToken: String
    let expiryInterval: TimeInterval
    let refreshToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiryInterval = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

struct ClientCredentials {
    let baseURL: URL
    let clientId: String
    let redirectURI: String
}

extension ClientCredentials {

    func generateAuthURL() -> (url: URL, state: String, codeVerfier: String) {
        let codeVerfier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(codeVerifier: codeVerfier)

        let state = UUID().uuidString

        var components = URLComponents(url: self.baseURL.appendingPathComponent("/oauth/authorize"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "client_id", value: self.clientId),
            URLQueryItem(name: "redirect_uri", value: self.redirectURI),
            URLQueryItem(name: "state", value: state),
        ]

        return (components.url!, state, codeVerfier)
    }

    func exchangeToken(code: String, verifier: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: self.clientId),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: verifier),
            URLQueryItem(name: "redirect_uri", value: self.redirectURI),
        ]

        var req = URLRequest(url: self.baseURL.appendingPathComponent("/oauth/token"))
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let data = data else {
                return debugPrint(error ?? "empty response")
            }

            let jsonDecoder = JSONDecoder()
            let result = jsonDecoder.decodeResult(TokenResponse.self, from: data)

            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func refreshToken(refreshToken: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: self.clientId),
        ]

        var req = URLRequest(url: self.baseURL.appendingPathComponent("/oauth/token"))
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
                completion(result)
            }
        }.resume()
    }

}
