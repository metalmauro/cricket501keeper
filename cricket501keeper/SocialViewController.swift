//
//  SocialViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-09.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

//MARK: - FriendsList Protocol
protocol FriendsListDelegate {
    func addUserToGame(_user:PFUser)
}

class SocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SocialCellDelegate, SeachCellDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var friendsTable: UITableView!
    var currentUser:PFUser?
    var friendsList:Array<String>?
    var searchList:Array<String>?
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    var gameController:FriendsListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard PFUser.current() != nil else{
            print("there is no Current User (SocialVC)")
            return
        }
        self.currentUser = PFUser.current()
        self.friendsList = self.currentUser?.value(forKey: "friendsList") as? Array
        self.searchList = [""]
        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self
        self.searchTable.dataSource = self
        self.searchTable.delegate = self
        self.userLabel.text = self.currentUser?.username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard PFUser.current() != nil else{
            print("there is no Current User (SocialVC)")
            return
        }
        self.currentUser = PFUser.current()
        self.friendsList = self.currentUser?.value(forKey: "friendsList") as? Array
    }
    //MARK: - Search for User
    @IBAction func search(_ sender: Any) {
        let query:PFQuery = PFUser.query()!
        query.whereKey("username", contains: self.searchField.text)
        query.findObjectsInBackground { (objects, error) in
            guard objects != nil else {
                if (error != nil) {
                    print(error!.localizedDescription)
                }
                return
            }
            for index in 0...(objects?.count)! {
                let user = objects?[index] as! PFUser
                self.searchList?.append((user.username)! as String)
            }
        }
    }
    @IBAction func signOut(_ sender: Any) {
        PFUser.logOut()
        let rootV = UIApplication.shared.keyWindow?.rootViewController as! RootViewController
        rootV.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! ViewController
        rootV.reloadInputViews()
    }
    //MARK: - Cell functionality
    func addFriend(_ username:String) {
        self.friendsList?.append(username)
        self.currentUser?["friendsList"] = self.friendsList
        self.currentUser?.saveInBackground()
    }
    func addOpponent(_ username:String) {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        let user = try? query?.getFirstObject() as! PFUser
        self.gameController?.addUserToGame(_user: user!)
    }
    
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.searchTable else {
            // is the friends Table
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
            cell.setSelected(true, animated: false)
            return
        }
        // is the search table
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.setSelected(true, animated: false)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        cell.isSelected = false
    }
    //MARK: - Configure Cell
    func configureCell(_ name:String, _ tableView:UITableView) -> UITableViewCell {
        guard tableView != self.searchTable else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
            cell.configureSelf(name)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UserTableViewCell
        cell.configureSelf(name)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var title:String?
        guard tableView != self.searchTable else {
            
            title = (self.searchList?[indexPath.row])! as String?
            return configureCell(title!, tableView)
        }
        if self.friendsList?.count == nil {
            title = "Add More Friends"
        } else {
            title = (self.friendsList?[indexPath.row])! as String?
        }
        return configureCell(title!, tableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView != self.friendsTable else {
            let count:Int? = (self.friendsList?.count)
            guard count != nil else {
                return 1
            }
            return count! as Int
        }
        let count:Int? = (self.searchList?.count)
        guard count != nil else {
            return 0
        }
        return count! as Int
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard tableView == friendsTable else {
            if (self.searchField.text?.isEmpty)! {
                return [""]
            } else {
                return ["Results"]
            }
        }
        return ["Friends"]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: - TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
