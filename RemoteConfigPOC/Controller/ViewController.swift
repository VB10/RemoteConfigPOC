//
//  ViewController.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 6.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import UIKit
import WebKit
import Networking

class ViewController: UIViewController , WKNavigationDelegate {
    let manager = BaseManager.instance
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    @IBAction func refreshPress(_ sender: Any) {
        self.manager.getServiceControl(success: { (result : Bool) in
            switch result {
            case true:
                self.loadWebView()
                break
            case false:
                print("Network Error")
            }

        })
    }
    override func viewDidAppear(_ animated: Bool) {
            // UI Updates here for task complete.
        
        self.manager.getServiceControl(success: { (result : Bool) in
                switch result {
                case true:
                    self.loadWebView()
                    break
                case false:
                    print("Network Error")
                }
            })
        
    }
    
    func loadWebView() {
        let list = manager.db?.getList(with: App.self)
        guard let website = list?[0].website else {
            print("DB is empty")
            return }
        let url = URL(string: website)
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url!))

        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}

