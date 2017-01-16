//
//  SummaryCricketViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-28.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class SummaryCricketViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var playerPointsLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var opponentPointsLabel: UILabel!
    var activityView:NVActivityIndicatorView?
    @IBOutlet var playerFrames: [UIImageView]!
    @IBOutlet var opponentFrames: [UIImageView]!
    @IBOutlet var closedMarkers: [UIImageView]!
    
    // set during initialization in GamePageViewController
    public var gameQueryInfo:String?
    var gameManager:CricketGameManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView = NVActivityIndicatorView(frame: self.view.frame,
                                                    type: NVActivityIndicatorType.ballTrianglePath,
                                                    color: UIColor.gray,
                                                    padding: CGFloat(0))
        self.view.addSubview(self.activityView!)
        self.playerLabel.text = self.gameManager?.player?.value(forKey: "username") as? String
        self.playerPointsLabel.text = String(format: "%d", self.gameManager?.playerPoints?.value(forKey: "totalPoints") as! Int)
        
        guard self.gameManager?.opponent != nil else {
            self.opponentLabel.text = ""
            self.opponentPointsLabel.text = ""
            return
        }
        
        self.opponentLabel.text = self.gameManager?.opponent?.value(forKey: "username") as? String
        self.opponentPointsLabel.text = String(format: "%d", self.gameManager?.opponentPoints?.value(forKey: "totalPoints") as! Int)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.gameManager == nil {
            self.gameManager = CricketGameManager()
        }
        print("Cricket Game started at: ")
        print(self.gameManager?.game?.value(forKey: "timeStart") as! NSString)
        
        for image:UIImageView in self.playerFrames {
            let sliceTitle = String(format: "p%d", image.tag)
            let hits = self.gameManager?.playerPoints?.value(forKey: sliceTitle) as? Int
            image.image = self.setFrameImage(hits: hits!)
        }
        for image:UIImageView in self.opponentFrames {
            let sliceTitle = String(format: "p%d", image.tag)
            let hits = self.gameManager?.opponentPoints?.value(forKey: sliceTitle) as? Int
            image.image = self.setFrameImage(hits: hits!)
        }
        
    }
    
    // used to find what UIImage to set for the frame images
    func setFrameImage(hits:Int) -> UIImage? {
        switch hits {
        case 0:
            return nil
        case 1:
            return UIImage(named: "single")
        case 2:
            return UIImage(named: "double")
        case 3:
            return UIImage(named: "triple")
        default:
            return UIImage(named: "triple")
        }
    }
}
