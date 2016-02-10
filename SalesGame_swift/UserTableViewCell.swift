//
//  UserTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    //==========================================================================================================================
    // MARK:
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
