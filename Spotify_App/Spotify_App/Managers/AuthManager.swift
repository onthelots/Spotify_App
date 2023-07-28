//
//  AuthManager.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        // MARK: - 🔒 User app information in Spotify dashboard (not changed)
        static let clientID: String = ClientID.youtClientID
        static let clientSecret: String = ClientID.yourClientSecret
        
        // Request Access Token URL
        static let tokenAPIURL: String = "https://accounts.spotify.com/api/token"
        static let redirectURI: String = "https://iosdevlime.tistory.com/"
        
        // Scope(사용자 인증 범위)
        static let scopes: String = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
 
    }
    
    // MARK: - signInURL
    public var signInURL: URL? {
        let base: String = "https://accounts.spotify.com/authorize"
        let string: String = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        
        return URL(string: string)
    }
    
    private init() {}
    
    // isSigned
    var isSignedIn: Bool {
        // accessToken이 nil이 아닐때 isSignedIn
        return accessToken != nil
    }
    
    // MARK: - UserDeafaults Data
    
    // accessToken
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    // refreshToken
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    // expirationDate
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expires_in") as? Date
    }
    
    // MARK: - Exchange Code for Token
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        // Add queryItem
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type",
                     value: "authorization_code"),
        URLQueryItem(name: "code",
                     value: code),
        URLQueryItem(name: "redirect_uri",
                     value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // request set Value (1)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8) // 데이터 타입으로 변환
        
        // Encoding data into base64String (Spotify Web API says to do)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        // request set Value (2)
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        // API Parsing & Decoding
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // to cache tokens
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error : \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    // MARK: - Token Refresh Process
    
    // Current Token Status
    private var refreshingToken: Bool = false
    
    // 새로고침 블럭
    var onRefreshBlocks = [((String) -> Void)]()
    
    // Determine if Token Expires
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        
        let currentDate: Date = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    
    // Refresh Token
    public func refreshTokenIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        // Change Token Status (true)
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type",
                     value: "refresh_token"),
        
        URLQueryItem(name: "refresh_token",
                     value: refreshToken)
        ]
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion?(false)
            return
        }
        
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            // Change Token Status (false)
            self?.refreshingToken = false
            
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                
                // append accessToken
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                
                self?.cacheToken(result: result)
                completion?(true)
            } catch {
                print("Error : \(error)")
                completion?(false)
            }
        }
        task.resume()
    }
    
    // MARK: - Supplies valid token to be used API Callers
    public func withValidToken(completion: @escaping (String) -> Void) {
            
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        
        // Token Expired
        if shouldRefreshToken {
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
    
    // MARK: - cahce Token
    private func cacheToken(result: AuthResponse) {
        
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token")
        }

        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expires_in")
    }
    
    // Remove cache values for logout
    public func signOut(completion: @escaping (Bool) -> Void){
        // UserDefaults (Local Cache)
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "expires_in")
        completion(true)
    }
}
