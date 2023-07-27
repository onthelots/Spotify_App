//
//  PlayBackPresenter.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import AVFoundation
import Foundation
import UIKit

// Delegate protocol
protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
 }

final class PlayBackPresenter {
    
    static let shared = PlayBackPresenter()
    
    // PlayerViewController
    var playerVC: PlayerViewController?
    
    // MARK: - Audio Player
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer? // playlist or album Player
    
    // MARK: - State Model (track or tracks / currentTrack?)
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    // Check track index
    private var index: Int = 0
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    
    // MARK: - Function (How to play a song)
    
    // 1. Music Stop
    func stopPlayback() {
        player?.pause()
        player = nil
        playerQueue?.pause()
        playerQueue = nil
    }
    
    // 2. Start Playback (a single track)
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        DispatchQueue.global().async {
            guard let url = URL(string: track.preview_url ?? "") else {
                return
            }

            self.stopPlayback()
            self.track = track
            self.tracks = []

            self.player = AVPlayer(url: url)
            self.player?.volume = 0.05
            self.player?.play()

            DispatchQueue.main.async {
                let vc = PlayerViewController()
                vc.title = track.name
                vc.modalPresentationStyle = .fullScreen

                vc.dataSource = self
                vc.delegate = self

                viewController.present(
                    UINavigationController(rootViewController: vc),
                    animated: true
                )

                self.playerVC = vc
            }
        }
    }

    // 2. Start Playback (Playlist or Album play)
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        DispatchQueue.global().async {
            let playerItems: [AVPlayerItem] = tracks.compactMap { track in
                guard let url = URL(string: track.preview_url ?? "") else {
                    return nil
                }
                return AVPlayerItem(url: url)
            }

            self.stopPlayback()
        
            self.playerQueue = AVQueuePlayer(items: playerItems)
            self.playerQueue?.volume = 0.05
            self.playerQueue?.play()

            self.tracks = tracks
            self.track = nil
            self.index = 0

            DispatchQueue.main.async {
                let vc = PlayerViewController()
                vc.title = tracks.first?.album?.name
                vc.modalPresentationStyle = .fullScreen

                vc.dataSource = self
                vc.delegate = self

                viewController.present(
                    UINavigationController(rootViewController: vc),
                    animated: true
                )

                self.playerVC = vc
            }
        }
    }
}

// MARK: - Extension (Player Data Setting)
extension PlayBackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "https://picsum.photos/id/237/200/300")
    }
}

// MARK: - Extension (Slider, Button Action)
extension PlayBackPresenter: PlayerControllerDelegate {
    
    // PlayPause
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        else if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        playerVC?.refreshUI()
    }
    
    // didTapFoward
    func didTapFoward() {
        if tracks.isEmpty {
            player?.seek(to: .zero, completionHandler: { [weak self] _ in
                self?.player?.pause()
            })
        }
        else if let playerQueue = playerQueue, !tracks.isEmpty {
            
            // continuously increasing and then 0 when it becomes equal to the number in tracks
            self.index = (index + 1) % tracks.count
            playerQueue.seek(to: .zero)
            playerQueue.pause()
            playerQueue.advanceToNextItem() // playerQueue next Track
            playerQueue.play()
        }
        playerVC?.refreshUI()
    }
    
    // didTapBackward
    func didTapBackward() {
        if tracks.isEmpty {
            player?.seek(to: .zero, completionHandler: { [weak self] _ in
                self?.player?.pause()
                self?.player?.play()
            })
        }

        else if let playerQueue = playerQueue, !tracks.isEmpty {
            playerQueue.pause()
            // decrease the index, but do not make it zero
            index = (index-1 + tracks.count) % tracks.count
            
            // remove All Items
            playerQueue.removeAllItems()
            
            // add the current track to Playerd from the last track in the new track array
            let newPlayerItems: [AVPlayerItem] = tracks[index..<tracks.count].compactMap { track in
                guard let url = URL(string: track.preview_url ?? "") else {
                    return nil
                }
                return AVPlayerItem(url: url)
            }
            
            // adding a new track to the player
            newPlayerItems.forEach { items in
                playerQueue.insert(items, after: nil)
            }
            
            playerQueue.seek(to: .zero)
            playerQueue.play()
        }
        playerVC?.refreshUI()
    }
    
    // slider의 value는 player의 Volume 값으로 설정
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
}
