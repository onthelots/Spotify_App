//
//  NewReleasesCellViewModel.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/13.
//

import Foundation

struct NewReleasesCellViewModel {
    let name: String
    let artworkURL: URL? // 없을수도
    let numberOfTracks: Int
    let artistName: String
}
