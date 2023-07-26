//
//  Artist.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import Foundation
 
struct Artist: Codable {
    let external_urls: ExternalUrls
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String
    let images: [APIImage]?
}
