//
//  HapticManager.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() { }
    
    // select for vibrate
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    // vibrate type
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare() // 준비하고
            generator.notificationOccurred(type)
        }
    }
}
