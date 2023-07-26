//
//  PlayBackPresenter.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import AVFoundation
import Foundation
import UIKit

// Delegate Pattern
protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
 }

final class PlayBackPresenter {
    
    static let shared = PlayBackPresenter()
    
    // 3️⃣startPlayback 메서드를 실행할 때 마다, 아래 track, tracks 데이터가 할당이 됨
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    // delegate?
    var playerVC: PlayerViewController?
    
    // 현재 PlayViewController 저장변수
    private weak var currentPlayerVC: PlayerViewController?
    
    
    // MARK: - Audio Player
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer? // playlist or album Player
    
    // 3️⃣현재 트랙 : 저장 프로퍼티 (하나의 track이냐, 아니면 앨범, 플레이리스트 전체의 Tracks이냐)
    var currentTrack: AudioTrack? {
        // 전체 재생이 아닐 경우, track만을 반환함
        if let track = track, tracks.isEmpty {
            return track
            // 전체 재생일 경우(tracks가 비어있지 않을 경우), 현재 재생되는 Track을 반환해야 함
            // tracks일 경우에는 반드시 AVplayer의 유형을 결정해줘야 함 (여기서는 앨범 혹은 플레이리스트니까, playerQueue일 경우에만 저장되도록 함)
        }
        else if !tracks.isEmpty {
            // didTapFoward에서 index 값을 할당함 (
            return tracks[index]
        }

        return nil
    }
    
    // track의 인덱스 값을 확인하는 변수
    private var index: Int = 0
    
    // MARK: - Music Stop (기존에 재생 중이던 음악을 정지하는 메서드)
//    func stopPlayback() {
//        if let player = player {
//            player.pause()
//            self.track = nil
//        }
//        if let playerQueue = playerQueue {
//            playerQueue.pause()
//            self.playerQueue = nil
//        }
//    }
    func stopPlayback() {
        player?.pause()
        player = nil
        playerQueue?.pause()
        playerQueue = nil
    }
    
    // MARK: - startPlayback
    
    // 단일 트랙 재생
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
                print("현재 트랙: \(String(describing: self.playerVC?.dataSource?.songName))")
            }
        }
    }

    // 전체 트랙 재생
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
                print("현재 트랙: \(String(describing: self.playerVC?.dataSource?.songName))")
            }
        }
    }
}



// 4️⃣ playerDataSource protocol 타입 내 정의된 프로퍼티를, 현재 PlayBackPresenter extension을 통해 데이터를 할당할 수 있도록 함
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

// MARK: - 프로토콜 playerControllerDelegate 내 메서드를 정의
extension PlayBackPresenter: PlayerControllerDelegate {
    
    // PlayPause 기능 정의
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
    
    // didTapFoward 기능 정의
    func didTapFoward() {
        if tracks.isEmpty {
            player?.seek(to: .zero, completionHandler: { [weak self] _ in
                self?.player?.pause()
            })
            print("다음 트랙이 없습니다.")
        }
        // tracks(items)의 첫번째 트랙
        else if let playerQueue = playerQueue, !tracks.isEmpty {
            // 마지막 인덱스를 초과할 경우, 0으로 다시 수렴하도록 함
            // 처음 didTapFoward 함수를 실행했을 땐 1이며, 지속적으로 증가하다가 tracks의 숫자와 동일해졌을 때 다시 0으로
            self.index = (index + 1) % tracks.count
            playerQueue.seek(to: .zero)
            playerQueue.pause() // 다음 트랙을 재생하기 전, 현재 재생중인 트랙을 정지시킴
            playerQueue.advanceToNextItem() // playerQueue에서 다음 아이템으로 옮기고
            playerQueue.play() // 재생함
            print("현재 트랙 : \(String(describing: currentTrack?.name))")
        }
        playerVC?.refreshUI()
    }
    
    // didTapBackward 기능 정의
    // AVQueueplayer는 단순히 Index를 통해 뒤로 이동할 수 없음(즉, 이전 Item으로 갈 수 없음)
    func didTapBackward() {
        // tracks이긴 한데, 단일 트랙일 때
        if tracks.isEmpty {
            // Not playlist or album
            player?.seek(to: .zero, completionHandler: { [weak self] _ in
                self?.player?.pause() // 멈췄다가
                self?.player?.play() // 재생함
            })
        }
        // tracks이고, 비어있지 않으며 playeQueue일 때
        else if let playerQueue = playerQueue, !tracks.isEmpty {
            playerQueue.pause()
            // 인덱스 값을 감소시키는 대신, 0이 되지 않도록 함
            index = (index-1 + tracks.count) % tracks.count
            
            // player에 새로운 아이템을 추가해야하므로, 기존 아이템을 모두 삭제함
            playerQueue.removeAllItems()
            
            // 현재 트랙(즉, 감소된 트랙)부터 새로운 트랙배열의 마지막 트랙까지 Playerd에 추가시킴
            let newPlayerItems: [AVPlayerItem] = tracks[index..<tracks.count].compactMap { track in
                guard let url = URL(string: track.preview_url ?? "") else {
                    return nil
                }
                return AVPlayerItem(url: url)
            }
            
            // 새로운 트랙을 player에 추가시킴 (그렇게 되면, Index가 줄어든 현재의 트랙에서부터 맨 마지막 트랙까지 다시 새롭게 playerQueue 아이템이 채워짐)
            newPlayerItems.forEach { items in
                playerQueue.insert(items, after: nil)
            }
            
            playerQueue.seek(to: .zero) // 처음으로 돌리고,
            playerQueue.play() // 재생
        }
        playerVC?.refreshUI()
    }
    
    // slider의 value는 player의 Volume 값으로 설정
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
}
