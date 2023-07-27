//
//  SearchResultSubtitleTableViewCell.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import UIKit
import Kingfisher

class SearchResultSubtitleTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    // stackView (labels)
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
    
    // subtitleLabel
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.sizeToFit()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()
    
    // imageView
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(verticalStackView)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        
        // Cell의 부가적인 기능 (기본적으로 오른쪽에 위치)
        // DisclosureIndicator -> 세브론 모양(화살표)의 액세서리
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // stackView addarranged Views
        verticalStackView.addArrangedSubview(label)
        verticalStackView.addArrangedSubview(subtitleLabel)
        
        // iconImageView
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
        
        // StackView
        NSLayoutConstraint.activate([
            verticalStackView.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        subtitleLabel.text = nil
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.kf.setImage(with: viewModel.imageURL ?? nil, placeholder: UIImage(systemName: "photo"))
    }
}
