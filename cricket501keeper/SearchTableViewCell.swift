//
//  SearchTableViewCell.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2017-01-10.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

protocol SearchCellDelegate {
    func addFriend(_ username:String)
}

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var username:String?
    var delegate:SocialCellDelegate?
    var select:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Set Background to red / green
        // set image to checkmark
        guard selected == true else {
            self.titleLabel.text = self.username
            self.select = false
            self.detailLabel.text = ""
            self.checkButton.isHidden = true
            return
        }
        self.titleLabel.text = self.username
        self.select = true
        self.detailLabel.text = "Add User as a Friend"
        self.checkButton.setImage(UIImage(named: "redcheck"), for: UIControlState.normal)
    }
    func configureSelf(_ name:String){
        self.select = false
        self.username = name
        self.titleLabel.text = name
    }
    
    @IBAction func buttonFunction(_ sender: Any) {
        self.delegate?.addOpponent(self.titleLabel.text!)
    }
}

