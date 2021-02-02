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

extension IntentsExtension.Thread {
    convenience init(thread: MusicThreadAPI.Thread) {
        self.init(identifier: thread.key, display: thread.title)
        self.title = thread.title
        self.threadDescription = thread.description
        self.tags = thread.tags
        self.pageURL = thread.pageURL
    }
}
extension IntentsExtension.Link {
    convenience init(link: MusicThreadAPI.Link) {
        self.init(identifier: link.key, display: "\(link.title) — \(link.artist)")
        self.title = link.title
        self.artist = link.artist
        self.pageURL = link.pageURL
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
                intentResponse.threads = response.threads.map(IntentsExtension.Thread.init(thread:))

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
                intentResponse.link = IntentsExtension.Link(link: response.link)

                completion(intentResponse)
            }
        }
    }

}

extension IntentHandler: CreateThreadIntentHandling {

    func handle(intent: CreateThreadIntent, completion: @escaping (CreateThreadIntentResponse) -> Void) {
        guard let title = intent.title else {
            return completion(CreateThreadIntentResponse(code: .failure, userActivity: nil))
        }

        API.shared.createThread(title: title, description: intent.threadDescription, tags: intent.tags ?? []) { (result) in
            switch result {
            case .failure(_):
                completion(CreateThreadIntentResponse(code: .failure, userActivity: nil))
            case .success(let response):
                let intentResponse = CreateThreadIntentResponse(code: .success, userActivity: nil)
                intentResponse.thread = IntentsExtension.Thread(thread: response.thread)

                completion(intentResponse)
            }
        }
    }

}
