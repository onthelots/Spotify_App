//
//  SettingModels.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/05.
//

import Foundation

// default form of the section
struct Section {
    let title: String
    let option: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
