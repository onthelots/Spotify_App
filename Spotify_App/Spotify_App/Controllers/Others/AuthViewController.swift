//
//  AuthViewController.swift
//  Spotify_App
//
//  Created by Jae hyuk Yim on 2023/06/29.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    // WKWebView : 웹 페이지에서 할당하는 메모리는 앱과 '별도의 스레드'에서 관리하는 장점이 있음
    private let webView: WKWebView = {
        
        // WKWebpagePreferences : webView의 기본속성
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        // WKWebViewConfiguration : webView 초기화
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        // webview 생성
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()
    
    // completionHandler -> Auth 과정이 bool타입에 따라 종료되었는지, 그렇지 않은지 작업 이후에 나타내기 위함
    public var completionHandler: ((Bool) -> Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        // 대리자 설정 (webView의 navigation 기능은 AuthViewController가 담당)
        webView.navigationDelegate = self
        
        // Add SubView -> webView
        view.addSubview(webView)
        
        // 하위 뷰(WebView)를 로드함
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    // subView가 호출된 직후에 수행해야 할 레이아웃
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // TODO: - Frame과 bounds 제대로 알아보기
        // webView의 frame, 즉 좌표계를 -> 상위뷰(view)의 bounds와 동일하게 설정함
        // 다시 말해, 하위 뷰(webvView)의 위치와 크기를를 상위뷰(view) 자체의 위치와 크기(좌표 시스템)에 할당함
        // 결국, 하위 뷰 = 상위 뷰는 동일한 위치, 크기, 좌표계를 가지게 됨
        webView.frame = view.bounds
    }
    
    // 웹 컨텐츠가 웹보기로 로드되기 시작할 때 호출되는 메서드
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        // MARK: - Exchange the code for access token
        
        // componet는 일종의 'URL 구조'
        // 1. webView의 url 구조를 Component란 이름으로 가져오고,
        let component = URLComponents(string: url.absoluteString)
        
        // 2. token 승인을 위해 Access Code를 가져올건데, 쿼리 아이템 중 첫번째(이름이 coded인) 값을 value(String)으로 받아옴
        guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else {
            return
        }
        
        // 3. 이후, webView을 일단 숨기고 나서
        webView.isHidden = true
        
        // 4. Code 로그를 확인하고
        print("Code : \(code)")
        
        // 5. Code를 Token으로 교환하는 메서드(exchangeCodeForToken)를 실행
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                // SignIn이 true로 변환되면, rootview인 WelcomeViewController로
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
