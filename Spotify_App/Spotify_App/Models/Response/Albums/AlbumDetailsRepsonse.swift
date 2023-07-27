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
    let label: String // 제작사 이름
    let name: String // 제목
    let tracks: TracksResponse
}

struct TracksResponse: Codable {
    let items: [AudioTrack]
}
