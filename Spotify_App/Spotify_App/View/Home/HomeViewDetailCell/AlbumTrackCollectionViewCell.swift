//
//  AlbumTrackCollectionViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/17.
//

import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"
    
    // Component 1. StackView (Verical)
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
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
        contentView.addSubview(verticalStackView)
        
        // SuperView 밖으로 넘어가는 subview는 잘릴 수 있음
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // SubView Layout 설정
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // stackView
        verticalStackView.addArrangedSubview(trackNameLabel)
        verticalStackView.addArrangedSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            verticalStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        // 재사용 되기전에 초기화
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    // 각각의 컴포넌트에 RecommendedTrackCellViewModel 타입의 데이터를 매개변수값으로 할당함
    func configure(with viewModel: AlbumCollectionViewCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
