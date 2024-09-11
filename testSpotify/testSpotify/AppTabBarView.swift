//
//  AppTabBarView.swift
//  testSpotify
//
//  Created by ICN on 10/09/2024.
//

import SwiftUI

struct AppTabBarView: View {
    
    @StateObject private var spotifyController = SpotifyController()
    
    @State private var albumImage : UIImage?
    var body: some View {
        VStack{
            
            connect
            
            trackInfo
            
            trackImage
            
            // show track progress length
            
            mediaController
            
            Text(spotifyController.appRemote.playerAPI?.description ?? "")
            
            
            
            
        }.onOpenURL { url in
            spotifyController.setAccessToken(from: url)
        }
        .environmentObject(spotifyController)
        
    }
    
    var connect : some View {
        Button {
            if !spotifyController.appRemote.isConnected {
                spotifyController.authorize()
                
                //spotifyController.connect()
                
                //spotifyController.appRemoteDidEstablishConnection(spotifyController.appRemote)
            }
        } label: {
            Text("Connect")
        }
        
    }
    
    var trackInfo : some View {
        VStack{
            Text(spotifyController.currentTrackURL ?? "Track URL")
            
            
            Text(spotifyController.currentTrackName ?? "Track Name")
            Text(spotifyController.currentTrackArtist ?? "Track Artist")
            Text("\(spotifyController.currentTrackDuration ?? 0)")
        }
        
    }
    
    var trackImage : some View {
        if let albumImage = spotifyController.currentTrackImage {
            Image(uiImage: albumImage)
                .resizable()
                .padding()
                .frame(width: 300, height: 300)
        } else {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .padding()
                .frame(width: 300, height: 300)
        }
    }
    
    var mediaController : some View {
        HStack{
            
            Button {
                spotifyController.appRemote.playerAPI?.skip(toPrevious: { result, error in
                    print("back!")
                })
            } label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .padding()
                    .frame(width: 100, height: 100)
            }
            
            
            
            Button {
                if let hehe = spotifyController.isPlaying {
                    if hehe {
                        spotifyController.appRemote.playerAPI?.resume()
                    } else {
                        spotifyController.appRemote.playerAPI?.pause()
                    }
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .padding()
                    .frame(width: 100, height: 100)
            }
            
            Button {
                spotifyController.appRemote.playerAPI?.skip(toNext: { result, error in
                    print("hehe")
                })
            } label: {
                Image(systemName: "arrow.forward.circle.fill")
                    .resizable()
                    .padding()
                    .frame(width: 100, height: 100)
            }
            
        }
    }
    
    var playButton : some View {

        Button {
            if let hehe = spotifyController.isPlaying {
                if hehe {
                    spotifyController.appRemote.playerAPI?.resume()
                } else {
                    spotifyController.appRemote.playerAPI?.pause()
                }
            }
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .padding()
                .frame(width: 100, height: 100)
        }
    }
    
}

#Preview {
    AppTabBarView()
}
