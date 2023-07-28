//
//  NewReleaseCollectionViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/13.
//

import UIKit
import Kingfisher

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    // MARK: - Components
    
    // albumCoverImage
    private let albumCoverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // albumLabel
    private let albumLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // artistNameLabel
    private let artistNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // numberOfTracksLabel
    private let numberOfTracksLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        
        // addSubview(components)
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // AlbumCoverImageView
        NSLayoutConstraint.activate([
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumCoverImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.35),
            albumCoverImageView.heightAnchor.constraint(equalTo: albumCoverImageView.widthAnchor, multiplier: 1.0)
        ])
        
        // albumLabel
        albumLabel.sizeToFit()
        albumLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        albumLabel.setContentHuggingPriority(.defaultLow, for: .vertical) // 길어지게 되면, 늘어날 수 있도록

        NSLayoutConstraint.activate([
            albumLabel.topAnchor.constraint(equalTo: albumCoverImageView.topAnchor),
            albumLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 10),
            albumLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // artistNameLabel
        artistNameLabel.sizeToFit()
        artistNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            artistNameLabel.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 5),
            artistNameLabel.leadingAnchor.constraint(equalTo: albumLabel.leadingAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: albumLabel.trailingAnchor)
        ])
        
        // numberOfTracksLabel
        numberOfTracksLabel.sizeToFit()
        numberOfTracksLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            numberOfTracksLabel.topAnchor.constraint(greaterThanOrEqualTo: artistNameLabel.bottomAnchor, constant: 10),
            numberOfTracksLabel.bottomAnchor.constraint(equalTo: albumCoverImageView.bottomAnchor),
            numberOfTracksLabel.leadingAnchor.constraint(equalTo: albumLabel.leadingAnchor),
            numberOfTracksLabel.trailingAnchor.constraint(equalTo: albumLabel.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        albumCoverImageView.image = nil
        albumLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
    }
    
    // MARK: - Configure
    func configure(with viewModel: NewReleasesCellViewModel) {
        albumCoverImageView.kf.setImage(with: viewModel.artworkURL)
        albumLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks : \(viewModel.numberOfTracks)"
    }
}
