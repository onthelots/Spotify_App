//
//  LibraryPlaylistsViewController.swift
//  Spotify_App/Users/onthelots/Desktop/GithubRepo/Projects/Spotify_App/Spotify_App/Managers
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    var playlists = [Playlist]()
    
    // MARK: - 특정 트랙을 LongPress 한 후, 저장버튼을 눌렀을 때 현재 View로 이동되는데, 이때 실행되는 Handler
    public var selectionHandler: ((Playlist) -> Void)?
    
    // 플레이리스트가 없는 경우 나타낼 UIView()
    private let noPlaylistsView = ActionLabelView()
    
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
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                               target: self,
                                                               action: #selector(didTapClose))
        }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        
        noPlaylistsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noPlaylistsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlaylistsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - setUp No PlaylistView (플레이리스트가 없을때)
    private func setUpNoPlaylistView() {
        view.addSubview(noPlaylistsView)
        
        // 델리게이트 생성 (noPlaylistsView의 위임을 해당 VC에서 받는다)
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
    
    // MARK: - UI 업데이트
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
    
    // MARK: - Playlists를 생성하는 Alert 실행 메서드
    public func showCreatePlaylistAlert() {
        // Show creation UI Playlists
        let alert = UIAlertController(
            title: "플레이리스트 생성하기",
            message: "나만의 플레이리스트를 만들고, 플레이하세요",
            preferredStyle: .alert
        )
        
        // textField 추가
        alert.addTextField { textfield in
            textfield.placeholder = "이름"
        }
        
        // alert action 1
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel))
        
        // alert action 2 -> completion handler를 통해 실행
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

// MARK: - delegate (ActionDidTapButton / 플레이리스트 생성 버튼을 눌렀을 때)
extension LibraryPlaylistsViewController: ActionLabelVieweDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let playlist = playlists[indexPath.row]
        
        // MARK: - selectionHandler
        guard selectionHandler == nil else {
            // 만약, selectionHandler가 비어있다면?
            // selectionHandler는 현재 선택된(row) Playlist 값이 할당됨
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
