//
//  WelcomeViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: Components
    
    // background ImageView
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "artist_background")
        return imageView
    }()
    
    // signInButton
    private let signInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 20
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setTitle("로그인하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    //overlayView
    private let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.8
        return view
    }()
    
    // Spotify logo ImageView
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_white")
        return imageView
    }()
    
    // introductionLabel
    private let introductionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.sizeToFit()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "글로벌 음악 앱 Spotify와 함께 \n내 마음에 꼭 드는 플레이리스트를 발견하세요"
        let labelString = NSMutableAttributedString(string: label.text!)
        let paragrphStyle = NSMutableParagraphStyle()
        paragrphStyle.lineSpacing = 5
        labelString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragrphStyle,
            range: NSMakeRange(0, labelString.length)
        )
        return label
    }()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Spotify"
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(introductionLabel)
        view.addSubview(iconImageView)
        view.addSubview(signInButton)
        
        // Action (didTapSignIn)
        signInButton.addTarget(self,
                               action: #selector(didTapSignIn),
                               for: .touchUpInside)
    }
    
    // MARK: - Layout SubViews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeArea = view.safeAreaLayoutGuide
        
        // backgroundImageView
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        // overlayView
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            overlayView.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            overlayView.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor)
        ])
        
        // iconImageView
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.bottomAnchor.constraint(equalTo: introductionLabel.topAnchor, constant: -20),
        ])
        
        // label
        NSLayoutConstraint.activate([
            introductionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            introductionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            introductionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            introductionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
        ])
        
        // signInButton
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func didTapSignIn() {
        let vc = AuthViewController()
        // Go to Login View
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
    }
    
    // MARK: - Branching by successful login
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops",
                                          message: "Something went wrong when signing in.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        // go to TabBarViewController
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}
