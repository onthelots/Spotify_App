//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/13.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    // Component 1. artworkURL
    private let albumCoverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Component 2. trackNameLabel + TextStyle (for dynamic type)
    private let trackNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Component 3. artistNameLabel + TextStyle (for dynamic type)
    private let artistNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // ContentView 기본 Layout 설정
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
    
    // SubView Layout 설정
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
        
        // 재사용 되기전에 초기화
        albumCoverImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    // 각각의 컴포넌트에 RecommendedTrackCellViewModel 타입의 데이터를 매개변수값으로 할당함
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        albumCoverImageView.kf.setImage(with: viewModel.artworkURL)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
