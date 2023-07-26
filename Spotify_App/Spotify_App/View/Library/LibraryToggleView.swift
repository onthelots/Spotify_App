//
//  LibraryToggleView.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

// delegate protocol
protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {
    
    enum State {
        case playlist
        case album
    }
    
    var state: State = .playlist
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistsButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    // indicator view
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
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
    
    @objc private func didTapPlaylists() {
        state = .playlist
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        // setContentOffset 위치 이동
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    
    @objc private func didTapAlbums() {
        state = .album
        
        // UIView를 업데이트하기 위한 메서드 추가
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        // setContentOffset 위치 이동
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    
    // TODO: - AutoLayout으로 변경
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistsButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistsButton.right, y: 0, width: 100, height: 40)
        
        layoutIndicator()
    }
    
    // indicator를 이동시키기 위한 메서드(+ Animation)
    func layoutIndicator() {
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistsButton.bottom, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: albumsButton.left, y: albumsButton.bottom, width: 100, height: 3)
        }
    }
    
    // contentOffset가 넘어갈 때, state를 변경시켜주고, 화면(scrollViewDidScroll)과 indicator도 변경시킴
    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
