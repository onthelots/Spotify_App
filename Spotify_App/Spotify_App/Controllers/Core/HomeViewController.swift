//
//  HomeViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/04.
//

import UIKit
import SwiftUI

// Section Type
enum BrowseSectionType {
    case newRelease(viewModels: [NewReleasesCellViewModel]) // 1
    case featuredPlaylists(viewModels: [FeaturedPlaylistsCellViewModel]) // 2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) // 3
    
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
    
    // data empty array
    private var newAlbum: [Album] = []
    private var playlists: [Playlist] = []
    private var track: [AudioTrack] = []
    
    
    // 전체 컬렉션뷰 초기 설정 (Layout은 [CompositionalLayout] 으로 진행할 예정이며, 레이아웃의 경우 createSectionLayout(NSCollectionLayoutSection)을 반환함
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return createSectionLayout(section: sectionIndex)
        }
    )
    
    // MARK: - UIActivityIndicatorView(데이터를 불러올 동안 표시될 Spinner를 선언)
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // Section -> 위에서 선언한 SectionType의 값을 선언
    private var sections = [BrowseSectionType]()
    
    // viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        
        // Configure CollectionView
        configureCollectionView()
        // spinner를 하위뷰로 추가
        view.addSubview(spinner)
        
        // Fetch API Data
        fetchData()
        
        // add playlists
        addLongTapGesture()
    }
    
    // viewDidLayoutSubViews()
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
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        // touchPoint(CGPoint) : gesture(LongPress)가 시작된 지점
        let touchPoint = gesture.location(in: collectionView)
        
        // indexPath : collectionView에서 선택한 아이템의 IndexPath(위치는 touchPoint)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              // 추가로, IndexPath의 section이 2번째 (즉, Recommended Track일 때)
              indexPath.section == 2 else {
            return
        }
        
        // selectedItem은 Recommended Track의 indexPath에 따른 Track(AudioTrack)
        let selectedItem = track[indexPath.item]
        
        // actionSheet (alert)
        let actionSheet = UIAlertController(
            title: selectedItem.name,
            message: "플레이리스트에 저장하시겠습니까?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel))
        
        // MARK: - 저장 버튼을 눌렀을 때
        actionSheet.addAction(UIAlertAction(title: "저장",
                                            style: .default, handler: { [weak self] _ in
            
            // 어디 플레이리스트에 저장할 것인데?
            DispatchQueue.main.async {
                // vc로 해당 LibraryPlaylist VC를 선언하고
                let vc = LibraryPlaylistsViewController()
                // 해당 vc에서 public 프로퍼티로 선언된 selectionHandler에 값을 할당함
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
    
    
    // MARK: - ConfigureCollectionView
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
        
        // headerview(ReusableView) 등록
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    // New Release Album Data Fetch
    private func fetchData() {
        // API 데이터가 파싱된 이후, 레이아웃을 완성시키고자 함
        
        // Dispatch Group
        // enter : 각각의 Task를 Queue에 담을 때 호출하는 메서드
        // leave : 해당 task가 완료되었음을 알리는 메서드
        // notify : 전체 Task가 완료되었음을 알림(이후, 필요한 작업을 실시)
        let group = DispatchGroup() // 여러개의 디스패치 작업을 담당
        
        // enter()를 통해 Task Count를 3 증가시킴
        group.enter()
        group.enter()
        group.enter()
        print("Start fetching data")
        
        // 각각의 API Model 변수를 가져와 -> APICaller를 통해 호출된 데이터 불러오는 메서드의 model 상수에 할당함
        var newReleases: NewReleaseResponse?
        var featuredPlaylists: FeaturedPlaylistsResponse?
        var recommendedTracks: RecommendationsResponse?
        
        // new Releases
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
        
        // Featured Playlists
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
        // Recommended Tracks
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
                    // seeds 데이터 할당하기
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
        
        // UI 이므로, Queue는 별도로 설정하지 않은 main Queue임
        group.notify(queue: .main) {
            guard let newAlbum = newReleases?.albums.items,
                  let playlists = featuredPlaylists?.playlists.items,
                  let tracks = recommendedTracks?.tracks else {
                fatalError("Models are nil")
            }
            
            // API가 정상적으로 할당되었을 때 -> configureModel 메서드(section에 model 데이터를 함께 심는 과정)를 실행함
            self.configureModels(newAlbum: newAlbum, playlists: playlists, tracks: tracks)
        }
    }
    
    
    // Models configure
    // 1. 임의로 만들어 둔 ViewModel (Model에서 필요한 객체만 별도로 정리)을 활용하기 위해, 각각의 Model에서의 배열 데이터들을 매개변수로 선언하고,
    // 2. section(빈 배열 형태의 타입이지만, 필요한 데이터를 매개변수로 가지고 있는)에서 활용할 수 있는 데이터를 매개변수에서 하나씩 뽑아서 section 배열에 할당하는 로직을 만듬
    // 3. 그렇게 되면, 위 fetchData 메서드에서 받아오는 API 데이터들을 활용하여 section 빈 배열에 실제 데이터를 할당할 수 있음
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

// MARK: - Extension to configure Layout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 컬렉션 뷰 내 섹션의 갯수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    // 컬렉션 뷰 내 섹션에 있는 아이템의 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // type은 sections 타입 중, Index에 따른 section의 모든 경우의 수를 받아옴
        let type = sections[section]
        
        // 이후, section 별로 Item의 갯수를 각각 다르게 반환함
        switch type {
        case .newRelease(viewModels: let viewModels):
            return viewModels.count
        case .featuredPlaylists(viewModels: let viewModels):
            return viewModels.count
        case .recommendedTracks(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    // 컬렉션뷰에 포함되는 cell Item의 정보
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // type은 sections 타입 중, Index에 따른 section의 모든 경우의 수를 받아옴
        let type = sections[indexPath.section]
        
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
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let section = sections[indexPath.section]
        
        // 각각의 Section 내부의 item으로 접근(didSelectedItem)하기 위한 과정
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
            // Modality -> PlayBackPresent 내 presnt 메서드 (PlayerViewController로 이동)
            PlayBackPresenter.shared.startPlayback(from: self, track: track)
         }
    }
    
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
    
    // MARK: - NSCollectionLayoutSection (Section의 레이아웃을 구성하는 메서드)
    // NSCollectionLayoutSize 요소들 (absoluteSize -> 항상 고정된 크기 / estimated -> 런타임 시, 크기가 변할 가능성이 있을 경우 / fractional -> 자신이 속한 컨테이너의 크기를 기반으로 비율을 설정. 0.0~1.0)
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        
        // section별로 Header의 레이아웃을 설정
        let supplementaryViews =  [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        
        switch section {
        // New Release Album
        case 0 :
            
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            // Vertical group in horizontal group
            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .estimated(130))

            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 2)
            
            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                             heightDimension: .estimated(260))

            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 1)
            
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            
            // header 추가
            section.boundarySupplementaryItems = supplementaryViews
            
            return section
            
        // Feature playlists
        case 1 :
            
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // Group
            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .absolute(150))
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 2)
            
            // Group (vericalGroup -> count 1)
            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                             heightDimension: .absolute(300))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            // header 추가
            section.boundarySupplementaryItems = supplementaryViews
            
            return section
            
        // Recommended Tracks
        case 2 :
            
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            
            // Vertical group in horizontal group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: group)
         
            // header 추가
          
            
            section.boundarySupplementaryItems = supplementaryViews
            return section
        
        // Mock-up
        default :
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         repeatingSubitem: item,
                                                         count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}
