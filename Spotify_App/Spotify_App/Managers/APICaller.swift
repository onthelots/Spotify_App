//
//  APICaller.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    // base API URL
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    // custom Error
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK: - Commom API Call (Albums, Playlists)
    
    // albums
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
                      type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let decorder = JSONDecoder()
                    let result = try decorder.decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // playlists
    public func getPlaylistsDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id),
                      type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decorder = JSONDecoder()
                    let result = try decorder.decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - User Profile APl Call
    
    // userProfile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET) { baseRequest in
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decorder = JSONDecoder()
                    let result = try decorder.decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - HomeTab API Call (New Release Album, Featured Playlists, Recommendations)
    
    // new Release Album
    public func getNewRelease(completion: @escaping (Result<NewReleaseResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"),
                      type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NewReleaseResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // featured Playlists
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=50"),
                      type: .GET) { request in

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // recommandation Tracks
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        
        // Separate genre data with commas(,), save in 'set' format
        let seeds = genres.joined(separator: ",")
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=10&seed_genres=\(seeds)"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // genre Seeds(Imported genre data will be converted into recommended genres)
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - SearchTab API Call
    
    // category(All or Several)
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // category (Selected Category)
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=20"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(FeaturedPlaylistsResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // Search Logic
    public func search(with query: String, completion: @escaping (Result<[SearchResult],Error>) -> Void) {
        // addingPercentEncoding (When encoding, convert characters (한글, 공백) that are not in the set into % and encode them)
        createRequest(with: URL(string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SearchResultResponse.self, from: data)
                    
                    // searchResults(Enum Type)
                    var searchResults: [SearchResult] = []
                    
                    // Data received through Parsing is stored by searchResultCase(albums, artists, playlists, tracks)
                    searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0)}))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0)}))
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0)}))
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Library API Call
    
    // get CurrentUser's Playlists
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LibraryPlaylistsResponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // create Playlist (POST)
    public func createUserPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        
        // get Current Profile
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                
                // use profile.id
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                
                // set request url
                self?.createRequest(with: URL(string: urlString), type: .POST, completion: { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name" : name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                completion(true)
                            }
                        }
                        catch {
                            completion(false)
                        }
                    }
                    task.resume()
                })
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    // add Track To Play (POST)
    public func addTrackToUserPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
                      type: .POST) { baseRequest in
            var request = baseRequest
            let json = [
                "uris" : [
                    "spotify:track:\(track.id)"
                ]
            ]
            
            // set request url
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    // remove Track From Playlists (DELETE)
    public func removeTrackFromUserPlaylists(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
                      type: .DELETE) { baseRequest in
            
            var request = baseRequest
            let json = [
                "tracks" : [
                    [
                        "uri": "spotify:track:\(track.id)"
                    ]
                ]
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    // get User Albums (GET)
    public func getCurrnUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LibraryAlbumsResponse.self, from: data)
                    completion(.success(result.items.compactMap({ item in
                        item.album
                    })))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // save Album (PUT)
    public func addAlbumToUserAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?ids=\(album.id)"),
                      type: .PUT) { baseRequest in
            
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode,
                      error == nil else {
                    completion(false)
                    return
                }
                // statusCode 200, OK
                completion(code == 200)
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    
    // HTTP Method
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    // createRequest (common API Method)
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        // Supplies valid token to be used API Callers
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }

            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            
            request.httpMethod = type.rawValue
            request.timeoutInterval = 10
            completion(request)
        }
    }
}
