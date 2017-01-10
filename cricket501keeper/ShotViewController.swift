//
//  ShotViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-23.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

//MARK: - ClassNotes
// this Controller is used simply to add Values into the shotArray, and then exit
// deciphering points and saving will be done by TurnViewController
// give a button to return only once our array of madeShots gets to a count of 3

class ShotViewController: UIViewController {

    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var shot1Label: UILabel!
    @IBOutlet weak var shot2Label: UILabel!
    @IBOutlet weak var shot3Label: UILabel!
    @IBOutlet weak var missButton: UIButton!
    @IBOutlet var rightButtons: [UIButton]!
    @IBOutlet var leftButtons: [UIButton]!
    @IBOutlet var centreButtons: [UIButton]!
    
    @IBOutlet weak var bull: UIButton!
    @IBOutlet weak var doubleBull: UIButton!
    @IBOutlet weak var confirmScoresButton: UIButton!
    @IBOutlet var spinButtons: [UIButton]!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    
    let boardNumbers:Array<String> = ["20", "1", "18", "4", "13",
                                      "6", "10", "15", "2", "17",
                                      "3", "19", "7", "16", "8",
                                      "11", "14", "9", "12", "5"]
    var shotCount:Int?
    var madeShots:Array<String>?
    var currentSlice:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add button functionality (and angles, if needed)
        for button:UIButton in self.centreButtons {
            button.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        }
        for button:UIButton in self.leftButtons {
            guard button.tag > 1 else {
                button.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
                return
            }
            button.transform = CGAffineTransform(rotationAngle: CGFloat(24.9))
            button.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        }
        for button:UIButton in self.rightButtons {
            guard button.tag > 1 else {
                button.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
                return
            }
            button.transform = CGAffineTransform(rotationAngle: CGFloat(-24.9))
            button.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        }
        self.bull.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        self.doubleBull.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        self.missButton.addTarget(self, action: #selector(setShotValue(sender:)), for: UIControlEvents.touchUpInside)
        
        // add spin functions to buttons and swipes
        for button:UIButton in self.spinButtons {
            guard button.tag == 1 else {
                button.addTarget(self, action: #selector(ShotViewController.clockwiseSpin), for: UIControlEvents.touchUpInside)
                return
            }
            button.addTarget(self, action: #selector(ShotViewController.counterClockwiseSpin), for: UIControlEvents.touchUpInside)
        }
        self.leftSwipe = UISwipeGestureRecognizer(target: self.boardImage, action: #selector(ShotViewController.clockwiseSpin))
        self.rightSwipe = UISwipeGestureRecognizer(target: self.boardImage, action: #selector(ShotViewController.counterClockwiseSpin))
        // set shotCount and currentSlice
        self.shotCount = 0
        currentSlice = self.boardNumbers.index(of: "20")
    }
    
    // adds a shot to the madeShots array
    func setShotValue(sender:UIButton!) {
        var buttonIndex = self.currentSlice
        
        guard self.shotCount! < 1 else {
            if sender.restorationIdentifier?.contains("Left") == true {
                buttonIndex = self.currentSlice("left", buttonIndex!)
            } else if sender.restorationIdentifier?.contains("Right") == true {
                buttonIndex = self.currentSlice("right", buttonIndex!)
            }
            
            // take current slice, multiply it by 'sender's tag value
            let mulitplier = sender.tag
            let madeShot = String(format: "%@*%d", self.boardNumbers[buttonIndex!], mulitplier)
            self.madeShots?[shotCount!] = madeShot
            
            self.confirmScoresButton.isHidden = false
            return
        }
        // alter if one of the buttons was to the side, as opposed to centre
        if (sender.restorationIdentifier?.contains("Left"))! {
            buttonIndex = self.currentSlice("left", buttonIndex!)
        } else if (sender.restorationIdentifier?.contains("Right"))! {
            buttonIndex = self.currentSlice("right", buttonIndex!)
        }
        
        // take current slice, multiply it by 'sender's tag value
        let mulitplier = sender.tag
        let madeShot = String(format: "%@*%d", self.boardNumbers[buttonIndex!], mulitplier)
        self.madeShots?[shotCount!] = madeShot
        self.shotCount! += 1
        
    }
    @IBAction func shotsConfirmed(_ sender: Any) {
        let turnVC = self.parent! as! TurnViewController
        turnVC.madeShots = NSMutableArray(array: self.madeShots!)
        self.dismiss(animated: true, completion: nil)
    }
    
    // function demands to type in right (counterClockwise) 1 or left (Clockwise) 2
    // only used in rotation functions
    func currentSlice(_ direction:String, _ from:Int) -> Int {
        let index = self.currentSlice
        guard (direction.isEqual("right")) else {
            //spin cw
            if index == 0 {
                return self.boardNumbers.count-1
            }else{
                return index!-1
            }
        }
        //spin ccw
        if index == self.boardNumbers.count-1 {
            return 0
        }else{
            return index!+1
        }
    }
    
    //MARK: - Rotation functions
    func clockwiseSpin() {
        self.currentSlice = currentSlice("right", self.currentSlice)
        //taken from our lecture on Core Animations
        UIView.animateKeyframes(
            withDuration: 4.0,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                //Note: Relative times are percentages
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { 
                    self.boardImage.transform.rotated(by: -0.314)
                })
        },
            completion: nil)
        
    }
    func counterClockwiseSpin() {
        self.currentSlice = currentSlice("left", self.currentSlice)
        UIView.animateKeyframes(
            withDuration: 4.0,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                //Note: Relative times are percentages
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                    self.boardImage.transform.rotated(by: 0.314)
                })
        },
            completion: nil)
    }
    
}
