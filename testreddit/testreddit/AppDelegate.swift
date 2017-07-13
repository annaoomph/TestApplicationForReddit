//
//  AppDelegate.swift
//  testreddit
//
//  Created by Anna on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //If the device is iPad, the main controller would be split view controller.
        //Therefore, we need to do additional job to get to the tab view controller.
        if let splitViewController = self.window!.rootViewController as? UISplitViewController {
            splitViewController.preferredDisplayMode = .allVisible
            let masterViewController = splitViewController.viewControllers.first as! UITabBarController
            masterViewController.selectedIndex = PreferenceManager().getLastOpenedTab()
        } else if let tabBarController = self.window!.rootViewController as? UITabBarController {
            //Otherwise, the main view controller would already be the tab view controller.
            tabBarController.selectedIndex = PreferenceManager().getLastOpenedTab()
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //Called when the browser is instructed to redirect to app's registered redirect_uri.
        return Loader.handleAuthorizationResponseWith(url)
    }
}

