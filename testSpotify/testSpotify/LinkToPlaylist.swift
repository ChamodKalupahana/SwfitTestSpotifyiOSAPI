//
//  LinkToPlaylist.swift
//  testSpotify
//
//  Created by ICN on 11/09/2024.
//

import SwiftUI
import UIKit

struct LinkToPlaylist: View {
    @StateObject private var spotifyController = SpotifyController()
    
    @State var test : String?
    
    var body: some View {
        ScrollView{
            VStack{
                Text("playlists")
                
                ForEach(spotifyController.listOfPlaylistItems) { item in
                    PlaylistCard(item: item)
                    
                }
                
                Button {
                    spotifyController.getPlaylist()
                } label: {
                    Text("Fetch content")
                }
                
            }
        }.onOpenURL { url in
                spotifyController.setAccessToken(from: url)
        }.environmentObject(spotifyController)
            // need so that spotify doesn't create a new instance, doesn't need to be fed in from contentView
        }
    }

struct PlaylistCard : View {
    var item : PlaylistItem
    
    @State var albumImage : UIImage?
    
    var body: some View {
        ZStack{
            
            Color.black.opacity(0.7)
            
            HStack{
                
                if let albumImage {
                    Image(uiImage: albumImage)
                        .resizable()
                        .padding()
                        .frame(width: 200, height: 200)
                } else {
                    Image(systemName: "square.and.arrow.up.circle")
                        .resizable()
                        .padding()
                        .frame(width: 200, height: 200)
                }
                
                VStack{
                    // title
                    Text(item.title)
                    
                    // num of songs
                    Text("\(item.numOfSongs)")
                }
            }.foregroundStyle(Color.white)
            
        }.onAppear {
            loadImage(from: item.Image) { image in
                self.albumImage = image
            }
        }
    }
}



func loadImage (from urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL :\(urlString)")
        completion(nil)
        return
    }
    
    // Create a URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) {data, repsonse, error in
        if let error = error {
            print("Error fetching image: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data, let image = UIImage(data: data) else {
            print("Image not found")
            completion(nil)
            return
        }
        
        DispatchQueue.main.async {
            completion(image)
            //print("image found")
        }
    }
    
    task.resume()
}


#Preview {
    LinkToPlaylist()
}
