//
//  AllCategoriesResponse.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/19.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
