//
//  SearchResult.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import Foundation

enum SearchResult {
    case album(model: Album)
    case artist(model: Artist)
    case playlist(model: Playlist)
    case track(model: AudioTrack)
}
