//
//  AppTabBarView.swift
//  testSpotify
//
//  Created by ICN on 10/09/2024.
//

import SwiftUI

struct AppTabBarView: View {
    
    @StateObject private var spotifyController = SpotifyController()
    var body: some View {
        VStack{
            
            Button {
                if !spotifyController.appRemote.isConnected {
                    spotifyController.authorize()                
                    
                    //spotifyController.connect()
                    
                    //spotifyController.appRemoteDidEstablishConnection(spotifyController.appRemote)
                }
            } label: {
                Text("Connect")
            }
            
            Text(spotifyController.currentTrackName ?? "Track Name")
            
            
            
            
        }.onOpenURL { url in
            spotifyController.setAccessToken(from: url)
        }
        .environmentObject(spotifyController)
        
    }
}

#Preview {
    AppTabBarView()
}
