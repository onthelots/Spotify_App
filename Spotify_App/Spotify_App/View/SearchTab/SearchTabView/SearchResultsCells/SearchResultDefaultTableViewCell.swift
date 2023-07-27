//
//  SearchResultDefaultTableViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import UIKit
import Kingfisher


class SearchResultDefaultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultDefaultTableViewCell"
    
    // MARK: - Components
    // label
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    // imageView
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator // DisclosureIndicator -> Chevron shape
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // iconImageView Layout
        iconImageView.layer.cornerRadius = iconImageView.height/2
        iconImageView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
        
        // label Layout
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
    }

    // MARK: - Configure
    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageView.kf.setImage(with: viewModel.imageURL ?? nil)
    }
}
