//
//  SearchResultResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumsResponse
    let artists: SearchArtistResponse
    let playlists: SearchPlaylistsResponse
    let tracks: SearchTracksResponse
}

struct SearchAlbumsResponse: Codable {
    let items: [Album]
}

struct SearchArtistResponse: Codable {
    let items: [Artist]
}

struct SearchPlaylistsResponse: Codable {
    let items: [Playlist]
}

struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}
