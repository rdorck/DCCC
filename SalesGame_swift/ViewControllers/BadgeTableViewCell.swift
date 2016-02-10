//
//  BadgeTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/10/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class BadgeTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var badgeImgView: UIImageView!
    
    
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
