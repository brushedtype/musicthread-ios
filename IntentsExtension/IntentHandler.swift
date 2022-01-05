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

    func handle(intent: ListThreadsIntent) async -> ListThreadsIntentResponse {
        do {
            let response = try await API.shared.fetchThreads()

            let intentResponse = ListThreadsIntentResponse(code: .success, userActivity: nil)
            intentResponse.threads = response.threads.map(IntentsExtension.Thread.init(thread:))

            return intentResponse

        } catch {
            return .init(code: .failure, userActivity: nil)
        }
    }

}

extension IntentHandler: AddLinkIntentHandling {

    func handle(intent: AddLinkIntent) async -> AddLinkIntentResponse {
        guard let threadKey = intent.thread?.identifier else {
            return .init(code: .failure, userActivity: nil)
        }

        guard let linkURL = intent.url else {
            return .init(code: .failure, userActivity: nil)
        }

        do {
            let response = try await API.shared.submitLink(threadKey: threadKey, linkURL: linkURL.absoluteString)

            let intentResponse = AddLinkIntentResponse(code: .success, userActivity: nil)
            intentResponse.link = IntentsExtension.Link(link: response.link)

            return intentResponse
        } catch {
            return .init(code: .failure, userActivity: nil)
        }
    }

}

extension IntentHandler: CreateThreadIntentHandling {

    func handle(intent: CreateThreadIntent) async -> CreateThreadIntentResponse {
        guard let title = intent.title else {
            return .init(code: .failure, userActivity: nil)
        }

        do {
            let response = try await API.shared.createThread(title: title, description: intent.threadDescription, tags: intent.tags ?? [], isPrivate: intent.isPrivate?.boolValue ?? false)

            let intentResponse = CreateThreadIntentResponse(code: .success, userActivity: nil)
            intentResponse.thread = IntentsExtension.Thread(thread: response.thread)

            return intentResponse

        } catch {
            return .init(code: .failure, userActivity: nil)
        }
    }

}
