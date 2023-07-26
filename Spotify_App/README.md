# Spotify

## 1. 앱 소개
🎧 Spotify : Spotify Web API를 활용한 음악검색, 플레이리스트 저장 외 앱 기능 전반 구현 (진행중)
// 구동화면, 진행기간, 활용기술

<br>

## 2. Architecture
- MVVM
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
2. UserDefaults를 활용하여 Token 저장 ➟ 처음 로그인 이후, 앱을 재 실행했을 때 재 로그인하지 않도록 함
```

> 2-2. Profile
```
1. API Parsing (APICaller 객체 생성)을 통한 SignIn을 완료한 User의 프로필 정보를 받아옴
2. AuthManager(사용자 인증관리)를 통해 생성한 Token(Access_Token, Refresh_Token)의 유효성 검사를 통해 올바른 토큰을 가지고 있을 경우 Request을 실시
3. 인증 만료 후, 새로운 Token이 생성될 시 기존의 Token과의 중복문제를 해소하기 위해 'onRefreshBlocks' 비어있는 클로저 배열을 생성하여 관리
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

<br>

## 7. 개발환경

` ... `
> ...
```
...
```

