//
//  LibraryToggleView.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

// Delegate protocol
protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}


class LibraryToggleView: UIView {
    
    // MARK: - Paging the screen according to offset location and status button click
    // State
    enum State {
        case playlist
        case album
    }
    
    // flag
    var state: State = .playlist
    
    // delegate
    weak var delegate: LibraryToggleViewDelegate?
    
    // MARK: - Components
    
    // playlists state button
    private let playlistsButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    // album state button
    private let albumsButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    // indicator view (Bottom of each button)
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistsButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        
        playlistsButton.addTarget(
            self,
            action: #selector(didTapPlaylists),
            for: .touchUpInside
        )
        
        albumsButton.addTarget(
            self,
            action: #selector(didTapAlbums),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - State Button Tapped Action
    
    @objc private func didTapPlaylists() {
        state = .playlist
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    
    @objc private func didTapAlbums() {
        state = .album
        
        // UIView를 업데이트하기 위한 메서드 추가
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistsButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistsButton.right, y: 0, width: 100, height: 40)
        
        layoutIndicator()
    }
    
    // MARK: - Move Indicator View
    
    // Change the position of the indicator depending on the State(album, playlists)
    func layoutIndicator() {
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistsButton.bottom, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: albumsButton.left, y: albumsButton.bottom, width: 100, height: 3)
        }
    }
    
    // update (Scene, Indicator Both)
    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
