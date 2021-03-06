//
//  TurnViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-23.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class TurnViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var currentPlayerLabel: UILabel!
    public var madeShots:NSMutableArray?
    
    var game:PFObject?
    var player:PFUser?
    var opponent:PFUser?
    var rules:String?
    var turnCounter:Int?
    var activityView:NVActivityIndicatorView?
    var cricketGM:CricketGameManager?
    var GM501:GameManager501?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.cricketGM == nil {
            // start spinning
            self.cricketGM = CricketGameManager()
            print("spinning")
            self.activityView = NVActivityIndicatorView(frame: self.view.frame,
                                                        type: NVActivityIndicatorType.ballTrianglePath,
                                                        color: UIColor.orange,
                                                        padding: 0)
            self.view.addSubview(self.activityView!)
        }
        
        guard (self.GM501 != nil) else {
            // is cricket game
            self.turnCounter = self.cricketGM?.currentTurn()
            self.currentPlayerLabel.text = self.cricketGM?.currentPlayer()
            return
        }
        // is 501 game
        self.turnCounter = self.GM501?.currentTurn()
        self.currentPlayerLabel.text = self.GM501?.currentPlayer()
    }
    
    //MARK: - ViewWillAppear
    // where we add new shots and save the point values associated to the proper user, for the right game.
    
    override func viewWillAppear(_ animated: Bool) {
        // if the madeShots Array's count is at 3, process them into the game's points
        guard self.madeShots?.count == 3 else {
            print("don't have 3 shots")
            self.madeShots = []
            return
        }
        
        print("we have 3 shots to add")
        
        //add point values to the points in game
        guard (self.GM501 != nil) else {
            
            guard (self.cricketGM?.opponent?.value(forKey: "username") as! String).isEqual((self.cricketGM?.currentPlayer())!) else {
                    // is player
                    self.addCricketPoints(self.game?.object(forKey: "playerPoints") as! PFObject)
                    let success = self.cricketGM?.earnedPoints(player: self.player!, points: self.game?.object(forKey: "playerPoints") as! PFObject)
                    if success == true {
                        print("success in viewWilAppear adding points to player of cricket game")
                    }
                    return
            }
            // is the opponent
            self.addCricketPoints(self.game?.object(forKey: "opponentPoints") as! PFObject)
            let success = self.cricketGM?.earnedPoints(player: self.opponent!, points: self.game?.object(forKey: "opponentPoints") as! PFObject)
            if success == true {
                print("success in viewWilAppear adding points to opponent of cricket game")
            }
            
            
            //check if game has ended due to point additions
            guard (self.cricketGM?.isGameOver(self.madeShots?.lastObject as! String))! else {
                //game is still going
                return
            }
            //game has ended, alert players
            self.cricketGM?.gameHasEnded()
            //make UIAlert to tell users that it's over
            
            return
        }
        
        //501 game
        // make 501 GM if there isnt one already
        
        // which player is current
        guard (self.GM501?.opponent?.value(forKey: "username") as! String).isEqual((self.GM501?.currentPlayer())!) else {
            // player is current
            self.add501Points((self.GM501?.playerPoints)!)
            if (self.GM501?.updatedPoints((self.GM501?.playerPoints)!))! {
                print("success in viewWilAppear adding points to player of 501 game")
            }
            return
        }
        // opponent is current
        self.add501Points((self.GM501?.opponentPoints)!)
        if (self.GM501?.updatedPoints((self.GM501?.opponentPoints)!))! {
            print("success in viewWilAppear adding points to opponent of 501 game")
        }
        
        // check if game has ended due to point additions
        guard (self.GM501?.isGameOver(madeShots?.lastObject! as! String))! else {
            //game is still going on
            return
        }
        //game has ended, alert players
        self.GM501?.gameHasEnded()
        //make UIAlert to tell users that it's over
        
    }
    
    
    //MARK: - Point addition functions
    func add501Points(_ points:PFObject) {
        guard points.parseClassName.isEqual("Pts501") else {
            print("wrong Parse Class for function")
            return
        }
        for index in 0...2 {
            // take data from array and find what slice was hit
            let newData = (self.madeShots?[index])! as! String
            var dataArray = newData.components(separatedBy: "x")
            let slice = dataArray[0]
            let multi = dataArray[1]
            
            for var pointValues in 0...21 {
                if pointValues > 20 {
                    pointValues = 25
                }
                guard Int(slice) == pointValues else {
                    print("not a scoring slice")
                    return
                }
                let title = String(format: "p%d", pointValues)
                var previousHits = points[title] as! Int
                if (multi.isEqual("x3")) {
                    previousHits += 3
                }
                if (multi.isEqual("x2")) {
                    previousHits += 2
                }
                if (multi.isEqual("x1")) {
                    previousHits += 1
                }
            }
        }
        points.saveInBackground { (success, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                print("sorry about that save attempt. TurnViewController 142")
            }
            if success == true {
                print("save successful")
            }
        }
    }
    func addCricketPoints(_ points:PFObject) {
        guard points.parseClassName.isEqual("PtsC") else {
            print("wrong Parse Class for function")
            return
        }
        for index in 0...2 {
            // take data from array and find what slice was hit
            let newData = (self.madeShots?[index])! as! String
            var dataArray = newData.components(separatedBy: "x")
            let slice = dataArray[0]
            let multi = dataArray[1]
            
            for var pointValues in 15...22 {
                if pointValues > 20 {
                    guard pointValues == 21 else {
                        pointValues = 25
                        return
                    }
                    pointValues = 0
                }
                guard Int(slice) == pointValues else {
                    return
                }
                let title = String(format: "p%d", pointValues)
                var previousHits = points[title] as! Int
                if (multi.isEqual("x3")) {
                    previousHits += 3
                }
                if (multi.isEqual("x2")) {
                    previousHits += 2
                }
                if (multi.isEqual("x1")) {
                    previousHits += 1
                }
            }
        }
        points.saveInBackground { (success, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                print("sorry about that save attempt. TurnViewController 142")
            }
            if success == true {
                print("save successful")
            }
        }
    }
    //MARK: - activityControl
    func hasFinishedLoading() {
        self.activityView?.stopAnimating()
    }
    func startedLoading() {
        self.activityView?.startAnimating()
    }
}
