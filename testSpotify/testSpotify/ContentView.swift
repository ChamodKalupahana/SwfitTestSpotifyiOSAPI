//
//  ContentView.swift
//  testSpotify
//
//  Created by ICN on 10/09/2024.
//

import SwiftUI
import SpotifyiOS
import Combine

struct ContentView: View {
    var body: some View {
        TabView{
            AppTabBarView()                
                .tabItem {
                Image(systemName: "house.fill")
                Text("Current Song")
            }
            
            LinkToPlaylist()
                .tabItem {
                    Image("square.and.arrow.up.fill")
                    Text("Link to Playlist")
                }
        }
        
    }
}

#Preview {
    ContentView()
}
