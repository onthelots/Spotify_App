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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    // Custom View
    private let toggleView = LibraryToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Library"
        view.backgroundColor = .systemBackground
        
        // add ToggleView & delegate
        view.addSubview(toggleView)
        toggleView.delegate = self
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.backgroundColor = .systemBackground
        
        // TODO: - AutoLayout으로 변경
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        
        // MARK: - paging 형식을 구현하고자, scrollView Containter View Controller를 활용
        // CollectionView를 사용하여 Paging을 사용할 시, 현재 scene화면에서 보여지지 않는 데이터 부분까지 생성되며, 이는 뷰가 매우 무거워짐
        addChildren()
        
        updateBarButtons()
    }
    
    // TODO: - AutoLayout으로 변경
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
    
    // MARK: - VC를 scrollView에 자식뷰로 할당하는 메서드
    // TODO: - AutoLayout으로 변경
    private func addChildren() {
        addChild(playlistVC) // 1. 포함시키고자 하는 VC를 addChild로 넣어주고,
        scrollView.addSubview(playlistVC.view) // 2. ScrollView의 subView로서 view를 할당한 후
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height) // 3. 포함하고자 하는 VC의 크기를 설정해주고
        playlistVC.didMove(toParent: self) // 포함하고자 하는 VC를 didMove 메서드를 통해 추가 혹은 삭제등의 상황에 반응할 수 있도록 함
        
        addChild(albumsVC) // 1. 포함시키고자 하는 VC를 addChild로 넣어주고,
        scrollView.addSubview(albumsVC.view) // 2. ScrollView의 subView로서 view를 할당한 후
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height) // 3. 포함하고자 하는 VC의 크기를 설정해주고
        albumsVC.didMove(toParent: self) // 포함하고자 하는 VC를 didMove 메서드를 통해 추가 혹은 삭제등의 상황에 반응할 수 있도록 함
    }
    
    // NavigationBarButton
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

extension LibraryViewController: UIScrollViewDelegate {
    // Scroll을 옆으로 swipe하는 동작을 실시할 때
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // swipe를 통해 scrollview의 x 좌표가 View 전체 너비의 100이 넘어갈 경우
        if scrollView.contentOffset.x >= (view.width-100) {
            // album state로 업데이트 되는 동시에 layoutIndicator 메서드를 실행함(인디케이터 변경)
            toggleView.update(for: .album)
            // NavigationBarButton 또한 playlist에만 나올 수 있도록 UI를 업데이트
            updateBarButtons()
        } else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}

extension LibraryViewController: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        // Action -> offset 설정을 통해 -> scrollView의 x, y축을 0로 설정
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        // Action -> offset 설정을 통해 -> scrollView의 x을 width의 끝부분으로, y축은 0으로 설정
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}
