# 🎧 Spotify (Custom)
> Spotify Web API를 활용한 나만의 음악 재생 앱

// 소개화면

<br> 

## 목차

[1. 프로젝트 소개](#-1.-프로젝트-소개)
> [1.1. 개요](###-1.1.-개요)
> [1.2. 주요목표](###-1.2.-주요-목표)
> [1.3. 활용기술](###-1.3.-활용-기술)
> [1.4. 구동방법](###-1.4.-구동-방법)

[2. Architecture]
> 2.1. 전체 구조
> 2.2. 파일 디렉토리


--- 

## 1. 프로젝트 소개
### 1.1. 개요
`Spotify Web API를 활용한 나만의 음악 재생 앱`
- **기획 및 개발** : 2023.06.10 ~ 2023.07.28 (약 6주)
- 세계 최대 음원 스트리밍 서비스인 Spotify를 **커스텀 UI 디자인**으로 구현
- <새로나온 앨범>, <맞춤형 플레이리스트 및 장르별 음악>, <아티스트 및 앨범 찾기>, <플레이리스트 만들기> 외 다양한 기능 제공

### 1.2. 주요 목표
- OAuth2.0의 동작 메커니즘(Resource Owner - Client - Authorization & Resource Server) 이해
- Spotify Web API에서 제공하는 문서를 바탕으로 RESTFul API 구현 
- Code-base UI AutoLayout 구현

### 1.3. 활용 기술
- 개발 환경
  - iOS : swift 5.8, xcode 14.3.1, UIKit
  - Layout : Code-base, AutoLayout(Constraints)
- 라이브러리
  - KingFisher (7.0.0)
 
### 1.4. 구동 방법
- 🗣️ 반드시 아래 절차에 따라 구동해주시길 바랍니다. 
- WKWeb, Spotify 전용 회원가입 및 개발자 설정이 필요합니다 (Google, Facebook, Apple 미 지원) 
- 구동이 잘 되지 않거나, 로그인 후 화면에 아무것도 보이지 않는다면 아래 메일로 문의 부탁드립니다. 

순서  | 내용  | 비고
----- | ----- | -----
1 | 스포티파이 계정을 생성 후, 로그인합니다(Google 외 기타 경로 가입 X) | [스포티파이 개발자용 링크](https://developer.spotify.com/)
2 | 오른쪽 상단에 있는 내 `아이디` 를 클릭한 후, Dashboard로 이동합니다 | 약관 동의 후, 이메일 인증을 실시
3 | 앱 생성 버튼을 누른 후, 앱 이름과 소개, RedirectURL을 작성한 후 저장합니다 | RedirectURL(임시 웹 페이지 주소)
4 | 앱이 생성되었다면, 오른쪽 상단에 `Settings` 버튼을 클릭합니다 | -
5 | Base Infromation 탭에서, `ClientID` 와 `Client secret` 코드를 복사합니다 | -
6 | 클론받은 프로젝트 파일 내 `ClientID+Secret.swift` 파일로 이동합니다 | ClientID 폴더 내 위치
7 | 비어있는 문자열에 순서대로 `ClientID`, `ClientSecret`, `RedirectURL` 을 기입합니다. | - 
8 | 빌드 후, 앱 로그인 시 앞서 생성한 스포티파이 계정으로 직접 로그인 합니다  | Google, Facebook, Apple 로그인 X 

<br>

## 2. Architecture
- MVC (+ MVVM)
// Data flow 및 Dependenccy 구상도
// Directory 구조

<br>

## 3. 프로젝트 특징
// 구동 화면별 소개


<br>

## 4. 프로젝트 세부과정

` [Feature 1] 어떤 앱을 만들 것인가? (+ UI Design) `
> 개발목표 및 주요기능
```
프로젝트를 통해 얻고자 하는 점. 해당 앱의 주요 기능
```

> 프로젝트 구조 및 화면구성
```
아키텍쳐 설정, 화면구성(프로토타입)
```

<br> 

`[Feature 2] 사용자 인증 및 로그인, 프로필 기능 구현`
> 2-1. User Authmetication (OAuth 2.0)
```
1. Spotify web API를 활용, 첫 Scene에서 SignIn 및 사용자 인증(Scope)을 통한 접근 구현 (인 앱 웹페이지를 보여주고자 WKWebView 활용)
3. UserDefaults를 활용하여 Token 저장 ➟ 처음 로그인 이후, 앱을 재 실행했을 때 재 로그인하지 않도록 함
```

> 2-2. Profile
```
1. API Parsing (APICaller 객체 생성)을 통한 SignIn을 완료한 User의 프로필 정보를 받아옴
2. AuthManager(사용자 인증관리)를 통해 생성한 Token(Access_Token, Refresh_Token)의 유효성 검사를 통해 올바른 토큰을 가지고 있을 경우 Request을 실시
4. 인증 만료 후, 새로운 Token이 생성될 시 기존의 Token과의 중복문제를 해소하기 위해 'onRefreshBlocks' 비어있는 클로저 배열을 생성하여 관리
```

<br> 

`[Feature 3] 탭(Tab)별 API 데이터 구축 및 UI 구성`
> 3-1. Browse Tab
```
1. 새로나온 앨범(NewRelese), 추천 재생목록(FeaturedPlaylist), 유사한 아티스트&트랙(Recommendations) API Parsing 수행
2. 각각의 Section별 디테일 뷰 구현 (ViewModel을 생성, ResuableCell를 활용한 UI 구현)
```

> 3-2. Search Tab
```
1. 검색바 추가 및 검색 기능 구현(UIsearchViewController)
2. 검색 결과(Query 입력 및 Search 완료 버튼)에 따른 UI 변화 (UIsearchResultsController)
```

> 3-3. Player Music
```
1. 개별 트랙(Track, single track) 혹은 재생목록(Playlists, tracks) Player UI 구현(Modality)
2. AVPlayer framework를 활용하여 [재생&일시정지] [이전 트랙] [다음 트랙] 기능 구현 (AVPlayer, AVQueuePlayer)
```

> 3-4. Player Music
```
1. UIScrollView 내 2개의 child ViewController를 할당, 로그인한 유저정보를 기반으로 나만의 Playlist 생성 및 삭제, Album 저장기능 구현 
```

<br> 

` [Feature 4] Haptic 기능 추가 및 UI 다듬기`

> ...
```
...
```

<br> 

### [TroubleShooting] 어떤 문제가 발생했고, 어떻게 대응했나?
` ... `
> ...
```
...
```


<br>

## 5. 자체 피드백 

### 긍정적인 부분
` ... `
> ...
```
...
```

### 보완해야 할 부분
` ... `
> ...
```
...
```

<br>

## 6. 활용기술

#### Platforms

<img src="https://img.shields.io/badge/iOS-5A29E4?style=flat&logo=iOS&logoColor=white"/>  
    
#### Language & Tools

// ...

## 1. 프로젝트 소개
🎧 Spotify : Spotify Web API를 활용한 음악검색, 플레이리스트 저장 외 앱 기능 전반 구현 (진행중)
// 구동화면, 진행기간, 활용기술

<br>

## 7. 개발환경

` ... `
> ...
```
...
```
