//
//  FeaturedPlaylistsResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/11.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlist]
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
