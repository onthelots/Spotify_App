//
//  ProfileViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Profile을 나타내는 TableView
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        // 데이터(DataSource)를 얻어올 시, Hidden을 false로 변경함
        tableView.isHidden = true
        
        // forCellReuseIdentifier (재사용 Cell의 Identifier) -> "cell"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    // Mock-up------------
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        fetchProfile()
        view.backgroundColor = .systemBackground
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 뷰가 나타날 때, 상위 뷰 전체에 꽉 차도록
        tableView.frame = view.bounds
    }
    
    
    // Profile 데이터를 fetch
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
    
    // getCurrentUserProfile 메서드에서 data(model)을 받아오면, updateUI의 인자로 할당하여 데이터를 할당
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
    
    // 🖼️ Create Image Header View
    private func createTableHeader(with string: String?) {
        guard let urlString = string, let url = URL(string: urlString) else {
            return
        }
        
        // TODO: - AutoLayout(Anchor)로 변경하기
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
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile."
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        // 중앙정렬
        label.center = view.center
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count // Row의 갯수
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}

