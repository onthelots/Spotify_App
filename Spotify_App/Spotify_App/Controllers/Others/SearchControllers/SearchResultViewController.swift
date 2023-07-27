//
//  SearchResultViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

// TODO: - CollectionView로 보기 좋게 UI 변경하기

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

// MARK: - row를 눌렀을 때, 다른 VC로 넘어가기 위한 Delegate 설정
protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    // Section title에 따라 구분되기 위해, 2차원으로 타입을 변경함
    private var sections: [SearchSection] = []
    
    // VC Push delegate
    weak var delegate: SearchResultsViewControllerDelegate?

    // tableViw
    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .grouped
        )
        
        // SearchResultDefaultTableViewCell
        tableView.register(SearchResultDefaultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        
        // SearchResultSubtitleTableViewCell
        tableView.register(SearchResultSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        
        tableView.isHidden = true
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        
        // 각각의 Case 마다 Section으로 만들어줘야하기 때문에, 해당하는 Case의 값만 가져오고(true), 나머지는 X(false)
        
        let artists = results.filter { item in
            switch item {
            case .artist:
                return true
            default :
                return false
            }
        }
        
        let albums = results.filter { item in
            switch item {
            case .album:
                return true
            default :
                return false
            }
        }
        
        let playlists = results.filter { item in
            switch item {
            case .playlist:
                return true
            default :
                return false
            }
        }
        
        let tracks = results.filter { item in
            switch item {
            case .track:
                return true
            default :
                return false
            }
        }
        
        self.sections = [
            SearchSection(title: "Songs",
                          results: tracks),
            SearchSection(title: "Artists",
                          results: artists),
            SearchSection(title: "Playlists",
                          results: playlists),
            SearchSection(title: "Albums",
                          results: albums)
        ]
        
        tableView.reloadData()
        
        // results 가 비어있지 않다면(false) -> tableView.isHidden Boolean값도 false로 변환
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var content = defaultCell.defaultContentConfiguration()
        let result = sections[indexPath.section].results[indexPath.row]

        // row, 혹은 Section에 따라 TableViewCell을 다르게 보여주기 위함
        switch result {
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }

            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "-",
                imageURL: URL(string: album.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell

        case .artist(model: let artist):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultDefaultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }

            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
            
        case .playlist(model: let playlist):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }

            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
            
        case .track(model: let track) :
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }

            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: track.name,
                subtitle: track.artists.first?.name ?? "-",
                imageURL: URL(string: track.album?.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        
        // delegate를 전달하는 메서드 실행
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
