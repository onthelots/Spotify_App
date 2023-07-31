//
//  ClientID+Secret.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/28.
//

import Foundation

struct ClientID {
    /// 🔒 앱 구동을 위한 준비(How to get ClientID & ClientSecret Code)
    /// 1. 스포티파이 개발자 대시보드로 이동해주세요(Go to your Spotify for Developers Dashboard)
    /// 2. 앱 등록을 진행해주세요(Click Your Create App)  ( If you do not log in or create an app, please refer to README(https://github.com/onthelots/Spotify_App) )
    /// 3. Basic Information 탭을 클릭합니다(On the Basic Information tab)
    /// 4. CliendID, ClientSecret, Redirect_url을 복사한 후, 아래 문자열에 입력해주세요 (Copy the [Client ID] and [Client Secret], [Redirect_url] code and write it in the string below (youtClientID, yourClientSecret, yourRedirectURL))
    /// 5. 시뮬레이션을 빌듣한 후, 본인의 스포티파이 아이디로 로그인해주세요(After the simulation build, log in with an account subscribed to 'Spotify Development' (☑️ Must be the same account))

    static let youtClientID: String = ""
    static let yourClientSecret: String = ""
    static let yourRedirectURL: String = ""
}
