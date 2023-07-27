//
//  SettingViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class SettingViewController: UIViewController {
    
    // MARK: - Components
    
    // tableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // section
    private var sections = [Section]()
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Setting"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    // MARK: - Setting Section
    private func configureModels() {
        sections.append(Section(title: "Profile", option: [Option(title: "View Your Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
        })]))
        
        // Section 2
        sections.append(Section(title: "Account", option: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
        })]))
    }
    
    // MARK: - Actions
    
    // viewProfile
    private func viewProfile() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // signOut
    private func signOutTapped() {
        let alert = UIAlertController(title: "로그아웃",
                                      message: "정말 로그아웃 하시겠습니까?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "아니오",
                                      style: .cancel))
        
        alert.addAction(UIAlertAction(title: "네",
                                      style: .destructive, handler: { _ in
            
            AuthManager.shared.signOut { [weak self] signOut in
                if signOut {
                    DispatchQueue.main.async {
                        let navVC = UINavigationController(rootViewController: WelcomeViewController())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        
                        self?.present(navVC, animated: true, completion: {
                            // back to WelcomeView
                            self?.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

    // num of tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].option.count
    }
    
    // cell Return
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = sections[indexPath.section].option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    // selected Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
 
        let model = sections[indexPath.section].option[indexPath.row]
        model.handler()
    }
    
    // header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
}
