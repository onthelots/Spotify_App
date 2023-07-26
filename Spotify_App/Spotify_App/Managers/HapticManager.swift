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
    
    // 선택에 따른 진동
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare() // 준비하고
            generator.selectionChanged() // 셀렉션을 변경한다?
        }
    }
    
    // 진동효과
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare() // 준비하고
            generator.notificationOccurred(type) // 타입에 따라 알림
        }
    }
}
