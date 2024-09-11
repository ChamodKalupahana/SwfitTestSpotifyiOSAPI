//
//  SpotifyController.swift
//  testSpotify
//
//  Created by ICN on 10/09/2024.
//

import Foundation
import UIKit

import SpotifyiOS
import SwiftUI
import Combine



@MainActor
final class SpotifyController : NSObject, ObservableObject {
    let spotifyClientID = "cc506604413c46178cee59b16f88700f"
    let spotifyRedirectURL = URL(string:"spotify-ios-quick-start://spotify-login-callback")! // return to app
    
    
    
    var accessToken : String? = nil
    
    @Published var currentTrackURL : String?
    @Published var currentTrackName : String?
    @Published var currentTrackArtist : String?
    @Published var currentTrackDuration : Int?
    @Published var currentTrackImage : UIImage?
    
    
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
            .sink { _ in
                self.disconnect()
            }
    }
    
    
    
    // lazy variables are only created by the system when asked to by the code, only load if needed
    lazy var appRemote : SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
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
                print("\(errorDesc)")
            }
        }
    }
    
    func authorize() {
        self.appRemote.authorizeAndPlayURI("")
    }
    
}



// This ensures that SpotifyController now conforms to the protocol and modifies the original class, this only adds func to the class
extension SpotifyController : SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to player state")
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("Player disconnected: \(error?.localizedDescription)")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("Player failed connection : \(error?.localizedDescription)")
    }
    
}

extension SpotifyController : SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        self.currentTrackURL = playerState.track.uri
        self.currentTrackName = playerState.track.name
        self.currentTrackArtist = playerState.track.artist.name
        self.currentTrackDuration = Int(playerState.track.duration / 1000) // spotfy api stores duration in miliseconds
        fetchImage()
    }
    
    func fetchImage() {
        appRemote.playerAPI?.getPlayerState({ (result, error) in
            
            guard let error else {
                print("Error getting player state: \(error?.localizedDescription)")
                return
            }
            
            if let playerState = result as? SPTAppRemotePlayerState {
                self.applyImageToClass(playerState: playerState, error: error)
                }
            })
        }

    
    func applyImageToClass(playerState : SPTAppRemotePlayerState, error : Error?) {
        let imageSize = CGSize(width: 300, height: 300)
        self.appRemote.imageAPI?.fetchImage(forItem: playerState.track, with: imageSize, callback: { (image, error) in
            
            
            guard let error else {
                print("Error fetching track image: \(error?.localizedDescription)")
                return
            }
            
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.currentTrackImage = image
                }
            }
        })
    }
}
