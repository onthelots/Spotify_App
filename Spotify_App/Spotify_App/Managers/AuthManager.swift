//
//  AuthManager.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    // 새로고침 여부를 확인하기 위한 Flag 변수
    private var refreshingToken: Bool = false
    
    struct Constants {
        // 클라이언트 ID, SecretID
        static let clientID: String = {
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path),
                  let clientID = dict["clientID"] as? String else {
                fatalError("Info.plist에서 CLIENT_ID를 찾을 수 없습니다")
            }
            return clientID
        }()
        
        static let clientSecret: String = {
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path),
                  let clientSecret = dict["clientSecret"] as? String else {
                fatalError("Info.plist에서 CLIENT_SECRET을 찾을 수 없습니다.")
            }
            return clientSecret
        }()
        // Request Access Token을 위한 URL
        static let tokenAPIURL: String = "https://accounts.spotify.com/api/token"
        static let redirectURI: String = "https://iosdevlime.tistory.com/"
        // scope (사용자 인증 범위)
        static let scopes: String = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
 
    }
    
    private init() {}
    
    // signIn을 위한 URL
    public var signInURL: URL? {
        let base: String = "https://accounts.spotify.com/authorize"
        let string: String = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        
        return URL(string: string)
    }
    
    // App, SceneDelegate에서 보여줄 첫 화면(로그인 여부)
    var isSignedIn: Bool {
        // accessToken이 nil이 아닐때 isSignedIn
        return accessToken != nil
    }
    
    // accessToken (UserDefaults 데이터이며, access_token 명칭의 key를 가지고 있음
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    // refreshToken (UserDefaults 데이터이며, refresh_token 명칭의 key를 가지고 있음)
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    // expirationDate (UserDefaults 데이터이며, string값이 아닌 다른 타입이므로 object로 넘겨줌
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expires_in") as? Date
    }
    
    // 🖐🏻 토큰을 새로고침 -> SignIn 시점으로 부터 3600초가 지나면 자동으로 만료가 되니, 새로고침이 필요함 -> withValidToken에서 활용
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        
        // 따라서, 현재 날짜(시간)을 나타내는 CurrentData에
        let currentDate: Date = Date()
        
        // 5분(fiveMinutes)을 나타내는 TimeInterval을 할당하고 (300초, 5분)
        let fiveMinutes: TimeInterval = 300
        
        // 리턴값은 Boolean 타입이므로 현재 시간보다 5분이 지난 시점이 > 만료 시점보다 5분 더 지난 시간값을 가진다면 true로 반환함으로서 새로고침을 알림
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    // 1️⃣ MARK: - 받은 Code를 -> Access Token로 변환 + 원하는 작업을 요청함
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        // URLComponent(URL구조) -> queryItem을 추가
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type",
                     value: "authorization_code"),
        URLQueryItem(name: "code",
                     value: code),
        URLQueryItem(name: "redirect_uri",
                     value: Constants.redirectURI),
        ]
        
        // URLRequest(원하는 API 기능을 요청)
        var request = URLRequest(url: url)
        
        // [1] 무슨 요청을 할 것인가? -> POST(게시)
        request.httpMethod = "POST"
        
        // HTTP 헤더에 어떤것들이 추가되어야 하나? 1
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        // HTTP 헤더에 어떤것들이 추가되어야 하나? 2
        // Basic <base64 encoded client_id:client_secret>
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8) // 데이터 타입으로 변환
        
        // 공식 가이드에 따르면, 위 data를 'base64String' 형식으로 Encoding 하는 것을 지시함
        // 아래와 같이 Binding을 실시한 후,
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        // request value에 아래 형식에 맞춰 전달
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        // [2] URLSession(퍼블리셔) 객체 생성
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            // data가 존재하고, error가 nil이 아닐 경우엔 completion을 false로 할당
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            // 데이터 파싱
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // ✅ Cache? : 파싱된 Data(AuthResponse)중, Token을 지속적으로 서버에 요청하지 않아도 로그인을 지속하기 위해 Cache Token 메서드를 활용함
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error : \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    // 🖐🏻 refresh 관련 클로저 - ((String) -> Void)- 가 저장되는 배열타입
    // 이걸 왜하는데? -> 새로고침이 중복되는것을 방지하기 위해, 관련 배열을 저장해둠
    var onRefreshBlocks = [((String) -> Void)]()
    
    /// Supplies valid token to be used API Callers -> SignIn 이후, API 데이터를 가져오기에 앞서 유효한 Token인지 여부를 확인하는 메서드로 활용됨
    // 🖐🏻 유효한 토큰인지, 아닌지 확인하는 메서드
    public func withValidToken(completion: @escaping (String) -> Void) {
            
        // RefreshingToken이 false 일때
        guard !refreshingToken else {
            // 그렇지 않다면, Completion을 배열에 포함시킴
            onRefreshBlocks.append(completion)
            print(onRefreshBlocks)
            return
        }
        
        // 토큰이 만료가 된 경우
        if shouldRefreshToken {
            // 토큰을 새로 고침함
            refreshTokenIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    // 2️⃣ MARK: - 토큰을 새로고침 해야 할 경우 (즉, shouldRefreshToken이 True일 경우) -> 새로운 Token값을 할당받는 메서드
    // 🖐🏻 토큰을 새로고침을 하는 방식 -> User가 SignIn을 한 이후, 시간이 경과되어 새로고침이 필요할 경우
    // 🚫 그런데, 만료가 되었단 것을 어떻게 알려야 하나? -> 사전에 미리 withValidToken 메서드를 통해 유효한 토큰(만료되지 않은 토큰)인지 확인할 필요가 있음
    public func refreshTokenIfNeeded(completion: ((Bool) -> Void)?) {
        // 🖐🏻 기존에 설정한 RefreshingToken의 값이 false인지 확인하고
        guard !refreshingToken else {
            return
        }
        
        // 만료 시간 이후 5분이 더 경과되었을 때 (true / shouldRefreshToken) -> 아래 새로고침 메서드를 실시함
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // ⏩️ 토큰을 새로고침 함
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        // 🖐🏻 토큰의 유효성+ 새로고침 여부를 확인하기 위하여 flag 변수를 true로 변환
        refreshingToken = true
        
        // URLComponent(URL구조) -> queryItem을 추가
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type",
                     value: "refresh_token"),
        
        // refresh Token값을 할당함
        URLQueryItem(name: "refresh_token",
                     value: refreshToken)
        ]
        
        // URLRequest(원하는 API 기능을 요청)
        var request = URLRequest(url: url)
        
        // 무슨 요청을 할 것인가? -> POST(게시)
        request.httpMethod = "POST"
        
        // HTTP 헤더에 어떤것들이 추가되어야 하나? 1
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        // HTTP 헤더에 어떤것들이 추가되어야 하나? 2
        // Basic <base64 encoded client_id:client_secret>
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8) // 데이터 타입으로 변환
        
        // 공식 가이드에 따르면, 위 data를 'base64String' 형식으로 Encoding 하는 것을 지시함
        // 아래와 같이 Binding을 실시한 후,
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion?(false)
            return
        }
        
        // request value에 아래 형식에 맞춰 전달
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        // URLSession(퍼블리셔) 객체 생성
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            // refreshingToken flag 변수를 다시 돌려놓음
            self?.refreshingToken = false
            
            // data가 존재하고, error가 nil이 아닐 경우엔 completion을 false로 할당
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                // 🖐🏻AccessToken의 배열에 인자값($0)으로 result.access_token을 할당함
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                print("Successfully Refreshed")

                // 🖐🏻 토큰이 할당된 이후, onRefreshBlocks에 있는 배열값을 모두 삭제함 (왜? 중복될 수 있으니까)
                // 결과적으로, onRefreshBlocks 배열에는 최신 토큰만 할당되었다가, 사라짐
                self?.onRefreshBlocks.removeAll()

                // ✅ Cache? : 파싱된 Data(AuthResponse)중, Token을 지속적으로 서버에 요청하지 않아도 로그인을 지속하기 위해 Cache Token 메서드를 활용함
                self?.cacheToken(result: result)
                completion?(true)
            } catch {
                print("Error : \(error)")
                completion?(false)
            }
        }
        task.resume()
    }
    
    // 캐싱 데이터(받아온 token, refresh token, expires time을 UserDefault에 저장)
    private func cacheToken(result: AuthResponse) {
        
        // ✅ UserDefaults (Local Cache)
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        
        // ⏩️ Refresh_Token (Local Cache) -> 새로고침된 토큰일 경우에만 UserDefaults로 할당할 수 있도록 함
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token")
        }

        // expire(Token이 만료되는)의 경우, 기본값이 3600초이므로 -> 로그인한 시간으로 부터 계산하기 위해 TimeInterval을 활용함
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expires_in")
    }
    
    // SignOut (캐시함수를 전체 삭제해버림)
    public func signOut(completion: @escaping (Bool) -> Void){
        // UserDefaults (Local Cache)
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        
        // Refresh_Token (Local Cache)
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        
        UserDefaults.standard.setValue(nil,
                                       forKey: "expires_in")
        
        completion(true)
    }
}
