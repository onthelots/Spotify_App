//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import UIKit
import Kingfisher

// TODO: - PlaylistHeader의 배경색 넣기 (Album cover Image에서 자주 사용되는 색상을 ColorPicker를 통해 RGB 값을 받아와, 배경에 뿌려주면 되지 않을까?)

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlxaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    // imageView
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    // nameLabel
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    // descriptionLabel
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    // ownerLabel
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()
    
    // PlayAllButton
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(textStyle: .body)
        )
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self,
                                action: #selector(didTapPlayAll),
                                for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)
        ])
        
        // nameLabel
        nameLabel.sizeToFit()
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        // DescriptionLabel
        descriptionLabel.sizeToFit()
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
        
        // ownerLabel
        ownerLabel.sizeToFit()
        NSLayoutConstraint.activate([
            ownerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            ownerLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            ownerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
        ])

        // playAllButton
        playAllButton.frame.size = CGSize(width: 50, height: 50)
        NSLayoutConstraint.activate([
            playAllButton.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor),
            playAllButton.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            playAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 재사용 되기전에 초기화
        imageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        ownerLabel.text = nil
    }
    
    func configure(with viewModel: PlaylistHeaderViewModel) {
        nameLabel.text = viewModel.playlistName
        descriptionLabel.text = viewModel.description
        ownerLabel.text = viewModel.ownerName
        imageView.kf.setImage(with: viewModel.artworkURL, placeholder: UIImage(systemName: "photo"))
    }
    
    // 해당 VC로 위임함
    @objc private func didTapPlayAll() {
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
}
