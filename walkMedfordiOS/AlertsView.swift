//
//  AlertsView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/14/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import WebKit

class AlertsView: UIViewController {
    
    // Variable for webView
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string:"https://www.medfordma.org/2018/12/04/reminder-snow-removal-regulations/")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
}
