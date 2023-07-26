//
//  RecommendationsResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/11.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
