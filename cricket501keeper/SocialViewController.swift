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
    func addUserToGame(_ user:PFUser)
}

class SocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SocialCellDelegate, SearchCellDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var friendsTable: UITableView!
    var currentUser:PFUser?
    var friendsList:Array<String>?
    var searchList:Array<String>?
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var userLabel: UILabel!
    var refreshControl:UIRefreshControl?
    @IBOutlet weak var signOutButton: UIButton!
    var gameController:FriendsListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard PFUser.current() != nil else{
            print("there is no Current User (SocialVC)")
            return
        }
        self.refreshControl = UIRefreshControl()
        let main_string = "Pull to Refresh"
        let string_to_color = "Pull to Refresh"
        let range = (main_string as NSString).range(of: string_to_color)
        let attributedString = NSMutableAttributedString(string:main_string)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white , range: range)
        
        self.refreshControl?.attributedTitle = attributedString
        self.refreshControl?.addTarget(self, action: #selector(SocialViewController.refreshTableView(_:)), for: UIControlEvents.valueChanged)
        self.friendsTable?.addSubview(refreshControl!)
        
        
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
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
                print("failed to Add opponent (SocialVC)")
            } else {
                print("Added Opp (socialVC)")
                self.gameController?.addUserToGame(objects?.last as! PFUser)
            }
        })
    }
    
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.searchTable else {
            // is the friends Table
            
            let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
            guard cell.select != false else {
                tableView.deselectRow(at: indexPath, animated: false)
                return
            }
            cell.setSelected(true, animated: false)
            return
        }
        // is the search table
        let cell = tableView.cellForRow(at: indexPath) as! SearchTableViewCell
        guard cell.select != false else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        cell.setSelected(true, animated: false)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView == self.searchTable else {
            // is the friends Table
            let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
            cell.setSelected(false, animated: false)
            return
        }
        // is the search table
        let cell = tableView.cellForRow(at: indexPath) as! SearchTableViewCell
        cell.setSelected(false, animated: false)
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
    func refreshTableView(_ sender:Any) {
        self.currentUser?.fetchInBackground()
        self.friendsList = self.currentUser?.object(forKey: "friendsList") as? Array<String>
        self.friendsTable.reloadData()
        self.refreshControl?.endRefreshing()
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard tableView == self.searchTable else {
            return "Friends"
        }
        guard (self.searchField.text?.isEmpty)! else {
            return "Search Results"
        }
        return ""
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
