//
//  ChallengeTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/10/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class ChallengeTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var opponentUsernameLabel: UILabel!
    @IBOutlet weak var opponentImgView: UIImageView!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
