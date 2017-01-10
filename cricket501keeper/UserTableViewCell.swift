//
//  UserTableViewCell.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-09.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

protocol SocialCellDelegate {
    func addFriend(_ username:String)
    func addOpponent(_ username:String)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var delegate:SocialCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Set Background to red / green
        // set image to checkmark
        guard selected == true else {
            self.detailLabel.text = ""
            self.checkButton.isHidden = true
            return
        }
        
        guard (self.reuseIdentifier?.isEqual("searchCell"))! else {
            // is cell that shows User's friend
            self.detailLabel.text = "Play Against Them!"
            self.checkButton.isHidden = false
            self.checkButton.setImage(UIImage(named: "redcheck"), for: UIControlState.normal)
            return
        }
        // is user that our current User is searching for
        self.detailLabel.text = "Add User as a Friend"
        self.checkButton.setImage(UIImage(named: "redcheck"), for: UIControlState.normal)
    }
    @IBAction func buttonFunction(_ sender: Any) {
        guard (self.reuseIdentifier?.isEqual("searchCell"))! else {
            self.delegate?.addOpponent(self.titleLabel.text!)
            return
        }
        self.delegate?.addFriend(self.titleLabel.text!)
    }
}
