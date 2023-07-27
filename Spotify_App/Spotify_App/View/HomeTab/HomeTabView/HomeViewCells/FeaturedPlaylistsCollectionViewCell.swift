//
//  FeaturedPlaylistsCollectionViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/13.
//

import UIKit

class FeaturedPlaylistsCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistsCollectionViewCell"
    
    // MARK: - Components
    // albumCoverImage
    private let playlistCoverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // albumLabel + TextStyle (for dynamic type)
    private let playlistNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // playlistCoverImageView
        playlistCoverImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            playlistCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playlistCoverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playlistCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playlistCoverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        // playlistNameLabel
        NSLayoutConstraint.activate([
            playlistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            playlistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            playlistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playlistCoverImageView.image = nil
        playlistNameLabel.text = nil
    }
    
    // MARK: - Configure
    func configure(with viewModel: FeaturedPlaylistsCellViewModel) {
        playlistCoverImageView.kf.setImage(with: viewModel.artworkURL)
        playlistNameLabel.text = viewModel.name
    }
}
