//
//  PlaylistViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    // HomeViewController에서 Item을 didSelected할 경우, 해당 Index.item의 데이터를 할당받게 됨
    private let playlist: Playlist
    
    public var isOwner = false
    
    // rendering (section이 하나이므로, 매개변수값은 없음)
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ -> NSCollectionLayoutSection in
                
                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                
                
                // Vertical group in horizontal group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                )
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                
                // Section
                let section = NSCollectionLayoutSection(group: group)
                
                // Header 레이아웃 설정
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1)),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
                ]
                return section
            })
    )
    
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - ViewModels
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        // CollectionView -> cell 등록
        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        
        // collectionview -> Header(ReusableView) 등록
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // HomeViewController -> didSelected한 item의 값을 album타입에 맞게 받아오고, 이를 APICaller에 위치한 getPlaylistsDetails 메서드의 매개변수로 할당함으로서 데이터를 할당하게 됨
        APICaller.shared.getPlaylistsDetails(for: playlist) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ item in
                        item.track
                    })
                    self?.viewModels = model.tracks.items.compactMap({ item in
                        RecommendedTrackCellViewModel(
                            name: item.track.name,
                            artistName: item.track.artists.first?.name ?? "-",
                            artworkURL: URL(string: item.track.album?.images.first?.url ?? "")
                        )
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        // Share Function
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        
        // gesture 추가
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return
        }
        
        let trackToDelete = tracks[indexPath.item]
        
        let actionSheet = UIAlertController(
            title: trackToDelete.name,
            message: "해당 트랙을 플레이리스트에서 삭제합니까?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        
        actionSheet.addAction(UIAlertAction(title: "삭제",
                                            style: .default, handler: { [weak self] _ in
            
            // handler는 weak 참조 유형의 메서드다 보니, 아래 APICaller의 매개변수 값으로 할당되는 현재 viewController의 playlist는 strongSelf라는 바인딩 된 viewController를 할당함
            guard let strongSelf = self else {
                return
            }
            // 삭제 버튼을 눌렀을 때
            APICaller.shared.removeTrackFromUserPlaylists(track: trackToDelete,
                                                      playlist: strongSelf.playlist) { success in
                
                DispatchQueue.main.async {
                    if success {
                        strongSelf.tracks.remove(at: indexPath.item)
                        strongSelf.viewModels.remove(at: indexPath.item)
                        strongSelf.collectionView.reloadData()
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    // Share Button Tapped (navigationItem.rightBarButtonItem)
    @objc private func didTapShare() {
        
        // playlist url -> external_urls 딕셔너리에서, value값을 뽑아냄
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        
        // 이후, 임의의 ActivityVC를 생성한 후, Item으로 할당한 urlString(playlist url)을 배열에 추가함
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        
        // 해당 vc가 모달되는 popover(공유기능)의 barButtonItem은, 기존에 생성한 rightBarButtonItem이며,
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        // 탭을 진행했을 때 해당 vc를 present함
        present(vc, animated: true)
    }
    
    // CollectionView 크기 조정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = PlaylistHeaderViewModel(
            playlistName: playlist.name,
            ownerName: playlist.owner.display_name,
            description: playlist.description,
            artworkURL: URL(string: playlist.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        
        // delegate -> playlistHeaderCollectionReusableView에서의 메서드를 실행하기에 앞서, 위임자를 해당 컨트롤러(PlaylistViewController)에 넘김
        header.delegate = self
        return header
                
    }
    
    // 하나의 track, 즉 cell을 눌렀을 때 (startPlayback, single tracks)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let track = tracks[indexPath.item]
        PlayBackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// play all button clicked (playBackPresent 내 startPlayback 메서드 실행)
extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // Start play list play in queue
        print("Playing all")
    
        // playlists에 담겨있는 모든 track의 데이터를 보냄
        PlayBackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
