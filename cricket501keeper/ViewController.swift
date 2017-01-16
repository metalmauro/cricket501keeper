//
//  ViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-22.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

protocol GameManager {
    func createGame()
    func calculatePoints(_ points:PFObject) -> Int
    func currentTurn() -> Int
    func currentPlayer() -> String
    func advanceTurn()
    func addOpponent(_ user:PFObject)
    func isGameOver(_ lastShot:String) -> Bool
    func gameHasEnded()
}

class ViewController: UIViewController,
                    UIPickerViewDelegate,
                    UIPickerViewDataSource,
                    FriendsListDelegate,
                    NVActivityIndicatorViewable{
    
    @IBOutlet weak var gameTypeControl: UISegmentedControl!
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var backingImage: UIImageView!
    @IBOutlet weak var playGameButton: UIButton!
    
    var sendingGame:String?
    
    var GM501:GameManager501?
    var cricketGM:CricketGameManager?
    
    var activityView:NVActivityIndicatorView?
    var games:[PFObject]?
    var currentUser:PFUser?
    var opponent:PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gamePicker.dataSource = self
        self.gamePicker.delegate = self
        
        self.activityView = NVActivityIndicatorView(frame: self.view.frame,
                                                    type: NVActivityIndicatorType.ballTrianglePath,
                                                    color: UIColor.gray,
                                                    padding: CGFloat(0))
        self.view.addSubview(self.activityView!)
        switch self.gameTypeControl.selectedSegmentIndex {
        case 0:
            let size = CGSize(width: 30, height: 30)
            startAnimating(size, message: "Fetching Games", type:  NVActivityIndicatorType.ballTrianglePath)
            self.fetchCricketInformation()
            break
        case 1:
            let size = CGSize(width: 30, height: 30)
            startAnimating(size, message: "Fetching Games", type:  NVActivityIndicatorType.ballTrianglePath)
            self.fetch501Information()
            break
        default:
            break
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let index = self.gameTypeControl.selectedSegmentIndex
        switch index {
        case 0:
            // make sure Game Type is Cricket
            self.fetchCricketInformation()
            self.backingImage.image = UIImage(named: "cricketSelect")
            self.gamePicker.reloadAllComponents()
            break
        case 1:
            //make sure GameType is set as 501
            self.fetch501Information()
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
            let size = CGSize(width: 30, height: 30)
            startAnimating(size, message: "Creating Game", type:  NVActivityIndicatorType.ballTrianglePath)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.performSegue(withIdentifier: "playGame", sender: self)
            })
            break
        case 1:
            self.create501()
            let size = CGSize(width: 30, height: 30)
            startAnimating(size, message: "Creating Game", type:  NVActivityIndicatorType.ballTrianglePath)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.performSegue(withIdentifier: "playGame", sender: self)
            })
            break
        default:
            break
        }
    }
    
    // segue notes: Will send a 2pt String, which is what the game is pinned under
    // to be saved and easily fetched by the subsequent View Controllers from Pin
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pages = segue.destination as! GamePageViewController
        switch self.gameTypeControl.selectedSegmentIndex {
        case 0:
            pages.gmCricket = self.cricketGM
            break
        case 1:
            pages.gm501 = self.GM501
            break
        default:
            break
        }
    }
    
    //MARK: - pickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = 1
        let gameRules = self.gameTypeControl.selectedSegmentIndex
        switch gameRules {
        case 0:
            let gameCount:Int? = (self.games?.count)
            guard gameCount != nil else {
                return 1
            }
            if (gameCount)! > 1 {
                rows = 2
            }
            break
        case 1:
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
    func addUserToGame(_ user: PFUser) {
        switch self.gameTypeControl.selectedSegmentIndex {
        case 0:
            if self.cricketGM == nil {
                self.cricketGM = CricketGameManager()
            }
            self.cricketGM?.addOpponent(user)
            break
        case 1:
            if self.GM501 == nil {
                self.GM501 = GameManager501()
            }
            self.GM501?.addOpponent(user)
            break
        default:
            break
        }
        print("Added Opponent (mainScreenVC)")
    }
    
    func create501() {
        if self.GM501 == nil {
            self.GM501 = GameManager501()
        }
        self.GM501?.createGame()
    }
    func createCricket(){
        if self.cricketGM == nil {
            self.cricketGM = CricketGameManager()
        }
        self.cricketGM?.createGame()
    }
    
    //MARK: - Parse fetching functions
    func fetch501Information() {
        guard PFUser.current() != nil else {
            return
        }
        self.currentUser = PFUser.current()
        let subQuery1 = PFQuery(className: "Game501")
        subQuery1.whereKey("player", equalTo: self.currentUser!)
        let subQuery2 = PFQuery(className: "Game501")
        subQuery2.whereKey("timeEnd", equalTo: "")
        
        let query = PFQuery.orQuery(withSubqueries: [subQuery1, subQuery2])
        query.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
                print("error fetching Cricket games")
            } else {
                self.games = objects
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.gamePicker.reloadAllComponents()
            }
        })
    }
    func fetchCricketInformation() {
        guard PFUser.current() != nil else {
            return
        }
        self.currentUser = PFUser.current()
        let query = PFQuery(className: "GameCricket")
        query.whereKey("player", equalTo: self.currentUser!)
        query.whereKey("timeEnd", equalTo: "")
        
        query.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
                print("error fetching Cricket games")
            } else {
                self.games = objects
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.gamePicker.reloadAllComponents()
            }
        })
    }
}

