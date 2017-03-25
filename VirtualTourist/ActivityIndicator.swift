//
//  ActivityIndicator.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/24/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import UIKit

// MARK: - ActivityIndicator

class ActivityIndicator {
    
    private var container = UIView()
    private var loadingView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    func startActivityIndicator(inView hostView: UIView) {
        
        container.tag = 100
        container.frame = hostView.frame
        container.center = hostView.center
        container.backgroundColor = UIColor(red: 0.77, green: 0.75, blue: 0.75, alpha: 0.6)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = hostView.center
        loadingView.backgroundColor = UIColor(red: 0.77, green: 0.75, blue: 0.75, alpha: 0.9)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        activityIndicator.startAnimating()
        hostView.addSubview(container)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator(inView hostView: UIView) {
        activityIndicator.stopAnimating()
        hostView.viewWithTag(100)?.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ActivityIndicator {
        struct Singleton {
            static var sharedInstance = ActivityIndicator()
        }
        return Singleton.sharedInstance
    }
}
