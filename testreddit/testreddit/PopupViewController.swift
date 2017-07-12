//
//  PopupViewController.swift
//  testreddit
//
//  Created by Anna on 6/26/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

/// A class for image popup controller.
class PopupViewController: UIViewController {
    
    /// Whether the popup is visible at the moment.
    var isShown = false
    
    /// A button to close the popup.
    @IBOutlet weak var close: UIButton!
    
    /// A view for image or gif.
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        close.layer.cornerRadius = 10
        self.showAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Close popup
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        self.removeAnimate()
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
