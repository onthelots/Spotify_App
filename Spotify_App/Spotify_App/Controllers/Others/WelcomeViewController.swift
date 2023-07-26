//
//  WelcomeViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class WelcomeViewController: UIViewController {
    
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
    
    // label
    private let label: UILabel = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        title = "Spotify"
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(label)
        view.addSubview(iconImageView)
        view.addSubview(signInButton)
        
        // addTarget을 통해 signInButton이 클릭(TouchUpInside)되었을 때 didTapSignIn 메서드를 실행(#selector)
        signInButton.addTarget(self,
                               action: #selector(didTapSignIn),
                               for: .touchUpInside)
    }
    
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
            iconImageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20),
        ])
        
        // label
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
        ])
        
        // signInButton
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // [Method] SignIn을 클릭할 경우
    @objc func didTapSignIn() {
        let vc = AuthViewController()
        
        // SignIn 버튼을 누른 이후 작업해야 할 사항이며, success란 인자를 활용 -> 비동기 처리를 통해 handleSignIn 메서드를 실행시켜줌
        // handleSignIn 메서드 또한 Success란 매개변수를 가지고 있으며, 내부로직에서 true 혹은 false 작업을 비동기 적으로 실시하면
        // AuthVC로 넘어가거나, TabBarVC로 넘어가는 방식을 취함
        // [weak self] -> 순환 참조를 방지하기 위해
        
        // MARK: - 비동기 실행 signIn이 완료되고, completionHandler가 success가 될 경우 ->     84번줄로
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        
        // AuthViewController의 largeTitle은 보이지 않게 하며
        vc.navigationItem.largeTitleDisplayMode = .never
        
        // AuthViewController 화면으로 이동시킴
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        // 로그인 되거나, 그렇지 않아서 오류를 보여주거나
        guard success else {
            // 실패하면 알림을 띄어주자
            let alert = UIAlertController(title: "Oops",
                                          message: "Something went wrong when signing in.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let mainAppTabBarVC = TabBarViewController()
        
        // 아예 뒤로(WelcomeHome) 갈 수 없도록 fullScreen의 모달형식을 띄어버림
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        
        // mainAppTabBarVC인 TabBarViewController(Core)로 이동
        present(mainAppTabBarVC, animated: true)
    }
}
