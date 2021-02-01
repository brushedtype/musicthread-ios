//
//  ClientCredentials.swift
//  MusicThreadAPI
//
//  Created by Edward Wellbrook on 01/02/2021.
//

import Foundation

public struct ClientCredentials {
    public let baseURL: URL
    public let clientId: String
    public let redirectURI: String

    public init(baseURL: URL, clientId: String, redirectURI: String) {
        self.baseURL = baseURL
        self.clientId = clientId
        self.redirectURI = redirectURI
    }
}
