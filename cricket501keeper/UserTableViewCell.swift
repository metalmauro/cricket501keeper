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
        
        self.detailLabel.text = "Play Against Them!"
        self.checkButton.isHidden = false
        self.checkButton.setImage(UIImage(named: "redcheck"), for: UIControlState.normal)
        
    }
    func configureSelf(_ name:String){
        self.titleLabel.text = name
    }
    @IBAction func buttonFunction(_ sender: Any) {
        self.delegate?.addOpponent(self.titleLabel.text!)
    }
}
