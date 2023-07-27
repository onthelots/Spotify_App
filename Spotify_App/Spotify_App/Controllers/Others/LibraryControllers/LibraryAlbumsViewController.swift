//
//  LibraryAlbumsViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    // store parsed data
    var albums = [Album]()

    // actionLabelView()
    private let noAlbumsView = ActionLabelView()
    
    // MARK: - Components
    
    // tableView()
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
    
    // MARK: - ViewDidLoad()
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
    
    // MARK: - Layout Settings
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
    
    // MARK: - set up (no albums view)
    private func setUpNoPlaylistView() {
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(
            with: ActionLabelViewModel(
                text: "저장된 앨범이 없습니다",
                actionTitle: "찾아보기")
        )
    }
    
    // MARK: - fetch getCurrentUserAlbums
    private func fetchData() {
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
    
    // MARK: - UI Update
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

// MARK: - delegate (did '앨범 찾기 버튼' Tapped)
extension LibraryAlbumsViewController: ActionLabelVieweDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

// MARK: - Delegate, DataSource, Layout
extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    // number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    // cell Return
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
    
    // selected Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let album = albums[indexPath.row]
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
