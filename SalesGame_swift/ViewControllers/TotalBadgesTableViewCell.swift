//
//  TotalBadgesTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/12/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class TotalBadgesTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
