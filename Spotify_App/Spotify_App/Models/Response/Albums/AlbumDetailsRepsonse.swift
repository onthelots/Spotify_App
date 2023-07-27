//
//  AlbumDetailsRepsonse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import Foundation

struct AlbumDetailsResponse: Codable {
    let album_type: String
    let artists: [Artist]
    let external_urls: ExternalUrls
    let id: String
    let images: [APIImage]
    let label: String
    let name: String 
    let tracks: TracksResponse
}

struct TracksResponse: Codable {
    let items: [AudioTrack]
}
