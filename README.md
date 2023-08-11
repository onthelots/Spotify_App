# 🎧 Spotify (Custom)
> Spotify Web API를 활용한 나만의 음악 재생 앱

![Group 1](https://github.com/onthelots/Spotify_App/assets/107039500/f551ba61-7d9d-4add-9908-6ca8d7ef97fc)

<br> 

# 목차

[1-프로젝트 소개](#1-프로젝트-소개)

- [1-1 개요](#1-1-개요)
- [1-2 주요목표](#1-2-주요목표)
- [1-3 개발환경](#1-3-개발환경)
- [1-4 구동방법](#1-4-구동방법)

[2-Architecture](#2-architecture)
- [2-1 구조도](#2-1-구조도)
- [2-2 파일 디렉토리](#2-2-파일-디렉토리)

[3-프로젝트 특징](#3-프로젝트-특징)

[4-프로젝트 세부과정](#4-프로젝트-세부과정)

[5-업데이트 및 리팩토링 사항](#5-업데이트-및-리팩토링-사항)


--- 

## 1-프로젝트 소개

### 1-1 개요
> Spotify Web API를 활용한 나만의 음악 재생 앱
- **기획 및 개발** : 2023.06.10 ~ 2023.07.28 (약 6주)
- 세계 최대 음원 스트리밍 서비스인 Spotify를 `커스텀 UI 디자인`으로 구현
- `새로나온 앨범`, `플레이리스트 및 장르별 음악`, `아티스트 및 앨범 찾기`, `플레이리스트 생성` 외 다양한 기능 제공

### 1-2 주요목표
- OAuth2.0의 동작 메커니즘(Resource Owner - Client - Authorization & Resource Server) 이해
- Spotify Web API에서 제공하는 문서를 바탕으로 RESTFul API 구현 
- Code-base UI AutoLayout 구현

### 1-3 개발환경
- 활용기술 외 키워드
  - **iOS** : swift 5.8, xcode 14.3.1, UIKit
  - **Network**: URLSession, OAuth(RESTful API)
  - **UI** : ScrollView, TableView, CollectionView, TabBar, StackView
  - **Layout** : AutoLayout(Code-base), Compositional Layout
- 라이브러리
  - KingFisher (7.0.0)
 
### 1-4 구동방법
- 🗣️ 반드시 아래 절차에 따라 구동해주시길 바랍니다. 
- `Spotify 전용 회원가입` 및 `개발자 설정`이 필요합니다 (Google, Facebook, Apple 미 지원) 
- 구동이 잘 되지 않거나, 로그인 후 화면에 아무것도 보이지 않는다면 아래 메일로 문의 부탁드립니다
- onthelots@naver.com

순서  | 내용  | 비고
----| ----- | -----
1 | 스포티파이 계정을 생성 후, 로그인합니다(Google 외 기타 경로 가입 X) | [스포티파이 개발자 링크](https://developer.spotify.com/)
2 | 오른쪽 상단에 있는 내 `아이디` 를 클릭한 후, Dashboard로 이동합니다 | 약관 동의 후, 이메일 인증을 실시
3 | 앱 생성 버튼을 누른 후, 앱 이름과 소개, RedirectURL을 작성한 후 저장합니다 | RedirectURL(임시 웹 페이지 주소)
4 | 앱이 생성되었다면, 오른쪽 상단에 `Settings` 버튼을 클릭합니다 | -
5 | Base Infromation 탭에서, `ClientID` 와 `Client secret` 코드를 복사합니다 | -
6 | 클론받은 프로젝트 파일 내 `ClientID+Secret.swift` 파일로 이동합니다 | ClientID 폴더 내 위치
7 | 비어있는 문자열에 순서대로 `ClientID`, `ClientSecret`, `RedirectURL` 을 기입합니다. | - 
8 | 빌드 후, 앞서 생성한 스포티파이 계정으로 직접 로그인 합니다  | Google, Facebook, Apple 로그인 X 

<br>

## 2-Architecture
### 2-1 구조도

<img width="2299" alt="Proeject Architecture" src="https://github.com/onthelots/Spotify_App/assets/107039500/1c192a15-8ad6-4974-b0fb-260821cd8601">

<br>

> MVC Architecture
- 음악 앱의 특성상, Track 리스트, 재생 플레이어 등 유사한 View를 지속적으로 재 사용하므로, `MVC 패턴` 활용 
- AuthManager 객체에서 API Fetching 메서드 구현 로직을 담당, ViewController에서 직접 호출
- OAuth2.0 인증을 위해 코드 및 토큰발행을 위한 AuthManager 객체를 생성하고, UserDefault 값으로 저장

<br>

> Presenter 활용
- Music Player의 경우, `2가지 경우`의 수(하나의 트랙 혹은 전체 트랙)를 가지고 있음
- 하나의 VC에서 역할이 다소 과중된다 판단, `Presenter`를 통해 View 및 Model의 상태를 확인, 업데이트 로직을 구현

<br>

### 2-2 파일 디렉토리
```
Spotify_App
 ┣ 📂App
 ┣ 📂ClientID
 ┣ 📂Controllers
 ┃ ┣ 📂Core
 ┃ ┃ ┣ 📜HomeViewController.swift
 ┃ ┃ ┣ 📜LibraryViewController.swift
 ┃ ┃ ┣ 📜SearchViewController.swift
 ┃ ┃ ┗ 📜TabBarViewController.swift
 ┃ ┗ 📂Others
 ┣ 📂Managers
 ┃ ┣ 📜APICaller.swift
 ┃ ┣ 📜AuthManager.swift
 ┃ ┗ 📜HapticManager.swift
 ┣ 📂Models
 ┃ ┣ 📂Auth
 ┃ ┣ 📂Common
 ┃ ┣ 📂Response
 ┃ ┗ 📂User
 ┣ 📂View
 ┃ ┣ 📂HomeTab
 ┃ ┣ 📂LibraryTab
 ┃ ┣ 📂Player
 ┃ ┃ ┣ 📂PlayBackPresenter
 ┃ ┃ ┃ ┗ 📜PlayBackPresenter.swift
 ┃ ┗ 📂SearchTab
```

<br>

## 3-프로젝트 특징
### 3-1 새로나온 앨범, 인기있는 플레이리스트, 취향에 맞는 음악 제공 (HomeTab)
- Spotify Web API 데이터 파싱에 따라, 실시간으로 음악정보를 확인함  
- 단일 앨범을 비롯, 주제에 따라 다양한 트랙이 혼합된 플레이리스트 제공
    
|![HomeTab1](https://github.com/onthelots/Spotify_App/assets/107039500/b44de0c6-cdc9-40eb-8e2c-028841a9bc34)|![HomeTab_to_Playlists](https://github.com/onthelots/Spotify_App/assets/107039500/28cfc7e7-972a-40b4-a2c1-64c04d3960c7)|![HomeTab_to_Album](https://github.com/onthelots/Spotify_App/assets/107039500/7c8bca91-b02a-4bbe-b145-482a7ff8e7f5)|
|:-:|:-:|:-:|
|`Home`|`Album`|`Playlist`|

<br>

---

### 3-2 키워드를 통해 음악, 아티스트, 앨범 검색(SearchTab)
- Search API 파싱 데이터를 SearchResults 모델 객체로 변환하여 음악, 아티스트, 앨범 검색결과를 섹션별로 나타냄 
- 주제(카테고리)에 따라 동일한 속성값(category.id)을 가지고 있는 플레이리스트를 제공

|![SearchTab](https://github.com/onthelots/Spotify_App/assets/107039500/b2c3cc1c-8bad-4ed4-81bb-a962ad68b965)|![Search](https://github.com/onthelots/Spotify_App/assets/107039500/75a66d5b-5a4a-4bf5-913b-2707b8a8a08f)|![Search_Category_Playlists](https://github.com/onthelots/Spotify_App/assets/107039500/73cb4147-4507-4683-b728-98d5db656b24)|
|:-:|:-:|:-:|
|`Search`|`Keyword`|`Category Playlists`|

<br>

---

### 3-3 마음에 드는 플레이리스트 혹은 앨범을 저장&관리(LibraryTab)
- 로그인 유저가 직접 플레이리스트의 명칭과 포함될 트랙을 추가할 수 있음
- Long Tap Gesture를 활용하여 플레이리스트 내 트랙 추가 (현재는 HomeTab 하단 추천 트랙만 추가 가능)
- 마음에 드는 앨범이 있을 경우, 앨범 페이지 우측 상단에 (+) 버튼을 눌러 즐겨찾는 앨범 추가

|![LibraryTab_Playlists_Add](https://github.com/onthelots/Spotify_App/assets/107039500/9dced62c-ee34-4aff-85b8-8f9efb19a020)|![MyPlaylists](https://github.com/onthelots/Spotify_App/assets/107039500/e3941276-bffd-41ed-b011-edb9fc6629f1)|![LibraryTabAlbums](https://github.com/onthelots/Spotify_App/assets/107039500/70018886-ef92-42a5-8e55-11a6b8ba0c7a)|
|:-:|:-:|:-:|
|`Create Playlist`|`Playlists tracks`|`Favorite Album`|

<br>

---

### 3-4 단일 트랙 혹은 플레이리스트(앨범) 별 음악 재생 (Player)
- AVPlayer Framework를 활용하여 트랙 및 플레이리스트(앨범) 전체 재생 가능 
  - 🖐🏻 시뮬레이터로 구동시, delay가 발생하며, 실제 디바이스에서는 테스트 완료)
  - 시작/정지(PlayPause), 다음 트랙(Forward), 이전 트랙(Backward) 기능 구현
 
|![image 93](https://github.com/onthelots/Spotify_App/assets/107039500/2a434d21-b98a-4c3b-bd67-1a9590c0ef92)|![Group 2047](https://github.com/onthelots/Spotify_App/assets/107039500/6bf72afc-f11f-4e94-9121-b0b0f969e51f)|![Group 2047](https://github.com/onthelots/Spotify_App/assets/107039500/b56433d3-9c65-40d9-89eb-b91eb4c2ff5b)|
|:-:|:-:|:-:|
|`Audio Player`|`Play All Button`|`Volume Slider`|

<br>

## 4-프로젝트 세부과정
### 4-1 [Feature 1] 어떤 앱을 만들 것인가? (+ UI Design)

> UIKit 개발 프레임워크를 활용, OPEN API 네트워크 구현, 구상화 목표
 - 스토리보드를 사용하지 않고 AutoLayout을 구현하는 `Code-base`를 활용
 - 단순하면서, 기초적으로 앱 구조를 구축하고자 `MVC 패턴` 적용
 - 현재 상용화 된 앱의 전반적인 모습을 따라가되, 1차적으로 UI 측면보다는 `기능 중심`의 구현 목표

<br> 

### 4-2 [Feature 2] 사용자 인증 및 로그인, 프로필 기능 구현

> OAuth 2.0 로그인 과정에 대한 학습을 기반으로 User Authmetication 구현
  - Spotify Web API 가이드에 따라 로그인 요청 ➟ 페이지 제공 ➟ Auth Code 발급 및 Token 교환 ➟ DB 저장 ➟ API 호출(Finish!)
  - UserDefaults를 활용하여 Token 저장 ➟ 처음 로그인 이후, 앱을 재 실행했을 때 재 로그인하지 않도록 함
  - **TroubleShooting** : [401 repsponse Error 발생 및 해결과정](https://github.com/users/onthelots/projects/5?pane=issue&itemId=32561891)

<br> 

### 4-3 [Feature 3] 탭(Tab)별 API 데이터 구축 및 UI 구성

> HomeTab(새로나온 앨범, 추천 재생목록, 유사한 아티스트&트랙)
- 각각의 Section별 구분을 목표로, 해당 View에서 활용되는 ViewModel을 Associated Values으로 설정하는 BrowseSectionType을 생성

```swift
enum BrowseSectionType {
    case newRelease(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistsCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
   ...
```

- 수직 스크롤 화면 내, 수평 스크롤로 구성된 새로나온 앨범, 추천 재생목록을 구현하기 위해 `Compositional Layout`을 사용

<br>

> Search Tab(아티스트, 앨범 외 검색기능, 테마별 플레이리스트)
- 검색 결과(Query 입력 및 Search 완료 버튼) 입력값에 따라, UI를 4개의 섹션으로 구분(SearchResult)하여 업데이트
```swift
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        resultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    resultsController.update(with: result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
```

<br>

> Player Music(음악 재생)
- `AVPlayer` framework를 활용하여 재생&일시정지, 이전 트랙, 다음 트랙 기능 구현 (AVPlayer, AVQueuePlayer)
- PlayerController의 과도한 역할부담을 줄이기 위해, `Presenter`를 생성, 활용
- Track(Cell), Album&Playlists(Play All Button) 선택에 따라 기능 분기처리 실시

```swift 
   var player: AVPlayer? // single Track
   var playerQueue: AVQueuePlayer? // playlist or album Player
  
  // 현재 재생되고 있는 트랙의 성격(혹은 선택된 아이템)에 따라 track(single) 혹은 tracks(album, playlists)를 반환
   var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
   ...

```

<br>

> Library Tab (유저정보를 기반으로 나만의 Playlist 생성 및 삭제, Album 저장기능)
- Child ViewController(Playlists, Albums)내 포함된 데이터 여부를 확인(GET), 'ActionLabelView(데이터가 없음)'를 토글함
- Playlists : 데이터가 없을 경우 생성(POST) 메서드를 통해 만들고, 'UILongPressGestureRecognizer'를 활용해 저장(POST), 삭제(DELETE)함
- Album : 기존 서버 데이터상에 존재하므로, 저장(PUT)을 실시함

```swift 
    private func addChildren() {
        addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height) // frame을 통한 paging
        playlistVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height) // frame을 통한 paging
        albumsVC.didMove(toParent: self)
    }
```

<br>

## 5-업데이트 및 리팩토링 사항
### 5-1 우선 순위별 개선항목

1) API Caller 메서드 로직 수정
- [ ] Library 내 저장되는 Playlists와 Albums의 경우, 동일한 데이터를 중복적으로 저장할 수 있는 이슈 해결필요

2) SNS 및 Google 로그인 기능 구현
- [ ] 개별 SDK 적용 및 기존 인웹(WKWeb)을 SFSafariview로 대체하는 대안 비교 및 적용

3) Player 기능
- [ ] Playlists나 Albums을 전체 재생할 때, 되감기 혹은 반복기능 추가 (AudioTrack 데이터 구조 내 재생시간 관련 객체 확인)
- [ ] Volume을 담당하는 UISilder 기능 제거, 재생 시간에 따른 UISlider 업데이트 방식으로 리팩토링 필요

4) 일부 Track의 미리보기 재생(Preview_urls)값이 있음에도 불구하고, 재생이 되지 않는 문제
- [ ] Tracks의 미리보기 재생이 없는 경우 분기처리를 통하여 UI 업데이트를 하지 않도록 제한

### 5-2 그 외 항목

1) UI 개선
- [ ] frame-base layout을 AutoLayout으로 전부 대체하기
- [ ] Color Palette를 활용하여 보다 통일감 있는 디자인 구성하기

2) Architecture 재 검토
- [ ] ViewController 및 API Caller 내 과도한 역할집중으로 인한 부차적인 문제 우려, MVVM 패턴으로의 리팩토링 고려

<br>
