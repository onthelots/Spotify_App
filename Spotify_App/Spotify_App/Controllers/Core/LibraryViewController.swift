//
//  LibraryViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let playlistVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()
    
    // MARK: Components
    
    // scrollView
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    // Custom View (ToggleView)
    private let toggleView = LibraryToggleView()

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Library"
        view.backgroundColor = .systemBackground
        
        // add ToggleView & delegate
        view.addSubview(toggleView)
        toggleView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.backgroundColor = .systemBackground
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        
        // add ChildView
        addChildren()
        
        // Update navigationItemBar with State(playlists, albums)
        updateBarButtons()
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top + 55,
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55
        )
        
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55
        )
    }
    
    // MARK: - Add ChildView in scrollView
    private func addChildren() {
        addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }
    
    // MARK: - NavigationBarButton
    private func updateBarButtons() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // didTapAdd(playlistview)
    @objc func didTapAdd() {
        playlistVC.showCreatePlaylistAlert()
    }
}

// MARK: - Extension (didScroll and update toggleView)

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100) {
            toggleView.update(for: .album)
            updateBarButtons()
        } else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}

// MARK: - Extension (update bar Button)
extension LibraryViewController: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}
