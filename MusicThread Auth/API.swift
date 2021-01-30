//
//  API.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation

class API {

    let baseURL: URL

    private var tokenStore: TokenStore?


    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func setTokenStore(_ tokenStore: TokenStore) {
        if Foundation.Thread.isMainThread {
            self.tokenStore = tokenStore
        } else {
            DispatchQueue.main.sync {
                self.tokenStore = tokenStore
            }
        }
    }

    func fetchThreads(completion: @escaping (Result<ThreadResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/threads"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(ThreadResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }

}

struct Account: Decodable {
    let name: String
}

struct Thread: Decodable {

    let key: String
    let title: String
    let description: String
    let author: Account
    let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case author
        case pageURL = "page_url"
    }

}

struct ThreadResponse: Decodable {
    let threads: [Thread]
}
