//
//  Badges.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/30/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import Foundation
import Parse

class Badges: PFObject, PFSubclassing {
    
    //=======================================================================================
    // MARK: Properties
    //=======================================================================================

    @NSManaged var badgeName: String?
    @NSManaged var badgeImg: PFFile?
    @NSManaged var badgeDescription: String?
    
    var badgeArray: NSMutableArray = NSMutableArray()
    var image: UIImage?
    
    
    //=======================================================================================
    // MARK: PFSubclassing Protocol
    //=======================================================================================

    static func parseClassName() -> String {
        return "Badges"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    //==========================================================================
    // MARK: Methods
    //==========================================================================

    func uploadImage() {
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let photo = PFFile(data: imageData)
            photo.saveInBackground()
            
            self.badgeImg = photo
            saveInBackground()
        }
    }
    
    
    
    
}