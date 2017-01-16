//
//  GameManager501.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-08.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class GameManager501: NSObject, GameManager {
    
    var game:PFObject?
    var player:PFUser?
    var playerPoints:PFObject?
    var opponent:PFObject?
    var opponentPoints:PFObject?
    
    //MARK: - GameManager Functions
    func addOpponent(_ user:PFObject) {
        self.opponent = user
    }
    func updatedPoints(_ points:PFObject) -> Bool {
        let currentPoints = points.value(forKey: "totalPoints") as! Int
        let calculated = 501 - self.calculatePoints(points)
        guard calculated >= 0 else {
            return false
        }
        if calculated < currentPoints {
            guard calculated > 1 else {
                print("User was left with a single point. bust")
                return false
            }
            points["totalPoints"] = calculated
            points.saveInBackground()
            return true
        } else {
            return false
        }
    }
    func calculatePoints(_ points:PFObject) -> Int {
        // finds total points scored, to be subtracted from totalPoints score in 'updatedPoints'
        var calculated = 0
        for var index in 0...21 {
            if index == 21 {
                index = 25
            }
            var hitsMade = points.value(forKey: String(format: "p%d", index)) as? Int
            if hitsMade == nil {
                hitsMade = 0
            }
            calculated += (index*(hitsMade!))
        }
        return calculated
    }
    // check if game is over
    func isGameOver(_ lastShot:String) -> Bool {
        guard self.playerPoints?.value(forKey: "totalPoints") as! Int != 0 || self.opponentPoints?.value(forKey: "totalPoints") as! Int != 0 else {
            guard (lastShot.contains("*2")) else {
                return false
            }
            return true
        }
        return false
    }
    // increase game's TurnCounter and save
    func advanceTurn() {
        let turn = self.game?.value(forKey: "turnCounter") as? Int
        self.game?["turnCounter"] = turn! + 1
        self.game?.saveInBackground()
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
    
    //MARK: - Parse Game Creation
    /*
     use note:
     User will have a friendsList array, to which they will choose a player to play against
     will ahve to add their friend to the game, and will send a Push Notification out to the opponent to join
     must simply add points and player values to the game of their choice, and then save the game and move forward
     current Game will be pinned to the device, allowing for easier reference moving forward
     subsequent View Controllers will fetch the saved game and then use and save data appropriately
     */
    /*
     Games have these Keys we MUST SET properly
     
     playerPoints (Pointer)
     opponentPoints (Pointer)
     userPlayers (Relation)
     locals (Relation)
     turnCounter
     timeStart
     timeEnd
     
     */
    
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
            self.opponent = localOpp
            let localRelate = self.player?.relation(forKey: "Locals")
            localOpp.saveInBackground()
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
    // Used to init basic point values
    func pointsIteration(_ points:PFObject) {
        // it's a 501 game
        for index in 0...20 {
            let sliceTitle = String(format: "p%d", 20-index)
            points[sliceTitle] = 0
        }
        points["p25"] = 0
        points["totalPoints"] = 501
        points.saveInBackground { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                print("error saving points")
            } else {
                print("saved points")
            }
        }
    }
    
    
    
    //MARK: Checkout Chart
    // yeah this function is long. Either that or a dictionary would be long
    func stringToClose(_ points:PFObject) -> String {
        let currentPoints = points.value(forKey: "totalPoints") as! Int
        guard currentPoints <= 170 else {
            return "Keep Scoring Points!"
        }
        switch currentPoints {
        case 170:
            return "Hit:\n 20*3, 20*3, Bull*1 \n to WIN!"
        case 167:
            return "Hit:\n 20*3, 19*3, Bull*1 \n to WIN!"
        case 164:
            return "Hit:\n 20*3, 18*3, Bull*1 \n to WIN!"
        case 161:
            return "Hit:\n 20*3, 17*3, Bull*1 \n to WIN!"
        case 160:
            return "Hit:\n 20*3, 20*3, 20*2 \n to WIN!"
        case 158:
            return "Hit:\n 20*3, 20*3, 19*2 \n to WIN!"
        case 157:
            return "Hit:\n 20*3, 19*3, 20*2 \n to WIN!"
        case 156:
            return "Hit:\n 20*3, 20*3, 18*2 \n to WIN!"
        case 155:
            return "Hit:\n 20*3, 19*3, 19*2 \n to WIN!"
        case 154:
            return "Hit:\n 20*3, 18*3, 20*2 \n to WIN!"
        case 153:
            return "Hit:\n 20*3, 19*3, 18*2 \n to WIN!"
        case 152:
            return "Hit:\n 20*3, 20*3, 16*2 \n to WIN!"
        case 151:
            return "Hit:\n 20*3, 17*3, 20*2 \n to WIN!"
        case 150:
            return "Hit:\n 20*3, 18*3, 18*2 \n to WIN!"
        case 154:
            return "Hit:\n 20*3, 18*3, 18*2 \n to WIN!"
        case 153:
            return "Hit:\n 20*3, 19*3, 18*2 \n to WIN!"
        case 152:
            return "Hit:\n 20*3, 20*3, 18*2 \n to WIN!"
        case 151:
            return "Hit:\n 20*3, 17*3, 20*2 \n to WIN!"
        case 150:
            return "Hit:\n 20*3, 18*3, 18*2 \n to WIN!"
        case 149:
            return "Hit:\n 20*3, 19*3, 16*2 \n to WIN!"
        case 148:
            return "Hit:\n 20*3, 16*3, 20*2 \n to WIN!"
        case 147:
            return "Hit:\n 20*3, 17*3, 18*2 \n to WIN!"
        case 146:
            return "Hit:\n 20*3, 18*3, 16*2 \n to WIN!"
        case 145:
            return "Hit:\n 20*3, 15*3, 20*2 \n to WIN!"
        case 144:
            return "Hit:\n 20*3, 20*3, 19*2 \n to WIN!"
        case 143:
            return "Hit:\n 20*3, 17*3, 16*2 \n to WIN!"
        case 142:
            return "Hit:\n 20*3, 14*3, 20*2 \n to WIN!"
        case 141:
            return "Hit:\n 20*3, 19*3, 12*2 \n to WIN!"
        case 140:
            return "Hit:\n 20*3, 16*3, 16*2 \n to WIN!"
        case 139:
            return "Hit:\n 19*3, 14*3, 20*2 \n to WIN!"
        case 138:
            return "Hit:\n 20*3, 18*3, 12*2 \n to WIN!"
        case 137:
            return "Hit:\n 19*3, 16*3, 16*2 \n to WIN!"
        case 136:
            return "Hit:\n 20*3, 20*3, 8*2 \n to WIN!"
        case 135:
            return "Hit:\n 20*3, 17*3, 12*2 \n to WIN!"
        case 134:
            return "Hit:\n 20*3, 14*3, 16*2 \n to WIN!"
        case 133:
            return "Hit:\n 20*3, 19*3, 8*2 \n to WIN!"
        case 132:
            return "Hit:\n 20*3, 16*3, 12*2 \n to WIN!"
        case 131:
            return "Hit:\n 20*3, 13*3, 16*2 \n to WIN!"
        case 130:
            return "Hit:\n 20*3, 20*1, Bull*1 \n to WIN!"
        case 129:
            return "Hit:\n 19*3, 16*3, 12*2 \n to WIN!"
        case 128:
            return "Hit:\n 18*3, 14*3, 16*2 \n to WIN!"
        case 127:
            return "Hit:\n 20*3, 17*3, 8*2 \n to WIN!"
        case 126:
            return "Hit:\n 19*3, 19*3, 6*2 \n to WIN!"
        case 125:
            return "Hit:\n Bull*2, 20*3, 20*2 \n to WIN!"
        case 124:
            return "Hit:\n 20*3, 16*3, 8*2 \n to WIN!"
        case 123:
            return "Hit:\n 19*3, 16*3, 9*2 \n to WIN!"
        case 122:
            return "Hit:\n 18*3, 20*3, 4*2 \n to WIN!"
        case 121:
            return "Hit:\n 17*3, 10*3, 20*2 \n to WIN!"
        case 120:
            return "Hit:\n 20*3, 20*1, 20*2 \n to WIN!"
        case 119:
            return "Hit:\n 19*3, 10*3, 16*2 \n to WIN!"
        case 118:
            return "Hit:\n 20*3, 10*1, 20*2 \n to WIN!"
        case 117:
            return "Hit:\n 20*3, 17*1, 20*2 \n to WIN!"
        case 116:
            return "Hit:\n 20*3, 16*1, 20*2 \n to WIN!"
        case 115:
            return "Hit:\n 20*3, 15*1, 20*2 \n to WIN!"
        case 114:
            return "Hit:\n 20*3, 14*1, 20*2 \n to WIN!"
        case 113:
            return "Hit:\n 20*3, 13*1, 20*2 \n to WIN!"
        case 112:
            return "Hit:\n 20*3, 12*1, 20*2 \n to WIN!"
        case 111:
            return "Hit:\n 20*3, 19*1, 16*2 \n to WIN!"
        case 110:
            return "Hit:\n 20*3, 18*1, 16*2 \n to WIN!"
        case 109:
            return "Hit:\n 19*3, 20*1, 16*2 \n to WIN!"
        case 108:
            return "Hit:\n 20*3, 16*1, 16*2 \n to WIN!"
        case 107:
            return "Hit:\n 19*3, 18*1, 16*2 \n to WIN!"
        case 106:
            return "Hit:\n 20*3, 14*1, 16*2 \n to WIN!"
        case 105:
            return "Hit:\n 19*3, 16*1, 16*2 \n to WIN!"
        case 104:
            return "Hit:\n 18*3, 18*1, 16*2 \n to WIN!"
        case 103:
            return "Hit:\n 20*3, 3*1, 20*2 \n to WIN!"
        case 102:
            return "Hit:\n 20*3, 10*1, 16*2 \n to WIN!"
        case 101:
            return "Hit:\n 20*3, 1*1, 20*2 \n to WIN!"
        case 100:
            return "Hit:\n 20*3, 20*2 \n to WIN!"
        case 99:
            return "Hit:\n 19*3, 10*1, 16*2 \n to WIN!"
        case 98:
            return "Hit:\n 20*3, 19*2 \n to WIN!"
        case 97:
            return "Hit:\n 19*3, 20*2 \n to WIN!"
        case 96:
            return "Hit:\n 20*3, 18*2 \n to WIN!"
        case 95:
            return "Hit:\n 19*3, 19*2 \n to WIN!"
        case 94:
            return "Hit:\n 18*3, 20*2 \n to WIN!"
        case 93:
            return "Hit:\n 19*3, 18*2 \n to WIN!"
        case 92:
            return "Hit:\n 20*3, 16*2 \n to WIN!"
        case 91:
            return "Hit:\n 17*3, 20*2 \n to WIN!"
        case 90:
            return "Hit:\n 20*3, 15*2 \n to WIN!"
        case 89:
            return "Hit:\n 19*3, 16*2 \n to WIN!"
        case 88:
            return "Hit:\n 16*3, 20*2 \n to WIN!"
        case 87:
            return "Hit:\n 17*3, 18*2 \n to WIN!"
        case 86:
            return "Hit:\n 18*3, 16*2 \n to WIN!"
        case 85:
            return "Hit:\n 15*3, 20*2 \n to WIN!"
        case 84:
            return "Hit:\n 20*3, 12*2 \n to WIN!"
        case 83:
            return "Hit:\n 17*3, 16*2 \n to WIN!"
        case 82:
            return "Hit:\n 14*3, 20*2 \n to WIN!"
        case 81:
            return "Hit:\n 19*3, 12*2 \n to WIN!"
        case 80:
            return "Hit:\n 20*3, 10*2 \n to WIN!"
        case 79:
            return "Hit:\n 13*3, 20*2 \n to WIN!"
        case 78:
            return "Hit:\n 18*3, 12*2 \n to WIN!"
        case 77:
            return "Hit:\n 19*3, 10*2 \n to WIN!"
        case 76:
            return "Hit:\n 20*3, 8*2 \n to WIN!"
        case 75:
            return "Hit:\n 17*3, 12*2 \n to WIN!"
        case 74:
            return "Hit:\n 14*3, 16*2 \n to WIN!"
        case 73:
            return "Hit:\n 19*3, 8*2 \n to WIN!"
        case 72:
            return "Hit:\n 16*3, 12*2 \n to WIN!"
        case 71:
            return "Hit:\n 13*3, 16*2 \n to WIN!"
        case 70:
            return "Hit:\n 10*3, 20*2 \n to WIN!"
        case 69:
            return "Hit:\n 15*3, 12*2 \n to WIN!"
        case 68:
            return "Hit:\n 20*3, 4*2 \n to WIN!"
        case 67:
            return "Hit:\n 17*3, 8*2 \n to WIN!"
        case 66:
            return "Hit:\n 10*3, 18*2 \n to WIN!"
        case 65:
            return "Hit:\n 19*3, 4*2 \n to WIN!"
        case 64:
            return "Hit:\n 16*3, 8*2 \n to WIN!"
        case 63:
            return "Hit:\n 13*3, 12*2 \n to WIN!"
        case 62:
            return "Hit:\n 10*3, 16*2 \n to WIN!"
        case 61:
            return "Hit:\n 15*3, 8*2 \n to WIN!"
        case 60:
            return "Hit:\n 20*1, 20*2 \n to WIN!"
        case 59:
            return "Hit:\n 15*3, 7*2 \n to WIN!"
        case 58:
            return "Hit:\n 20*2, 9*2 \n to WIN!"
        case 57:
            return "Hit:\n 15*3, 6*2 \n to WIN!"
        case 56:
            return "Hit:\n 20*2, 8*2 \n to WIN!"
        case 55:
            return "Hit:\n 15*3, 5*2 \n to WIN!"
        case 54:
            return "Hit:\n 20*2, 7*2 \n to WIN!"
        case 53:
            return "Hit:\n 11*3, 10*2 \n to WIN!"
        case 52:
            return "Hit:\n 20*2, 6*2 \n to WIN!"
        case 51:
            return "Hit:\n 15*3, 3*2 \n to WIN!"
        case 50:
            return "Hit:\n 15*2, 10*2 \n to WIN!"
        case 49:
            return "Hit:\n 11*3, 8*2 \n to WIN!"
        case 48:
            return "Hit:\n 10*3, 9*2 \n to WIN!"
        case 47:
            return "Hit:\n 11*3, 7*2 \n to WIN!"
        case 46:
            return "Hit:\n 10*3, 8*2 \n to WIN!"
        case 45:
            return "Hit:\n 5*1, 20*2 \n to WIN!"
        case 44:
            return "Hit:\n 4*1, 20*2 \n to WIN!"
        case 43:
            return "Hit:\n 3*1, 20*2 \n to WIN!"
        case 42:
            return "Hit:\n 2*1, 20*2 \n to WIN!"
        case 41:
            return "Hit:\n 1*1, 20*2 \n to WIN!"
        case 40:
            return "Hit:\n 20*2 \n to WIN!"
        case 39:
            return "Hit:\n 9*1, 15*2 \n to WIN!"
        case 38:
            return "Hit:\n 8*1, 15*2 \n to WIN!"
        case 37:
            return "Hit:\n 7*1, 15*2 \n to WIN!"
        case 36:
            return "Hit:\n 18*2 \n to WIN!"
        case 35:
            return "Hit:\n 5*1, 15*2 \n to WIN!"
        case 34:
            return "Hit:\n 17*2 \n to WIN!"
        case 33:
            return "Hit:\n 3*1, 15*2 \n to WIN!"
        case 32:
            return "Hit:\n 16*2 \n to WIN!"
        case 31:
            return "Hit:\n 1*1, 15*2 \n to WIN!"
        case 30:
            return "Hit:\n 15*2 \n to WIN!"
        case 29:
            return "Hit:\n 9*1, 10*2 \n to WIN!"
        case 28:
            return "Hit:\n 14*2 \n to WIN!"
        case 27:
            return "Hit:\n 7*1, 10*2 \n to WIN!"
        case 26:
            return "Hit:\n 13*2 \n to WIN!"
        case 25:
            return "Hit:\n 5*1, 10*2 \n to WIN!"
        case 24:
            return "Hit:\n 12*2 \n to WIN!"
        case 23:
            return "Hit:\n 3*1, 10*2 \n to WIN!"
        case 22:
            return "Hit:\n 11*2 \n to WIN!"
        case 21:
            return "Hit:\n 1*1, 10*2 \n to WIN!"
        case 20:
            return "Hit:\n 10*2 \n to WIN!"
        case 19:
            return "Hit:\n 9*1, 5*2 \n to WIN!"
        case 18:
            return "Hit:\n 9*2 \n to WIN!"
        case 17:
            return "Hit:\n 7*1, 5*2 \n to WIN!"
        case 16:
            return "Hit:\n 8*2 \n to WIN!"
        case 15:
            return "Hit:\n 5*1, 5*2 \n to WIN!"
        case 14:
            return "Hit:\n 7*2 \n to WIN!"
        case 13:
            return "Hit:\n 3*1, 5*2 \n to WIN!"
        case 12:
            return "Hit:\n 6*2 \n to WIN!"
        case 11:
            return "Hit:\n 1*1, 5*2 \n to WIN!"
        case 10:
            return "Hit:\n 5*2 \n to WIN!"
        case 9:
            return "Hit:\n 3*1, 3*2 \n to WIN!"
        case 8:
            return "Hit:\n 4*2 \n to WIN!"
        case 7:
            return "Hit:\n 1*1, 3*2 \n to WIN!"
        case 6:
            return "Hit:\n 3*2 \n to WIN!"
        case 5:
            return "Hit:\n 1*1, 2*2 \n to WIN!"
        case 4:
            return "Hit:\n 2*2 \n to WIN!"
        case 3:
            return "Hit:\n 1*1, 1*2 \n to WIN!"
        case 2:
            return "Hit:\n 1*2 \n to WIN!"
        default:
            return "Keep Scoring Points! (still no easy way out)"
        }
    }
}
