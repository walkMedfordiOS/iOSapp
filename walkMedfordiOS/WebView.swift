//
//  WebView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/29/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController, WKNavigationDelegate {
    
    // Variable for WebView
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var website: String = "https://www.walkmedford.org"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: website)
        let request = URLRequest(url: url!)
        webView.load(request)
        webView.navigationDelegate = self
        
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
    
    /*
     Purpose: To dismiss page when back button is pressed
     Notes:
     */
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
