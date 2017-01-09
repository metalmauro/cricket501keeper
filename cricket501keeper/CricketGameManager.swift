//
//  CricketGameManager.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-03.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

class CricketGameManager: NSObject {
    
    var game:PFObject?
    var player:PFUser?
    var playerPoints:PFObject?
    var opponent:PFUser?
    var opponentPoints:PFObject?
    
    //MARK: Cricket Rulings funcitons
    func isGameOver() -> Bool {
       
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
    func isSliceClosed(_ title:String, points:PFObject) -> Bool {
        var closed:Bool = false
        let hits = points[title] as! Int
        if hits >= 3 {
            closed = true
        }
        return closed
    }
    
    // points object will have number values for 'slice' key set in TurnViewController (after shots have been made)
    // we will take the unaltered 'totalPoints' value for key, and update it if we should
    //MARK: - Point Functions
    func earnedPoints(player:PFUser, points:PFObject) -> Bool {
        let previousPoints = points.value(forKey: "totalPoints") as! Int
        var earned:Bool = false
        let calculated = self.calculatePoints(points: points)
        if calculated > previousPoints {
            // calculated points are greater than previous
            // set new point value to existing 'previousPoints' value
            points.setObject(calculated, forKey: "totalPoints")
            //save
            points.saveInBackground(block: { (success, error) in
                guard error == nil else {
                    print((error?.localizedDescription)!)
                    print("error saving point values in 'shouldEarnPoints' - CricketGameManager")
                    return
                }
                if success == true {
                    print("success saving totalPoints")
                    earned = true
                }
            })
        }
        return earned
    }
    func calculatePoints(points:PFObject) -> Int {
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
    
    // MARK: Custom Init and Parse fetching
    init(withGameID:String) {
        super.init()
        let query = PFQuery(className: "GameCricket")
        var foundGame:PFObject?
        
        query.fromPin(withName: withGameID)
        query.findObjectsInBackground { (gamesFound, error) in
            guard error == nil else {
                print((error?.localizedDescription)!)
                print("sorry about that. Failed to find game with that id (gameManager501)")
                return
            }
            guard gamesFound != nil else {
                print("games was nil for some reason (GM501)")
                return
            }
            foundGame = (gamesFound?.last)!
        }
        if foundGame != nil {
            self.game = foundGame
            self.playerPoints = foundGame?.object(forKey: "playerPoints") as! PFObject?
            self.opponentPoints = foundGame?.object(forKey: "opponentPoints") as! PFObject?
            if self.playerPoints == nil || self.opponentPoints == nil {
                print("one of our points objects from the fetched Game is nil")
            }
        } else {
            print("foundGame was nil")
        }
        if self.foundPlayers(foundGame!) == true {
            print("got our players for the game (GM501)")
        }
    }
    
    // finds players for the game
    func foundPlayers(_ game:PFObject) -> Bool {
        var checking:Bool = false
        guard game.parseClassName.isEqual("Game501") else {
            print("game wasn't a 501 game")
            return checking
        }
        let playerID = game.value(forKey: "playerID") as? String
        let oppID = game.value(forKey: "opponentID") as? String
        let pQuery = PFUser.query()
        pQuery?.whereKey("objectId", equalTo: playerID!)
        let oQuery = PFUser.query()
        oQuery?.whereKey("objectId", equalTo: oppID!)
        pQuery?.findObjectsInBackground(block: { (users, error) in
            guard error == nil else {
                print((error?.localizedDescription)!)
                print("sorry about that. Failed to find player user with that id (gameManager501)")
                return
            }
            guard users != nil else {
                print("users was nil for some reason (GM501)")
                return
            }
            self.player = users?.last as! PFUser?
            checking = true
        })
        oQuery?.findObjectsInBackground(block: { (users, error) in
            guard error == nil else {
                print((error?.localizedDescription)!)
                print("sorry about that. Failed to find opponent user with that id (gameManager501)")
                return
            }
            guard users != nil else {
                print("users was nil for some reason (GM501)")
                return
            }
            self.opponent = users?.last as! PFUser?
            checking = true
        })
        return checking
    }
    func currentTurn() -> Int {
        return self.game?.object(forKey: "turnCounter") as! Int
    }
    func currentPlayer() -> String {
        if self.currentTurn() % 2 == 0 {
            return self.opponent?.value(forKey: "username") as! String
        } else {
            return self.player?.value(forKey: "username") as! String
        }
    }
    func gameHasEnded() {
        self.game?["timeEnd"] = Date()
        self.game?.saveInBackground()
    }
}
