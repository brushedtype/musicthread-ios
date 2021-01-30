//
//  ThreadList.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI

class ThreadListViewModel: ObservableObject {

    private var apiClient = API(baseURL: URL(string: "https://musicthread.app/api")!)

    @Published var threads: [Thread] = []

    func setAuth(tokenResponse: TokenResponse) {
        self.apiClient.setTokenStore(TokenStore(authBaseURL: "https://musicthread.app/oauth", tokenResponse: tokenResponse))

        self.apiClient.fetchThreads { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let threadResponse):
                    self.threads = threadResponse.threads
                }
            }
        }
    }

}

struct ThreadListView: View {

    @ObservedObject var viewModel: ThreadListViewModel


    var body: some View {
        NavigationView {
            List(self.viewModel.threads, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}
