//
//  SpotifyController.swift
//  testSpotify
//
//  Created by ICN on 10/09/2024.
//

import Foundation
import SpotifyiOS
import SwiftUI
import Combine


@MainActor
final class SpotifyController : NSObject, ObservableObject {
    let spotifyClientID = ""
    let spotifyRedirectURL = URL(string:"spotify-ios-quick-start://spotify-login-callback")! // return to app
    

    var accessToken : String? = nil
    
    private var connectCancellable: AnyCancellable? = nil
    private var disconnectCancellable: AnyCancellable? = nil
    
    override init() {
        super.init()
        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.connect()
            }
        
        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink {_ in
                self.disconnect()}
    }
    

    
    // lazy variables are only created by the system when asked to by the code, only load if needed
    lazy var appRemote : SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        //appRemote.delegate = self
        return appRemote
    }()

    func connect() {
        if let _ = self.appRemote.connectionParameters.accessToken {
            appRemote.connect()
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    

    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )
        

    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
            
        } else {
            if let errorDesc = parameters?[SPTAppRemoteErrorDescriptionKey] {
                print("oh no")
            }
        }
    }
    
    func authorize() {
        self.appRemote.authorizeAndPlayURI("")
    }
}
