//
//  PlayerControlsView.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/07/20.
//

import Foundation
import UIKit

// Delegate protocol
protocol PlayerControlsViewDelegate: AnyObject {
    func playControlsViewDidTapPlayPause(_ playerControlsView: PlayerControlsView)
    func playControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
    func playControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

class PlayerControlsView: UIView {
    
    // flag
    private var isPlaying: Bool = true
    
    // delegate
    weak var delegate: PlayerControlsViewDelegate?
    
    // MARK: - Components (Label & Slider & Buttons)
    
    // Stack view with full components
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // StackView (with labels)
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // trackNameLabel
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.text = "TrackName"
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()
    
    // artistNameLabel
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.sizeToFit()
        label.text = "ArtistName"
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()
    
    
    // Slider
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        
        // slider Common Layout
        slider.minimumTrackTintColor = .label
        slider.maximumTrackTintColor = .secondaryLabel
        
        slider.thumbTintColor = .label
        return slider
    }()
    
    // StackView (with buttons)
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Play & Pause
    // TODO: - 동일한 속성을 하나의 메서드로 정의해서 뿌리기
    // pause.fill (pause image)
    private let playAndPauseButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .label
        return button
    }()
    
    // BackwardButton
    private let backwardsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "backward.end.fill")
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .label
        return button
    }()
    
    // forwardsButton
    private let forwardsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "forward.end.fill")
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .label
        return button
    }()
    
    // shuffleButton
    private let shuffleButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "shuffle")
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .label
        return button
    }()
    
    // repeatButton
    private let repeatButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "repeat")
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .label
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        verticalStackView.addArrangedSubview(labelStackView)
        verticalStackView.addArrangedSubview(volumeSlider)
        verticalStackView.addArrangedSubview(buttonStackView)
        addSubview(verticalStackView)
        
        labelStackView.addArrangedSubview(trackNameLabel)
        labelStackView.addArrangedSubview(artistNameLabel)
        
        // Slider Action
        volumeSlider.addTarget(
            self,
            action: #selector(didSlideSlider),
            for: .valueChanged
        )

        // Buttons
        buttonStackView.addArrangedSubview(shuffleButton)
        buttonStackView.addArrangedSubview(backwardsButton)
        buttonStackView.addArrangedSubview(playAndPauseButton)
        buttonStackView.addArrangedSubview(forwardsButton)
        buttonStackView.addArrangedSubview(repeatButton)
        
        // MARK: - Buttons Action
        backwardsButton.addTarget(
            self,
            action: #selector(didTapBackward),
            for: .touchUpInside
        )
        
        forwardsButton.addTarget(
            self,
            action: #selector(didTapForward),
            for: .touchUpInside
        )
        
        playAndPauseButton.addTarget(
            self,
            action: #selector(didTapPlayPause),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout setting
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // veticalStackView
        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    
    // MARK: - Configure
    func configure(with viewModel: PlayerControlsViewViewModel) {
        trackNameLabel.text = viewModel.title
        artistNameLabel.text = viewModel.subtitle
    }
    
    // MARK: - Components(Slider, Button) Action
    
    // slider
    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        delegate?.playControlsView(
            self, didSlideSlider: value
        )
    }
    
    // backward button
    @objc func didTapBackward() {
        delegate?.playControlsViewDidTapBackwardButton(self)
    }
    
    // forward button
    @objc func didTapForward() {
        delegate?.playControlsViewDidTapForwardButton(self)
    }
    
    // PlayPause button
    @objc func didTapPlayPause() {
        delegate?.playControlsViewDidTapPlayPause(self)
        self.isPlaying = !isPlaying
        
        // Button icon Configuration
        let pause = UIImage(systemName: "pause.circle",
                            withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))
        
        let play = UIImage(systemName: "play.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))
        
        // Updata icon
        playAndPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
}
