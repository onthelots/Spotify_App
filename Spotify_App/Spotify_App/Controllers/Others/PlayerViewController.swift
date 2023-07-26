//
//  PlayerViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import Kingfisher

protocol PlayerControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapFoward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    
    // 5️⃣ MARK: - dataSource (playerDataSource protocol object)
    weak var dataSource: PlayerDataSource?
    
    weak var delegate: PlayerControllerDelegate?
    
    // imageView
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // controlsView
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        
        // delegate pattern
        controlsView.delegate = self
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        // NavigationBarButton configure
        configureBarButton()
        
        // configure playerDataSource (dataSource에 데이터를 할당)
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeArea = view.safeAreaLayoutGuide
        // imageView
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // controllsView
        NSLayoutConstraint.activate([
            controlsView.widthAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 1.0),
//            controlsView.heightAnchor.cons
            controlsView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20),
            // MARK: - PlayerControlsView 임의 크기 (아래 추가적인 정보를 담는 View만큼의 크기를 남김)
            controlsView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100),
            controlsView.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor)
        ])
        
    }
    
    // NavigationBarButton setting(configure)
    private func configureBarButton() {
        // leftBarButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"),
            style: .done,
            target: self,
            action: #selector(didTapClose)
        )
        
        // rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .done,
            target: self,
            action: #selector(didTapAction)
        )
        
        // Bar Item Color
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    // 6️⃣ configure playerDataSource (dataSource에 데이터를 할당)
    // 여기서는 imageView 밖엔 없으니, 해당 ImageView에 dataSource.url을 할당
    private func configure() {
        // imageView
        imageView.kf.setImage(with: dataSource?.imageURL)
        
        // controlsView
        controlsView.configure(
            with: PlayerControlsViewViewModel(
                title: dataSource?.songName,
                subtitle: dataSource?.subtitle)
        )
    }
    
    // MARK: - Action
    // dismiss (LeftBarButtonItem)
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    // action (LeftBarButtonItem)
    @objc private func didTapAction() {
        // Actions -> Share
    }
    
    // 다음 버튼, 뒤로 버튼이 눌렸을 경우 configure을 재 실시함
    func refreshUI() {
        configure()
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapFoward()
    }
    
    func playControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}
