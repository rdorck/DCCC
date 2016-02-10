//
//  FriendTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendImgView: UIImageView!
    @IBOutlet weak var newLabel: UILabel!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
