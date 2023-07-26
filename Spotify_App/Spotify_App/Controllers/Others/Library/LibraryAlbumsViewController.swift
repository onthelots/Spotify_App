//
//  LibraryAlbumsViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    var albums = [Album]()

    // 플레이리스트가 없는 경우 나타낼 UIView()
    private let noAlbumsView = ActionLabelView()
    
    // 플레이리스트를 보여줄 UITableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        setUpNoPlaylistView()
        
        fetchData()
        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchData()
            }
        )
    }
    
    // MARK: - Observer
    private var observer: NSObjectProtocol?
    
    
    override func viewDidLayoutSubviews() {
        
        noAlbumsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noAlbumsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAlbumsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - setUp noAlbumsView (저장된 앨범이 없을때)
    private func setUpNoPlaylistView() {
        view.addSubview(noAlbumsView)
        
        // 델리게이트 생성 (noPlaylistsView의 위임을 해당 VC에서 받는다)
        noAlbumsView.delegate = self
        noAlbumsView.configure(
            with: ActionLabelViewModel(
                text: "저장된 앨범이 없습니다",
                actionTitle: "찾아보기")
        )
    }
    
    // MARK: - fetch getCurrentUserPlaylists
    private func fetchData() {
        
        // observer를 활용하여 저장된 앨범을 refresh하기 위해
        albums.removeAll()
        
        APICaller.shared.getCurrnUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error) :
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - UI 업데이트
    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        }
        else {
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
}

// MARK: - delegate (ActionDidTapButton / 앨범 찾기 버튼을 눌렀을 때)
extension LibraryAlbumsViewController: ActionLabelVieweDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        // tabBarController의 Index를 옮겨서 searchView로
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                                                       for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name,
                                                                        subtitle: album.artists.first?.name ?? "-",
                                                                        imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let album = albums[indexPath.row]
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
