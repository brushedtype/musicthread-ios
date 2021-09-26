//
//  MainInterfaceController.swift
//  ShareExtension
//
//  Created by Edward Wellbrook on 01/02/2021.
//

import Foundation
import UIKit
import SwiftUI
import MusicThreadAPI
import KeychainAccess

class ExtensionContext {

    var context: (() -> NSExtensionContext?)?

}

class MainInterfaceController: UIHostingController<MainInterfaceView> {

    static let client = ClientCredentials(
        baseURL: URL(string: "https://musicthread.app")!,
        clientId: "1fa875b7a58ecdf4380c9ddd2b9ab6c1",
        redirectURI: "musicthread://auth"
    )

    static let keychain = Keychain(service: "co.brushedtype.musicthread", accessGroup: "group.co.brushedtype.musicthread")


    @objc init() {
        let api = API(client: MainInterfaceController.client, keychain: MainInterfaceController.keychain)
        let context = ExtensionContext()

        super.init(rootView: MainInterfaceView(apiClient: api, extension: context))

        context.context = {
            return self.extensionContext
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MusicThreadAPI.Thread: Hashable, Equatable {

    public static func == (lhs: MusicThreadAPI.Thread, rhs: MusicThreadAPI.Thread) -> Bool {
        return lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
        hasher.combine(self.title)
        hasher.combine(self.description)
        hasher.combine(self.tags)
    }

}

struct ThreadListView: View {

    let apiClient: API

    @State var shareURL: URL?
    @State var threads: [MusicThreadAPI.Thread] = []
    @State var isFetchingThreads: Bool = false

    @Binding var selectedThread: MusicThreadAPI.Thread?


    var body: some View {
        List {
            if self.isFetchingThreads {
                Text("Fetching threads...")
                    .foregroundColor(Color(.placeholderText))
            } else if self.threads.isEmpty {
                Text("Unable to fetch your threads.")
                    .foregroundColor(Color(.placeholderText))
            } else {
                Section(header: Text("Select a Thread")) {
                    ForEach(self.threads, id: \.key) { thread in
                        Button(action: {
                            self.selectedThread = thread
                        }) {
                            HStack(spacing: 10) {
                                Text(verbatim: thread.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Spacer()

                                if self.selectedThread?.key == thread.key {
                                    Image(systemName: "checkmark").foregroundColor(Color(.systemBlue))
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: {
            Task.detached(priority: .userInitiated) {
                await self.fetchThreads()
            }
        })
    }

    func fetchThreads() async {
        guard self.isFetchingThreads == false else {
            return
        }

        self.isFetchingThreads = true

        do {
            let response = try await self.apiClient.fetchThreads()
            self.threads = response.threads
        } catch {
            debugPrint(error)
        }

        self.isFetchingThreads = false
    }

}

struct MainInterfaceView: View {

    let apiClient: API
    let `extension`: ExtensionContext

    @State var isSubmittingLink = false
    @State var selectedThread: MusicThreadAPI.Thread?


    var body: some View {
        NavigationView {
            ThreadListView(apiClient: self.apiClient, selectedThread: self.$selectedThread)
                .navigationTitle("Add To Thread")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: self.navigationBarItems)
        }
    }

    var navigationBarItems: some View {
        HStack {
            if self.isSubmittingLink {
                ProgressView()
            } else {
                Button("Submit", action: self.submitURL)
                    .disabled(self.selectedThread == nil)
            }
        }
    }


    func submitURL() {
        guard let thread = self.selectedThread, let extensionContext = self.extension.context?() else {
            return
        }

        let items = extensionContext.inputItems.compactMap({ $0 as? NSExtensionItem })
        let urlProviders = items.flatMap({ $0.attachments ?? [] }).filter({ $0.hasItemConformingToTypeIdentifier("public.url") })

        guard let linkURLProvider = urlProviders.first else {
            return extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
        }

        self.isSubmittingLink = true

        Task.detached(priority: .userInitiated) {
            defer {
                self.isSubmittingLink = false
            }

            guard let url = try await linkURLProvider.loadItem(forTypeIdentifier: "public.url", options: nil) as? URL else {
                extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
                return
            }

            do {
                let _ = try await self.apiClient.submitLink(threadKey: thread.key, linkURL: url.absoluteString)
                extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
            } catch {
                debugPrint(error)
            }
        }
    }

}
