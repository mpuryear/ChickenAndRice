//
//  TableViewCell_Chat.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

class TableViewCell_Chat: UITableViewCell {
    
 
 
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var dateTextView: UITextView!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
