//
//  PlaylistDetailsResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let `public`: Bool
    let tracks: PlaylistTracksResponse
}

// 해당 Album 별 Playlist
struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

// 해당 AlbumPlaylist의 AudioTrack
struct PlaylistItem: Codable {
    let track: AudioTrack
}
