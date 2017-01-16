//
//  CricketGameManager.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-03.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class CricketGameManager: NSObject, GameManager {
    
    var game:PFObject?
    var player:PFUser?
    var playerPoints:PFObject?
    var opponent:PFObject?
    var opponentPoints:PFObject?
    
    //MARK: GameManager functions
    func isGameOver(_ lastShot:String) -> Bool {
        var completed:Bool = false
        //check Player
        var playerFrames = 0
        for var index in 15...22 {
            if index == 21 {
                index = 25
            }
            let sliceCheck = self.isSliceClosed((String(format: "p%d", index)), points: playerPoints!)
            if sliceCheck == true {
                playerFrames += 1
            }
        }
        // check if player has cleared the board
        if playerFrames == 7 {
            completed = true
        }
        //check Opponent
        var opponentFrames = 0
        for var index in 15...22 {
            if index == 21 {
                index = 25
            }
            let sliceCheck = self.isSliceClosed((String(format: "p%d", index)), points: self.opponentPoints!)
            if sliceCheck == true {
                opponentFrames += 1
            }
        }
        // check if opponent has cleared the board
        if opponentFrames == 7 {
            completed = true
        }
        return completed
    }
    
    func addOpponent(_ user:PFObject) {
        self.opponent = user
    }
    // increase game's TurnCounter and save
    func advanceTurn() {
        let turn = self.game?.value(forKey: "turnCounter") as? Int
        self.game?["turnCounter"] = turn! + 1
        self.game?.saveInBackground()
    }
    
    // points object will have number values for 'slice' key set in TurnViewController (after shots have been made)
    // we will take the unaltered 'totalPoints' value for key, and update it if we should
   
    func calculatePoints(_ points:PFObject) -> Int {
        var earnedPoints = 0
        for var index in 15...22 {
            if index == 21 {
                index = 25
            }
            var hitsMade = points.value(forKey: String(format: "p%d", index)) as? Int
            guard hitsMade != nil else {
                hitsMade = 0
                break
            }
            if hitsMade! > 3 {
                earnedPoints += (index*(hitsMade!-3))
            }
        }
        return earnedPoints
    }
    
    func currentTurn() -> Int {
        return self.game?.object(forKey: "turnCounter") as! Int
    }
    func currentPlayer() -> String {
        if self.currentTurn() % 2 == 0 {
            guard self.opponent != nil else {
                return ""
            }
            return self.opponent?.value(forKey: "username") as! String
        } else {
            return self.player?.value(forKey: "username") as! String
        }
    }
    func gameHasEnded() {
        self.game?["timeEnd"] = Date()
        self.game?.saveInBackground()
    }
    //Parse Game creation and save
    func createGame(){
        
        let newGame = PFObject(className: "Game501")
        newGame["timeStart"] = Date()
        self.player = PFUser.current()
        
        let playerRelations = newGame.relation(forKey: "userPlayers")
        let locals = newGame.relation(forKey: "Locals")
        if self.opponent == nil {
            let localOpp = PFObject(className: "localOpp")
            localOpp["creator"] = self.player
            locals.add(localOpp)
            localOpp.saveInBackground()
            self.opponent = localOpp
            let localRelate = self.player?.relation(forKey: "Locals")
            localRelate?.add(localOpp)
            playerRelations.add(self.player!)
        } else {
            playerRelations.add(self.player!)
            playerRelations.add(self.opponent!)
        }
        newGame["turnCounter"] = 1
        
        // device owner points
        let p1Points = PFObject(className: "Pts501")
        p1Points["Player"] = self.player
        newGame["playerPoints"] = p1Points
        // their friend's points
        let p2Points = PFObject(className: "Pts501")
        if self.opponent != nil {
            p2Points["Player"] = self.opponent!
        } else {
            p2Points["Player"] = NSNull()
        }
        newGame["opponentPoints"] = p2Points
        
        self.pointsIteration(p1Points)
        self.pointsIteration(p2Points)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            newGame.saveInBackground { (success, error) in
                if let error = error {
                    print((error.localizedDescription))
                    print("sorry about that save attempt (GM501)")
                } else {
                    print("Game saved")
                    let pinnedGame = String(format: "501:%@v%@", (self.player?.username)!, (self.opponent?.value(forKey: "username") as! String))
                    newGame.pinInBackground(withName: pinnedGame) { (success, error) in
                        if let error = error {
                            print((error.localizedDescription))
                            print("sorry about that pin attempt GM501")
                        } else {
                            print("GM501 pinned")
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    //MARK: - Point Functions
    func pointsIteration(_ points:PFObject) {
        // it's a cricket game
        for index in 0...5 {
            let sliceTitle = String(format: "p%d", 20-index)
            points[sliceTitle] = 0
        }
        points["p25"] = 0
        points["p0"] = 0
        points["totalPoints"] = 0
        points.saveInBackground()
    }
    func isSliceClosed(_ title:String, points:PFObject) -> Bool {
        var closed:Bool = false
        let hits = points[title] as! Int
        if hits >= 3 {
            closed = true
        }
        return closed
    }
    func earnedPoints(player:PFUser, points:PFObject) -> Bool {
        let previousPoints = points.value(forKey: "totalPoints") as! Int
        var earned:Bool = false
        let calculated = self.calculatePoints(points)
        if calculated > previousPoints {
            // calculated points are greater than previous
            // set new point value to existing 'previousPoints' value
            points.setObject(calculated, forKey: "totalPoints")
            earned = true
            //save
            points.saveInBackground()
        }
        return earned
    }
}
