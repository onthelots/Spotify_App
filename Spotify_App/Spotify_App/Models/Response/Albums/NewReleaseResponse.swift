//
//  NewReleaseResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/08.
//

import Foundation

struct NewReleaseResponse: Codable {
    let albums: Albums
}

struct Albums: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let artists: [Artist]
    let external_urls: ExternalUrls
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let type: String
    let uri: String
}

struct ExternalUrls: Codable {
    let spotify: String
}

