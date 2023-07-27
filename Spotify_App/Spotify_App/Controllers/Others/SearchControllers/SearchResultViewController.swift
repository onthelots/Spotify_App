//
//  SearchResultViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

// result sections
struct SearchSection {
    let title: String
    let results: [SearchResult]
}

// delegate didTapResult
protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController{
    
    // Search Results save in sections
    private var sections: [SearchSection] = []
    
    // delegate
    weak var delegate: SearchResultsViewControllerDelegate?

    // MARK: - Components
    
    // tableView
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

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - update (Store the results divided into two-dimensional arrays to create a section)
    func update(with results: [SearchResult]) {
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
        
        // sections (two-dimensional arrays, Values with different arrays in the array)
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
        
        // Show views based on results
        tableView.isHidden = results.isEmpty
    }

}

// MARK: - Delegate, DataSource, Layout
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    // number of Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // number Of Items In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    // cell Return
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
        switch result {
            // album sections
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

            // artist sections
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
            
            // playlist sections
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
            
            // track sections
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
    
    // selected rows
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        
        // delegate를 전달하는 메서드 실행
        delegate?.didTapResult(result)
    }
    
    // setting header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
