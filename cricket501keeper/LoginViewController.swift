//
//  LoginViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-28.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Parse

protocol LoginDelegate {
    func switchSideViews()
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var delegate:LoginDelegate?
    var segmentIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentIndex = 0
        self.segmentConfigure()
        
        let keychainUser:String? = KeychainWrapper.standard.string(forKey: "user")
        let keychainPassword:String? = KeychainWrapper.standard.string(forKey: "password")
        
        self.usernameField.text = keychainUser
        self.passwordField.text = keychainPassword
        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    func segmentConfigure() {
        switch self.segmentIndex!
        {
        case 0:
            self.emailField.isHidden = true
            self.emailLabel.isHidden = true
            self.logButton.titleLabel?.text = "Log In"
            break
        case 1:
            self.emailField.isHidden = false
            self.emailLabel.isHidden = false
            self.emailLabel.text = "email"
            self.logButton.titleLabel!.text = "Sign Up"
            break
        default:
            break
        }
    }
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        self.segmentIndex = self.segmentedControl.selectedSegmentIndex
        self.segmentConfigure()
    }
    @IBAction func buttonAction(_ sender: Any) {
        guard (self.usernameField.text?.isEqual(""))! || (self.passwordField.text?.isEqual(""))! else {
            //test has failed
            switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                // Log In
                self.signInUser((self.usernameField.text)!,
                                password: (self.passwordField.text)!)
                break
            case 1:
                // Sign Up
                self.makeNewUser((self.usernameField.text)!,
                                 email: (self.emailField.text)!,
                                 password: (self.passwordField.text)!)
                break
            default:
                break
            }
            return
        }
        if (self.usernameField.text?.isEqual(""))! {
            self.usernameField.tintColor = UIColor.red
            self.usernameField.placeholder = "this space is required"
        }
        if (self.passwordField.text?.isEqual(""))! {
            self.passwordField.tintColor = UIColor.red
            self.passwordField.placeholder = "this space is required"
        }
    }
    
    //MARK: - Make New Parse User
    func makeNewUser(_ name:String, email:String, password:String){
        let newUser = PFUser()
        newUser.username = name
        newUser.email = email
        let has = "saf8198538906passw".hashValue
        newUser.password = String(format: "%d%d", has.hashValue, password.hashValue)
        newUser.setValue(["spidermatt"], forKey: "friendsList")
        let local = PFObject(className: "localOpp")
        local["username"] = "Opponent"
        newUser["locals"] = local
        newUser.signUpInBackground { (success, error) in
            if let error = error {
                let errorString = error.localizedDescription as String
                print(errorString)
                // Show the errorString somewhere and let the user try again.
            } else {
                // Hooray! Let them use the app now.
                // Make main viewController the new screen
                print("Sign Up succeeded")
                
                // add user to the keychain
                let userKeySuccess: Bool = KeychainWrapper.standard.set(newUser.username!, forKey: "user")
                let passWKeySuccess:Bool = KeychainWrapper.standard.set(password, forKey: "password")
                if userKeySuccess == true && passWKeySuccess == true {
                    print("save to keychain was successful")
                }
                let rootV = UIApplication.shared.keyWindow?.rootViewController as! RootViewController
                rootV.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                rootV.leftDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "socialView")
                rootV.reloadInputViews()
            }
        }
    }
    func signInUser(_ name:String, password:String){
        let has = "saf8198538906passw".hashValue
        let pass = String(format: "%d%d", has.hashValue, password.hashValue)
        PFUser.logInWithUsername(inBackground: name, password: pass) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Error", message: "couldn't log in, perhaps the username and/or password was wrong? \n But hey, I'm jsut a computer...", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // save to keychain
                let userKeySuccess: Bool = KeychainWrapper.standard.set(name, forKey: "user")
                let passWKeySuccess:Bool = KeychainWrapper.standard.set(password, forKey: "password")
                if userKeySuccess == true && passWKeySuccess == true {
                    print("save to keychain was successful")
                }
                let rootV = UIApplication.shared.keyWindow?.rootViewController as! RootViewController
                rootV.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                rootV.leftDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "socialView") as! SocialViewController
                rootV.reloadInputViews()
            }
        }
    }
    //MARK: - TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
