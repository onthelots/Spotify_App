//
//  ActionLabelView.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/25.
//

import UIKit

struct ActionLabelViewModel {
    let text: String
    let actionTitle: String
}

protocol ActionLabelVieweDelegate: AnyObject {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
}

class ActionLabelView: UIView {
    
    weak var delegate: ActionLabelVieweDelegate?
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.sizeToFit()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.link, for: .normal)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        // 조건에 따라 View가 나타나기 위해 isHidden true 값으로 설정
        isHidden = true
        // addSubviews
        
        verticalStackView.addArrangedSubview(label)
        verticalStackView.addArrangedSubview(button)
        addSubview(verticalStackView)
        
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.verticalStackView.addArrangedSubview(label)
        self.verticalStackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    
    @objc func didTapButton() {
        delegate?.actionLabelViewDidTapButton(self)
        print("버튼이 눌렸습니다")
    }
    
    func configure(with viewModel: ActionLabelViewModel) {
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
