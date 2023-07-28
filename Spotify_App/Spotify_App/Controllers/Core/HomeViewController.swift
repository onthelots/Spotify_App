//
//  HomeViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/04.
//

import UIKit
import SwiftUI

// MARK: - Section Type (Associated Values)
enum BrowseSectionType {
    case newRelease(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistsCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
    
    var title: String {
        switch self {
        case .newRelease :
            return "New Released Albums"
        case .featuredPlaylists :
            return "Featured Playlists"
        case .recommendedTracks :
            return "Recommended Tracks"
        }
    }
}

class HomeViewController: UIViewController {
    
    // Array to store parsed data
    private var newAlbum: [Album] = []
    private var playlists: [Playlist] = []
    private var track: [AudioTrack] = []
    
    // Sections
    private var sections = [BrowseSectionType]()
    
    // MARK: - Components
    
    // CollectionView
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return createSectionLayout(section: sectionIndex)
        }
    )
    
    // UIActivityIndicatorView(Spinner)
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSetting)
        )
        
        configureCollectionView() // configure collectionView
        view.addSubview(spinner)
        fetchData() // fetch API Data
        addLongTapGesture() // LongGesture action in collectionView (Add Playlists Gesture)
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    // MARK: - Add Playlists Gesture
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                             action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    // configure didLongPress
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        // touchPoint(CGPoint) : The point at which the gesture(LongPress) started
        let touchPoint = gesture.location(in: collectionView)
        
        // indexPath : IndexPath of the item selected in collectionView
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              // the section of the IndexPath is the second('Recommended Track' section)
              indexPath.section == 2 else {
            return
        }
        
        // selectedItem
        let selectedItem = track[indexPath.item]
        
        // actionSheet (alert)
        let actionSheet = UIAlertController(
            title: selectedItem.name,
            message: "플레이리스트에 저장하시겠습니까?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "저장",
                                            style: .default, handler: { [weak self] _ in
            
            // Add Playlists Process
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToUserPlaylist(track: selectedItem,
                                                        playlist: playlist) { success in
                        print("플레이리스트에 트랙이 저장되었습니다 : \(success)")
                    }
                }
                vc.title = "저장할 플레이리스트를 선택해주세요"
                self?.present(UINavigationController(rootViewController: vc), animated: true)
            }
        }))
        
        // present actionSheet
        present(actionSheet, animated: true)
    }
    
    
    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        view.addSubview(collectionView)
      
        // Register Cell
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: "NewReleaseCollectionViewCell")
        collectionView.register(FeaturedPlaylistsCollectionViewCell.self,
                                forCellWithReuseIdentifier: "FeaturedPlaylistsCollectionViewCell")
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: "RecommendedTrackCollectionViewCell")
        
        // headerview(ReusableView)
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    // MARK: - Fetch Data (with API Caller)
    private func fetchData() {
        let group = DispatchGroup() // create DispatchGroup
        
        // Task Count Up
        group.enter()
        group.enter()
        group.enter()
        
        // Model (Response)
        var newReleases: NewReleaseResponse?
        var featuredPlaylists: FeaturedPlaylistsResponse?
        var recommendedTracks: RecommendationsResponse?
        
        // 1. new Releases
        APICaller.shared.getNewRelease { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // 2. Featured Playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let model):
                featuredPlaylists = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        // 3.Recommended Tracks
        APICaller.shared.getRecommendedGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendedTracks = model
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // notify
        group.notify(queue: .main) {
            guard let newAlbum = newReleases?.albums.items,
                  let playlists = featuredPlaylists?.playlists.items,
                  let tracks = recommendedTracks?.tracks else {
                fatalError("Models are nil")
            }
            
            // configureModels
            self.configureModels(newAlbum: newAlbum, playlists: playlists, tracks: tracks)
        }
    }
    
    
    // MARK: - Models configure (section Associated Values)
    private func configureModels(newAlbum: [Album],
                                 playlists: [Playlist],
                                 tracks: [AudioTrack]) {
        
        self.newAlbum = newAlbum
        self.playlists = playlists
        self.track = tracks
        
        // Section 0 -> NewReleases
        sections.append(.newRelease(viewModels: newAlbum.compactMap({ item in
            return NewReleasesCellViewModel(name: item.name,
                                            artworkURL: URL(string: item.images.first?.url ?? ""),
                                            numberOfTracks: item.total_tracks,
                                            artistName: item.artists.first?.name ?? "-")
        })))
        
        // Section 1 -> featuredPlaylists
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({ item in
            return FeaturedPlaylistsCellViewModel(name: item.name,
                                                  artworkURL: URL(string: item.images.first?.url ?? ""))
        })))
        
        // Section 2 -> recommendedTracks
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({ item in
            return RecommendedTrackCellViewModel(name: item.name,
                                                 artistName: item.artists.first?.name ?? "-",
                                                 artworkURL: URL(string: item.album?.images.first?.url ?? ""))
        })))
        
        // Refresh Scene (collectionView)
        collectionView.reloadData()
    }
    
    // Action -> Setting Button (NavigationBar Item)
    @objc func didTapSetting() {
        let vc = SettingViewController()
        vc.title = "Setting"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Delegate, DataSource, Layout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // number of Section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    // number Of Items In Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Index section
        let type = sections[section]
        
        switch type {
        case .newRelease(viewModels: let viewModels):
            return viewModels.count
        case .featuredPlaylists(viewModels: let viewModels):
            return viewModels.count
        case .recommendedTracks(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    // cell Return
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // type은 sections 타입 중, Index에 따른 section의 모든 경우의 수를 받아옴
        let type = sections[indexPath.section]
        
        // Returns the created Reusable cell
        switch type {
        case .newRelease(viewModels: let viewModels) :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                                                          for: indexPath) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.item]
            cell.configure(with: viewModel)
            return cell
            
        case .featuredPlaylists(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistsCollectionViewCell.identifier,
                                                          for: indexPath) as? FeaturedPlaylistsCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.item]
            cell.configure(with: viewModel)
            return cell
            
        case .recommendedTracks(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                                                          for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.item]
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    // selected Items
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Haptics Effect
        HapticManager.shared.vibrateForSelection()
        
        let section = sections[indexPath.section]
        
        switch section {
        case .featuredPlaylists :
            let playlist = playlists[indexPath.item]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newRelease :
            let album = newAlbum[indexPath.item]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks :
            let track = track[indexPath.item]
            PlayBackPresenter.shared.startPlayback(from: self, track: track)
         }
    }
    
    // setting headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                                                                           for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let model = sections[section].title
        header.configure(with: model)
        return header
    }
    
    // MARK: - NSCollectionLayoutSection (setting sections layout)
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        
        // header Layout
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        // Secton Layout
        switch section {
        case 0 :
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .estimated(75))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 3)
            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                             heightDimension: .estimated(225))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 1)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section
            
        case 1 :
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .absolute(160))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 2)
            
            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                             heightDimension: .absolute(320))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 1)
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            
            return section
            
        case 2 :
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 1)

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            
            return section
        
        // Mock-up
        default :
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         repeatingSubitem: item,
                                                         count: 1)
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }
}
