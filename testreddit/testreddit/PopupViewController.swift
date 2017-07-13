//
//  PopupViewController.swift
//  testreddit
//
//  Created by Anna on 6/26/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

/// A class for image popup controller.
class PopupViewController: UIViewController, UIScrollViewDelegate {
    
    /// Whether the popup is visible at the moment.
    var isShown = false
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    /// A button to close the popup.
    @IBOutlet weak var close: UIButton!
    
    /// A view for image or gif.
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        close.layer.cornerRadius = 10
        self.showAnimate()
        scrollView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imgView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imgView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imgView.bounds.width
        let heightScale = size.height / imgView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
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
