//
//  ProfileViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    // store parsed data
    private var models = [String]()
    
    // MARK: - Components
    
    // tableView()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        fetchProfile()
        
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - fetchData
    func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model) :
                    self?.updateUI(with: model)
                case .failure(let error) :
                    print(error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    // MARK: - updateUI
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        
        // configure table models
        models.append("Full Name: \(model.display_name)")
        models.append("E-mail: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product)")
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    
    // data parsing failed image
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile."
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    // MARK: - create simple headerView (frame-base)
    private func createTableHeader(with string: String?) {
        guard let urlString = string, let url = URL(string: urlString) else {
            return
        }
        
        // headerView Size Configure
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        
        // headerview in ImageSize
        let imageSize: CGFloat = headerView.height/2
        
        // create Image View
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        
        // headerview in imageView
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        
        // layout imageView
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        
        // import Image (indicatorType -> 빙글빙글 돌아가는 로딩효과 / option -> 이미지가 나타나는 효과)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: nil,
                              options: [.transition(.fade(0.5))],
                              progressBlock: nil)
        
        tableView.tableHeaderView = headerView
    }
}

// MARK: - Delegate, DataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    // number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count // Row의 갯수
    }
    
    // cell Return
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}

