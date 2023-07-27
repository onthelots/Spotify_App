//
//  LibraryPlaylistsViewController.swift
//  Spotify_App/Users/onthelots/Desktop/GithubRepo/Projects/Spotify_App/Spotify_App/Managers
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    // store parsed data
    var playlists = [Playlist]()
    
    // MARK: - 특정 트랙을 LongPress 한 후, 저장버튼을 눌렀을 때 현재 View로 이동되는데, 이때 실행되는 Handler
    public var selectionHandler: ((Playlist) -> Void)?
    
    // MARK: - Components
    
    // actionLabelView()
    private let noPlaylistsView = ActionLabelView()
    
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
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                               target: self,
                                                               action: #selector(didTapClose))
        }
    }
    
    // MARK: - Dismiss()
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        
        // noPlaylistView
        noPlaylistsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noPlaylistsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlaylistsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // tableView
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - setup (no Playlist view)
    private func setUpNoPlaylistView() {
        view.addSubview(noPlaylistsView)
        
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(
            with: ActionLabelViewModel(
                text: "저장된 플레이리스트가 없습니다",
                actionTitle: "생성하기")
        )
    }
    
    // MARK: - fetch getCurrentUserPlaylists
    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error) :
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - UI Update
    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        }
        else {
            tableView.reloadData()
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    // MARK: - Add Playlists
    public func showCreatePlaylistAlert() {
        // Show creation UI Playlists
        let alert = UIAlertController(
            title: "플레이리스트 생성하기",
            message: "나만의 플레이리스트를 만들고, 플레이하세요",
            preferredStyle: .alert
        )
        
        // textField
        alert.addTextField { textfield in
            textfield.placeholder = "이름"
        }
        
        // alert action
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "생성",
                                      style: .default,
                                      handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            // MARK: - API createdPlaylists (POST)
            APICaller.shared.createUserPlaylist(with: text) { success in
                if success {
                    // Haptics
                    HapticManager.shared.vibrate(for: .success)
                    self.fetchData()
                }
                else {
                    HapticManager.shared.vibrate(for: .error)
                    print("Failed to create Playlist")
                }
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - delegate (did '플레이리스트 생성하기' Tapped)
extension LibraryPlaylistsViewController: ActionLabelVieweDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

// MARK: - Delegate, DataSource, Layout
extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    // number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    // cell Return
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                                                       for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name,
                                                                        subtitle: playlist.owner.display_name,
                                                                        imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    // selected Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let playlist = playlists[indexPath.row]
        
        // MARK: - selectionHandler
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
