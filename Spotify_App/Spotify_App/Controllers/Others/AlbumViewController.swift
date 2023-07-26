//
//  AlbumViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import UIKit

class AlbumViewController: UIViewController {

    // HomeViewController에서 Item을 didSelected할 경우, 해당 Index.item의 데이터를 할당받게 됨
    private let album: Album
    
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
    
    // Data를 받아오기 위한 Initalizer (매개변수 생성)
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - ViewModels
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    private var tracks = [AudioTrack]()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        // CollectionView -> cell 등록
        collectionView.register(
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
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
        
        fetchData()
        
        // Share Function
        let shareButton: UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        
        let addAlbumButton: UIBarButtonItem  = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapSave)
        )
        
        navigationItem.rightBarButtonItems = [shareButton, addAlbumButton]
    }
    
    // Share Button Tapped (navigationItem.rightBarButtonItem)
    @objc private func didTapShare() {
        
        // playlist url -> external_urls 딕셔너리에서, value값을 뽑아냄
        guard let url = URL(string: album.external_urls.spotify) else {
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
    
    // Save Button Tapped (navigationItem.rightBarButtonItem)
    @objc private func didTapSave() {
        
        // TODO: - 이미 동일한 앨범이 저장되어 있다면 X
        
        let actionSheet = UIAlertController(title: album.name,
                                            message: "즐겨찾는 앨범으로 저장하시겠습니까?",
                                            preferredStyle: .actionSheet)
        
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
        
        // 탭을 진행했을 때 해당 vc를 present함
        present(actionSheet, animated: true)
    }
    
    private func fetchData() {
        // HomeViewController -> didSelected한 item의 값을 album타입에 맞게 받아오고, 이를 APICaller에 위치한 getAlbumDetails 메서드의 매개변수로 할당함으로서 데이터를 할당하게 됨
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
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
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

        // delegate -> playlistHeaderCollectionReusableView에서의 메서드를 실행하기에 앞서, 위임자를 해당 컨트롤러(AlbumViewController)에 넘김
        header.delegate = self
        return header
    }
    
    // 하나의 track, 즉 cell을 눌렀을 때 (startPlayback, single tracks)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var track = tracks[indexPath.item]
        track.album = self.album
        PlayBackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// 전체 Tracklist, 즉 All play 버튼을 눌렀을 때 (startPlayback, all tracks)
extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap { tracks in
            var tracks = tracks
            tracks.album = self.album
            return tracks
        }
        PlayBackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
}
