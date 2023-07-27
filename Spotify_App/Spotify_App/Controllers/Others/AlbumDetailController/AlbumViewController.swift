//
//  AlbumViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import UIKit

class AlbumViewController: UIViewController {

    // store parsed data
    private let album: Album
    
    // MARK: - ViewModels
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    private var tracks = [AudioTrack]()
    
    // MARK: - Initializer
    init(album: Album) {
        self.album = album
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
        title = album.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        collectionView.register(
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
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
        
        // share Button
        let shareButton: UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        
        // save Album Button
        let addAlbumButton: UIBarButtonItem  = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapSave)
        )
        
        // add NavigationBarItem Buttons
        navigationItem.rightBarButtonItems = [shareButton, addAlbumButton]
    }
    
    // MARK: - Fetch Data (with API Caller)
    private func fetchData() {
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model) :
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap({ item in
                        AlbumCollectionViewCellViewModel(name: item.name,
                                                         artistName: item.artists.first?.name ?? "-")
                    })
                    
                    self?.collectionView.reloadData()
                case .failure(let error) :
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
    
    // MARK: - NavigationButtonItem Actions
    // share
    @objc private func didTapShare() {
        guard let url = URL(string: album.external_urls.spotify) else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // save
    @objc private func didTapSave() {
        let actionSheet = UIAlertController(title: album.name,
                                            message: "즐겨찾는 앨범으로 저장하시겠습니까?",
                                            preferredStyle: .actionSheet)
        
        // Sheet Actions
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "저장", style: .default, handler: { [weak self] _ in
            
            guard let strongSelf = self else { return }
            APICaller.shared.addAlbumToUserAlbum(album: strongSelf.album) { success in
                if success {
                    HapticManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                }
                else {
                    HapticManager.shared.vibrate(for: .error)
                }
            }
        }))
        present(actionSheet, animated: true)
    }
}

// MARK: - Delegate, DataSource, Layout
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            withReuseIdentifier: AlbumTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? AlbumTrackCollectionViewCell else {
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
            playlistName: album.name,
            ownerName: album.artists.first?.name ?? "-",
            description: "Release Data : \(String.formattedDate(string: album.release_date))",
            artworkURL: URL(string: album.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    // selected Items (single track)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var track = tracks[indexPath.item]
        track.album = self.album
        PlayBackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// MARK: - Header Deleagate
extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    
    // touch up inside button (play album tracks)
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap { tracks in
            var tracks = tracks
            tracks.album = self.album
            return tracks
        }
        PlayBackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
}
