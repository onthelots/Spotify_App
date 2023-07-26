//
//  SearchViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // SearchController
    let searchController: UISearchController = {
        
        // initializer SearchController (검색 결과를 나타내는 'SearchResultViewController'가 담긴 vc를 만듬)
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
           
            // item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 2,
                leading: 7,
                bottom: 2,
                trailing: 7
            )
            
            // group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(110)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 2
            )
            
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 0,
                bottom: 5,
                trailing: 0
            )
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        })
    )
    
    private var categories = [Category]()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        // 검색 결과를 업데이트&담당
        searchController.searchResultsUpdater = self
        
        // 검색창(Bar)에 대한 기능을 담당
        searchController.searchBar.delegate = self
        
        //configure navigationItem SearchController
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
                    
                    // 빈 배열에 받아오는 Category 배열을 부여함
                    self?.categories = categories
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
    }
    
    // MARK: - Delegate -> Search Button Clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // query -> searchBar에 작성되는 text
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              // query text의 공백을 모두 제거한 이후, 비어있지 않다면(Not Empty)
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // MARK: - ✅ SearchViewController에서 나타나는 searchResultsController의 위임을 받고
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
    
    // MARK: - Delegate -> Search Results method
    func updateSearchResults(for searchController: UISearchController) {
        
        // query -> searchBar에 작성되는 text
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchController.searchBar.text,
              // query text의 공백을 모두 제거한 이후, 비어있지 않다면(Not Empty)
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // MARK: - ✅ SearchViewController에서 나타나는 searchResultsController의 위임을 받고
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

// MARK: - ✅ SearchResultsViewControllerDelegate의 showResult 메서드 구현함
// navigationController, pushVC를 인자로 진행할 수 있도록 위임을 받음
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


// Extension (Delegate, DataSource)
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier,
                                                            for: indexPath) as? CategoryCollectionViewCell else {
            return CategoryCollectionViewCell()
        }
        
        // 임의상수 category에 API Parsing을 통해 채워진 categories 배열의 index싱을 통한 item 값을 할당하고
        let category = categories[indexPath.item]
        cell.configure(with: CategoryCollectionViewCellViewModel(
            title: category.name,
            artworkURL: URL(string: category.icons.first?.url ?? ""))
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀 선택효과 해제
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // Haptics
        HapticManager.shared.vibrateForSelection()
        
        let category = categories[indexPath.item]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
