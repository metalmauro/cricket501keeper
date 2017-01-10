//
//  RootViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-09.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import MMDrawerController
import Parse

class RootViewController: MMDrawerController, LoginDelegate {

    var currentUser:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUser = PFUser.current()
        if self.currentUser == nil {
            let login:LoginViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController)
            self.centerViewController = login
        } 
    }
    func switchSideViews() {
        self.currentUser = PFUser.current()
        if self.currentUser == nil {
            let login:LoginViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController)
            self.centerViewController = login
        } else {
            let mainScreen:ViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreen") as! ViewController)
            let socialView:SocialViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "socialView") as! SocialViewController)
            self.centerViewController = mainScreen
            self.leftDrawerViewController = socialView
        }
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        let mySocial: SocialViewController!
//        let vc: ViewController!
//        
//        if segue.identifier == "mm_left" {
//            mySocial = segue.destination as! SocialViewController
//        }
//        if segue.identifier == "mm_center" {
//            vc = segue.destination as! ViewController
//        }
//        
//        
//    }
}
