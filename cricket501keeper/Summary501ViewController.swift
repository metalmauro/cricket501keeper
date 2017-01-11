//
//  Summary501ViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-28.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

class Summary501ViewController: UIViewController {

    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var playerPts: UILabel!
    @IBOutlet weak var oppPoints: UILabel!
    
    @IBOutlet weak var playerCloseOutHint: UITextView!
    @IBOutlet weak var oppCloseOutHint: UITextView!
    
    public var gameQueryInfo:String?
    var gm:GameManager501?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.gm == nil {
            self.gm = GameManager501(withGameID: self.gameQueryInfo!)
        }
        self.playerLabel.text = self.gm?.player?.username!
        self.opponentLabel.text = self.gm?.opponent?.value(forKey: "username") as? String
        self.playerPts.text = self.gm?.playerPoints?.value(forKey: "totalPoints") as? String
        self.oppPoints.text = self.gm?.opponentPoints?.value(forKey: "totalPoints") as? String
        self.playerCloseOutHint.text = self.gm?.stringToClose((self.gm?.playerPoints)!)
        self.oppCloseOutHint.text = self.gm?.stringToClose((self.gm?.opponentPoints)!)
    }
}
