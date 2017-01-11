//
//  AppDelegate.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-22.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit

import Parse
import SwiftKeychainWrapper
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var currentUser:PFUser?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let config = ParseClientConfiguration { (config) in
            config.applicationId = "cricket501Keeper"
            config.server = "http://cricket501keeper.herokuapp.com/parse"
            config.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: config)
        self.currentUser = PFUser.current()
        
        let rootView = self.window!.rootViewController as! RootViewController
        
        if self.currentUser == nil {
            rootView.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
            rootView.openDrawerGestureModeMask = MMOpenDrawerGestureMode.all
            rootView.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
        } else {
            let mainScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreen") as! ViewController
            let social = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "socialView") as! SocialViewController
            social.gameController = mainScreen
            rootView.leftDrawerViewController = social
            rootView.centerViewController = mainScreen
            rootView.openDrawerGestureModeMask = MMOpenDrawerGestureMode.all
            rootView.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

