//
//  SceneDelegate.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 17/01/2021.
//

import UIKit
import AuthenticationServices
import SwiftUI
import MusicThreadAPI
import MusicThreadTokenStore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authSession: ASWebAuthenticationSession?


    private let client = ClientCredentials(
        baseURL: URL(string: "https://musicthread.app")!,
        clientId: "1fa875b7a58ecdf4380c9ddd2b9ab6c1",
        redirectURI: "musicthread://auth"
    )

    private let tokenStorage = KeychainTokenStorage(service: "co.brushedtype.musicthread", accessGroup: "group.co.brushedtype.musicthread")

    private lazy var viewModel = RootViewModel(client: self.client, tokenStorage: self.tokenStorage)


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window?.rootViewController = UIHostingController(rootView: RootView(viewModel: self.viewModel))
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        Task.detached(priority: .userInitiated) {
            if await self.viewModel.apiClient.isAuthenticated() == false {
                await self.startAuth()
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func startAuth() {
        guard self.authSession == nil else {
            return
        }

        let (authURL, state, codeVerfier) = self.client.generateAuthURL()
        DEBUG_debugPrint(authURL, state, codeVerfier)

        self.authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "musicthread") { (url, error) in
            func tearDownAuthSession(printingMessage message: Any...) {
                // setting `self.authSession = nil` marks the authentication process as completed
                self.authSession = nil
                DEBUG_debugPrint(message)
            }

            guard error == nil else {
                // we should show an error to the user, but this is a preview/demo app and I'm being lazy
                return tearDownAuthSession(printingMessage: error!)
            }

            guard let url = url else {
                return tearDownAuthSession(printingMessage: "missing url")
            }

            guard let (code, checkState) = self.parseResponseURL(url: url) else {
                return tearDownAuthSession(printingMessage: "invalid url")
            }

            guard state == checkState else {
                return tearDownAuthSession(printingMessage: "state mismatch", state, checkState)
            }

            self.client.exchangeToken(code: code, verifier: codeVerfier) { result in
                defer {
                    tearDownAuthSession(printingMessage: "authentication complete with result:", result)
                }

                switch result {
                case .failure(let error as DecodingError):
                    DEBUG_debugPrint("token response didn't match expected format", error)

                case .failure(let error):
                    DEBUG_debugPrint(error)

                case .success(let tokenResposne):
                    Task.detached(priority: .userInitiated) {
                        try await self.viewModel.setAuth(tokenResponse: tokenResposne)
                    }
                }
            }
        }

        self.authSession?.presentationContextProvider = self
        self.authSession?.start()
    }

    private func parseResponseURL(url: URL) -> (code: String, state: String)? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        if let err = components.queryItems?.first(where: { $0.name == "error" })?.value {
            DEBUG_debugPrint(err)
            return nil
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            DEBUG_debugPrint("missing auth code")
            return nil
        }

        guard let checkState = components.queryItems?.first(where: { $0.name == "state" })?.value else {
            DEBUG_debugPrint("missing state")
            return nil
        }

        return (code, checkState)
    }

}

extension SceneDelegate: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor(windowScene: self.window!.windowScene!)
    }

}

fileprivate func DEBUG_debugPrint(_ items: Any...) {
#if DEBUG
    debugPrint(items)
#endif
}
