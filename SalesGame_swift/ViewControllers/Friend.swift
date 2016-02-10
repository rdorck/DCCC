//
//  Friend.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/21/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import Foundation
import Parse

class Friend: PFObject, PFSubclassing {

    //==========================================================================
    // MARK: Properties
    //==========================================================================

    @NSManaged var username: String?
    @NSManaged var profilePic: PFFile?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    var image: UIImage?
    
    
    //==========================================================================
    // MARK: PFSubclassing Protocol
    //==========================================================================

    static func parseClassName() -> String {
        return "Friend"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    
    //==========================================================================
    // MARK: Methods
    //==========================================================================

    func uploadUserImage() {
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let profilePicFile = PFFile(data: imageData)
            profilePicFile.saveInBackground()
            
            self.profilePic = profilePicFile
            saveInBackground()
        }
    }
    
    
    
    
    
}