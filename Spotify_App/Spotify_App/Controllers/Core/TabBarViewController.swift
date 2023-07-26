//
//  TabBarViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 각각의 TabBar를 담당할 VC를 선언하고
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        // VC의 타이틀(혹은 NavigationTitle)을 설정
        vc1.title = "Home"
        vc2.title = "Search"
        vc3.title = "Library"
        
        // NavigationTitle을 Large 타입으로 설정 (always)
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        // 각각의 Core VC를 담당하는 NavigationController를 선언
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        // TabBar의 타이틀, 이미지, 태그('몇번째 탭바가 선택되었는가?')를 설정
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        // 각각의 NavigationController의 LargeTitle을 모두 true 값으로 선언함
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        // 각각의 NavigationBar의 색상을 변경하기 (Dark / Light => SystemColor에 맞도록(label))
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        // 순서대로, 각각의 NavigationController를 배열에 담아냄 -> 즉, TabBar 왼쪽부터 순서대로 나열
        setViewControllers([nav1, nav2, nav3], animated: false)
    }
}
