//
//  SceneDelegate.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // windowScene -> Optional Binding
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // window 임의 상수는 UIWindow 타입이며, 화면을 나타내는 Scene으로 앞서 바인딩 한 windowScene을 할당함
        let window = UIWindow(windowScene: windowScene)
        
        // 📲 AuthManager (SingIn의 여부 확인)
        // SignedIn이 true일 경우 -> AppDelegate 상에서 TabBarVC 창 (전체 Scene을 확인)으로
        if AuthManager.shared.isSignedIn {
            window.rootViewController = TabBarViewController()
        } else {
            // 그렇지 않다면, NavigationController에서의 WelcomeVC을 나타냄
            let navVC = UINavigationController(rootViewController: WelcomeViewController())
            navVC.navigationBar.prefersLargeTitles = true
            
            // ⁉️ Navigation controller 는 여러개의 vc를 관리하는 컨테이너 형태의 배열임(pop, push가 가능함)
            // 따라서, NavigationController의 첫번째 vc인 WelcomeVC를 나타내기 위해 .first를 사용함
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            window.rootViewController = navVC
        }
        
        //  🟢 rootViewController(이를 관리하는 루트 ViewController) -> TabBar가 포함될 것이므로, 해당 VC를 루트뷰로 설정함
//        window.rootViewController = TabBarViewController()
        
        window.makeKeyAndVisible()
        // AppDelegate의 변수 window의 값으로, 앞서 선언한 window를 할당함
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

