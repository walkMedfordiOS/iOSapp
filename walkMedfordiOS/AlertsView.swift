//
//  AlertsView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/14/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import WebKit

class AlertsView: UIViewController, WKNavigationDelegate {
    
    // Variable for webView
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string:"https://www.medfordma.org/2018/12/04/reminder-snow-removal-regulations/")
        let request = URLRequest(url: url!)
        webView.load(request)
        webView.navigationDelegate = self
        
        // Add activity
        activity.startAnimating()
        activity.hidesWhenStopped = true
    }
    
    /*
     Purpose: To stop web activity indicator when finished
     Notes:
    */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
    }
    
    /*
     Purpose: To stop web activity indicator if failed
     Notes:
     */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activity.stopAnimating()
    }
}
