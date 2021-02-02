//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Edward Wellbrook on 02/02/2021.
//

import Intents
import MusicThreadAPI
import KeychainAccess

extension API {

    static let shared: API = {
        let client = ClientCredentials(
            baseURL: URL(string: "https://musicthread.app")!,
            clientId: "1fa875b7a58ecdf4380c9ddd2b9ab6c1",
            redirectURI: "musicthread://auth"
        )

        let keychain = Keychain(service: "co.brushedtype.musicthread", accessGroup: "group.co.brushedtype.musicthread")

        return API(client: client, keychain: keychain)
    }()

}

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}

extension IntentHandler: ListThreadsIntentHandling {

    func handle(intent: ListThreadsIntent, completion: @escaping (ListThreadsIntentResponse) -> Void) {
        API.shared.fetchThreads { (result) in
            switch result {
            case .failure(_):
                completion(ListThreadsIntentResponse(code: .failure, userActivity: nil))
            case .success(let response):
                let intentResponse = ListThreadsIntentResponse(code: .success, userActivity: nil)
                intentResponse.threads = response.threads.map({ IntentsExtension.Thread(identifier: $0.key, display: $0.title) })

                completion(intentResponse)
            }
        }
    }

}

extension IntentHandler: AddLinkIntentHandling {

    func handle(intent: AddLinkIntent, completion: @escaping (AddLinkIntentResponse) -> Void) {
        guard let threadKey = intent.thread?.identifier else {
            return completion(AddLinkIntentResponse(code: .failure, userActivity: nil))
        }

        guard let linkURL = intent.url else {
            return completion(AddLinkIntentResponse(code: .failure, userActivity: nil))
        }

        API.shared.submitLink(threadKey: threadKey, linkURL: linkURL.absoluteString) { (result) in
            switch result {
            case .failure(_):
                completion(AddLinkIntentResponse(code: .failure, userActivity: nil))
            case .success(let response):
                let intentResponse = AddLinkIntentResponse(code: .success, userActivity: nil)
                intentResponse.link = IntentsExtension.Link(identifier: response.link.key, display: "\(response.link.title) — \(response.link.artist)")
                intentResponse.link?.pageURL = response.link.pageURL

                completion(intentResponse)
            }
        }
    }

}
