//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/13.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    // MARK: - Components
    
    // artworkURL
    private let albumCoverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // trackNameLabel
    private let trackNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // artistNameLabel
    private let artistNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
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
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        // SuperView 밖으로 넘어가는 subview는 잘릴 수 있음
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // playlistCoverImageView
        albumCoverImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            albumCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumCoverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0),
            albumCoverImageView.widthAnchor.constraint(equalTo: albumCoverImageView.heightAnchor, multiplier: 1.0),
        ])
        
        // trackNameLabel
        NSLayoutConstraint.activate([
            trackNameLabel.topAnchor.constraint(equalTo: albumCoverImageView.topAnchor, constant: 5),
            trackNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 10),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // artistNameLabel
        NSLayoutConstraint.activate([
            artistNameLabel.topAnchor.constraint(greaterThanOrEqualTo: trackNameLabel.bottomAnchor, constant: 5),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            artistNameLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumCoverImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    // MARK: - Configure
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        albumCoverImageView.kf.setImage(with: viewModel.artworkURL)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
