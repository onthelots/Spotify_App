//
//  SearchViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Components
    
    // searchController
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultViewController())
        vc.searchBar.placeholder = "Song, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    // collectionView
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
           
            // NSCollectionLayoutSection (setting sections layout)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                         leading: 7,
                                                         bottom: 2,
                                                         trailing: 7)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(110))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           repeatingSubitem: item,
                                                           count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 5,
                                                          leading: 0,
                                                          bottom: 5,
                                                          trailing: 0)
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        })
    )
    
    // Array to store parsed data
    private var categories = [Category]()
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        // search Results update
        searchController.searchResultsUpdater = self
        
        // searchBar
        searchController.searchBar.delegate = self
        
        // configure navigationItem SearchController
        navigationItem.searchController = searchController
        
        collectionView.register(CategoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
        // collectionView delegate, dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        // Category API Parsing
        APICaller.shared.getCategories { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
    }
    
    // MARK: - Delegate(Search Button Clicked)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        resultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    resultsController.update(with: result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delegate(Search Results method)
    func updateSearchResults(for searchController: UISearchController) {
        
        // query -> searchBar에 작성되는 text
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchController.searchBar.text,
              // query text의 공백을 모두 제거한 이후, 비어있지 않다면(Not Empty)
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        resultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    resultsController.update(with: result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: -Implemented 'didTapResult' functionality
extension SearchViewController: SearchResultsViewControllerDelegate {
    func didTapResult(_ result: SearchResult) {
        switch result {
        case .artist(let model):
            guard let url = URL(string: model.external_urls.spotify) else {
                return
            }
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
        case .album(let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .playlist(let model):
            let vc = PlaylistViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .track(let model):
            PlayBackPresenter.shared.startPlayback(from: self, track: model)
        }
    }
}

// MARK: - Delegate, DataSource, Layout
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // number of Section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number Of Items In Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    // cell Return
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier,
                                                            for: indexPath) as? CategoryCollectionViewCell else {
            return CategoryCollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        cell.configure(with: CategoryCollectionViewCellViewModel(
            title: category.name,
            artworkURL: URL(string: category.icons.first?.url ?? ""))
        )
        return cell
    }
    
    // selected Items
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let category = categories[indexPath.item]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
