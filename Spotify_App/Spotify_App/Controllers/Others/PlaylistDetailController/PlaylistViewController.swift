//
//  PlaylistViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    // store parsed data
    private let playlist: Playlist
    
    // MARK: - ViewModels
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    // MARK: - Initializer
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Components
    
    // collectionView
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ -> NSCollectionLayoutSection in
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(60))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             repeatingSubitem: item,
                                                             count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                
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
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchData()
        
        // Share Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        
        // gesture
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Fetch Data (with API Caller)
    private func fetchData() {
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
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    // MARK: - LongPress gesture
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
            
            guard let strongSelf = self else {
                return
            }
            // if remove button tapped
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
    
    // MARK: - NavigationButtonItem Actions
    // share
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
    
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

// MARK: - Delegate, DataSource, Layout
extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // number of Section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number Of Items In Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    // cell Return
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
    
    // header
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
        header.delegate = self
        return header
                
    }
    
    // selected Items (single track)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let track = tracks[indexPath.item]
        PlayBackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// MARK: - Header Deleagate
extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // touch up inside button (play album tracks)
        PlayBackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
