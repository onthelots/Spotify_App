//
//  PlayerViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import Kingfisher

// Delegate protocol(configure Action in PlayBackPresenter)
protocol PlayerControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapFoward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    
    weak var dataSource: PlayerDataSource?
    
    // songName, subtitle, imageURL..
    weak var delegate: PlayerControllerDelegate?
    
    // MARK: - Components
    
    // imageView
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // controlsView
    private let controlsView = PlayerControlsView()
    
    
    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        
        // delegate pattern
        controlsView.delegate = self
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        
        configureBarButton()
        configure()
    }
    
    // MARK: - Layout SubView
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
            controlsView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20),
            controlsView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100),
            controlsView.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor)
        ])
        
    }
    
    // MARK: - NavigationBarButton setting(configure)
    private func configureBarButton() {
        // leftBarButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"),
            style: .done,
            target: self,
            action: #selector(didTapClose)
        )
        
        // Bar Item Color
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    // MARK: - Configure Data
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
    
    // refresh Data (in PlayBackPresenter, with Action)
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
