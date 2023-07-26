//
//  SettingModels.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/05.
//

import Foundation

// MARK: - Section의 기본적인 형태를 나타내기 위한 세팅 (Model)
struct Section {
    let title: String
    let option: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
