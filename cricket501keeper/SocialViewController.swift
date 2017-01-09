//
//  SocialViewController.swift
//
//
//  Created by Matthew Mauro on 2016-12-29.
//
//

import UIKit
import Parse

//MARK: - FriendsList Protocol

protocol FriendsListDelegate {
    
    func addUserToGame(_user:PFUser)
    func moveSocialView(view:SocialViewController)
}

class SocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var searchTable: UITableView!
    var currentUser:PFUser?
    var friendsList:Array<String>?
    var searchList:Array<String>?
    @IBOutlet weak var searchField: UITextField!
    
    public var position:Bool?
    var gameController:FriendsListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard PFUser.current() != nil else {
            print("there is no Current User")
            return
        }
        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self
        self.searchTable.dataSource = self
        self.searchTable.delegate = self
        self.position = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUser = PFUser.current()
        self.friendsList = self.currentUser?.value(forKey: "friendsList") as? Array
    }
    
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
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.searchTable {
            var array = self.currentUser?.value(forKey: "friendsList") as? Array<String>
            let newFriend = self.searchList?[indexPath.row]
            array?.append(newFriend! as String)
            self.currentUser?.setValue(array, forKey: "friendsList")
            currentUser?.saveInBackground()
            self.friendsTable.reloadData()
        }else{
            let cell = tableView.cellForRow(at: indexPath)
            guard cell?.isHighlighted == true else {
                
                // unselect rows
                let totalRows = tableView.numberOfRows(inSection: 0)
                for row in 0 ..< totalRows {
                    let index = IndexPath(row: row, section: 0)
                    tableView.deselectRow(at: index, animated: false)
                }
                //highlight Cell
                cell?.backgroundColor = UIColor.green
                cell?.isHighlighted = true
                return
            }
            // add User as player against you in game
            let query = PFUser.query()
            query?.whereKey("username", equalTo: (self.friendsList?[indexPath.row])!)
            query?.findObjectsInBackground(block: { (objects, error) in
                guard objects != nil else {
                    if (error != nil) {
                        print(error!.localizedDescription)
                    }
                    return
                }
                let user = objects?.first as! PFUser
                self.gameController?.addUserToGame(_user: user)
            })
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    func configureCell(_name:String) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = _name
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var title:String?
        if tableView == self.searchTable {
            title = self.searchList?[indexPath.row]
        }else{
            title = self.friendsList?[indexPath.row]
        }
        return configureCell(_name: title!)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.friendsTable {
            let count:Int? = (self.friendsList?.count)
            if count == nil {
                return 0
            }else{
                return count!
            }
        }else{
            let count:Int? = (self.searchList?.count)!
            if count == nil {
                return 0
            }else{
                return count!
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
