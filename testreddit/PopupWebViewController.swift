//
//  PopupWebViewController.swift
//  
//
//  Created by Alexander on 7/3/17.
//
//

import UIKit

class PopupWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    /// Defines whether the view is currently shown.
    var isShown = false
    
    /// Url to be loaded in a web view.
    var urlString: String?
   
    @IBOutlet weak var close: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        close.layer.cornerRadius = 10
        self.showAnimate()
        if let url = URL(string: urlString!) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closePopup(_ sender: UIButton) {
        self.removeAnimate()
    }
    
    //MARK: - Animation
    func showAnimate() {
        isShown = true
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        isShown = false
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }

}
