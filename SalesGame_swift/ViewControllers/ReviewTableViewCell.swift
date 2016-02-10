
//
//  ReviewTableViewCell.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/21/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionALabel: UILabel!
    @IBOutlet weak var optionBLabel: UILabel!
    @IBOutlet weak var optionCLabel: UILabel!
    @IBOutlet weak var optionDLabel: UILabel!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //==========================================================================================================================
    // MARK: 
    //==========================================================================================================================


}
