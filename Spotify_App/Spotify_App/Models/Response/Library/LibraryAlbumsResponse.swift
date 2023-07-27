//
//  LibraryAlbumsResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/26.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
