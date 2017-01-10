//
//  ViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-22.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, FriendsListDelegate {
    
    @IBOutlet weak var gameTypeControl: UISegmentedControl!
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var backingImage: UIImageView!
    @IBOutlet weak var playGameButton: UIButton!
    
    var sendingGame:String?
    
    var games:[PFObject]?
    var currentUser:PFUser?
    var opponent:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gamePicker.dataSource = self
        self.gamePicker.delegate = self
        
        self.currentUser = PFUser.current()
        if self.currentUser == nil {
            
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let index = self.gameTypeControl.selectedSegmentIndex
        switch index {
        case 0:
            // make sure Game Type is Cricket
            self.backingImage.image = UIImage(named: "cricketSelect")
            self.gamePicker.reloadAllComponents()
            break
        case 1:
            //make sure GameType is set as 501
            self.backingImage.image = UIImage(named: "501Select")
            self.gamePicker.reloadAllComponents()
            break
        default:
            break
        }
    }
    
    //MARK: - startGame button and Segues
    @IBAction func startGame(_ sender: Any) {
        switch (self.gameTypeControl.selectedSegmentIndex) {
        case 0:
            self.createCricket()
            self.performSegue(withIdentifier: "playGame", sender: self)
            break
        case 1:
            self.create501()
            self.performSegue(withIdentifier: "playGame", sender: self)
            break
        default:
            break
        }
    }
    
    // segue notes: Will send the currentGame's objectId to be saved and easily fetched by the subsequent View Controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pages = segue.destination as! GamePageViewController
        pages.gameQueryInfo = self.sendingGame!
    }
    
    //MARK: - pickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = 1
        let gameRules = self.gameTypeControl.selectedSegmentIndex
        switch gameRules
        {
        case 0:
            self.fetchCricketInformation()
            let gameCount:Int? = (self.games?.count)
            guard gameCount != nil else {
                return 1
            }
            if (gameCount)! > 1 {
                rows = 2
            }
            break
        case 1:
            self.fetch501Information()
            let gameCount:Int? = (self.games?.count)
            guard gameCount != nil else {
                return 1
            }
            if (gameCount)! > 1 {
                rows = 2
            }
            break
        default:
            break
        }
        return rows
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String = ""
        switch row {
        case 0:
            title = "New Game"
            break
        case 1:
            title = "Continue From Last"
            break
        default:
            break
        }
        return title
    }
    
    //MARK: - Friends Delegate
    func addUserToGame(_user: PFUser) {
        self.opponent = _user
    }
    
    //MARK: - Parse Game Creation
    // use note:
    // User will have a friendsList array, to which they will choose a player to play against
    // will ahve to add their friend to the game, and will send a Push Notification out to the opponent to join
    // must simply add points and player values to the game of their choice, and then save the game and move forward
    // current Game will be pinned to the device, allowing for easier reference moving forward
    // subsequent View Controllers will fetch the saved game and then use and save data appropriately
    
    func create501() {
        let newGame = PFObject(className: "Game501")
        newGame["timeStart"] = Date()
        newGame["player"] = self.currentUser
        
        if self.opponent == nil {
            self.makeTempOpponent(newGame)
        }
        newGame["opponent"] = self.opponent
        newGame["turnCounter"] = 0
        
        // device owner points
        let p1Points = PFObject(className: "Pts501")
        self.pointsIteration(p1Points)
        p1Points["Player"] = self.currentUser
        newGame["playerPoints"] = p1Points
        
        // their friend's points
        let p2Points = PFObject(className: "Pts501")
        self.pointsIteration(p2Points)
        p2Points["Player"] = self.opponent
        newGame["opponentPoints"] = p2Points
        newGame.saveInBackground { (success, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                print("sorry about that save attempt (ViewContoller-178)")
            }
        }
        self.sendingGame = String(format: "501:%@%@", (self.currentUser?.objectId)!, (self.opponent?.objectId)!)
        newGame.pinInBackground(withName: self.sendingGame!) { (success, error) in
            if (error != nil) {
                print((error?.localizedDescription)!)
                print("sorry about that pin attempt (ViewContoller-184)")
            }
        }
    }
    func createCricket(){
        let newGame = PFObject(className: "GameCricket")
        newGame["timeStart"] = Date()
        newGame["player"] = self.currentUser
        
        if self.opponent == nil {
            self.makeTempOpponent(newGame)
        }
        newGame["opponent"] = self.opponent
        newGame["turnCounter"] = 0
        
        // device owner points
        let p1Points = PFObject(className: "PtsC")
        self.pointsIteration(p1Points)
        p1Points["Player"] = self.currentUser
        newGame["playerPoints"] = p1Points
        
        // their friend's points
        let p2Points = PFObject(className: "PtsC")
        self.pointsIteration(p2Points)
        p2Points["Player"] = self.opponent
        newGame["opponentPoints"] = p2Points
        
        newGame.saveInBackground()
        self.sendingGame = String(format: "Cricket:%@%@", (self.currentUser?.objectId)!, (self.opponent?.objectId)!)
        newGame.pinInBackground(withName: self.sendingGame!) { (success, error) in
            if (error != nil) {
                print((error?.localizedDescription)!)
                print("sorry about that pin attempt (ViewContoller-222)")
            }
        }
    }
    
    // Used to init basic point values
    func pointsIteration(_ points:PFObject) {
        // test what type of points
        let className = points.parseClassName
        guard className.isEqual("Pts501") else {
            
            // it's a cricket game
            for index in 0...5 {
                let sliceTitle = String(format: "p%d", 20-index)
                points[sliceTitle] = 0
            }
            points["p25"] = 0
            points["p0"] = 0
            points["totalPoints"] = 0
            return
        }
        // it's a 501 game
        for index in 0...20 {
            let sliceTitle = String(format: "p%d", 20-index)
            points[sliceTitle] = 0
        }
        points["p25"] = 0
        points["totalPoints"] = 501
    }
    
    //MARK: - Parse fetching functions
    func fetch501Information() {
        let query = PFQuery(className: "Game501")
        query.whereKey("timeEnd", equalTo: "undefined")
        query.findObjectsInBackground { (objects, error:Error?) in
            guard error == nil else{
                print((error?.localizedDescription)!)
                print("sorry about that find attempt (ViewContoller-257)")
                return
            }
            guard objects != nil else{
                print("objects array was nil")
                return
            }
            print("have 501 objects")
            self.games = objects
        }
        
    }
    func fetchCricketInformation() {
        let query = PFQuery(className: "GameCricket")
        query.whereKey("timeEnd", equalTo: "undefined")
        query.findObjectsInBackground { (objects, error:Error?) in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                print("sorry about that find attempt (ViewContoller-275)")
                return
            }
            guard objects != nil else{
                print("objects array was nil")
                return
            }
            print("have cricket objects")
            self.games = objects
        }
    }
    
    //MARK: - TemporaryOpponent
    func makeTempOpponent(_ game:PFObject){
        let newUser = PFUser()
        newUser.username = "LocalOpponent"
        newUser.email = ""
        let has = "saf8198538906passw".hashValue
        newUser.password = String(format: "%d%d", has.hashValue, "temp".hashValue)
        newUser.signUpInBackground()
        self.opponent = newUser
    }
}

