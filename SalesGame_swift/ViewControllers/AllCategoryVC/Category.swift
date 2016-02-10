//
//  Category.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/13/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import Foundation
import Parse

class Category: PFObject, PFSubclassing {
    
    //==========================================================================
    // MARK: Properties
    //==========================================================================

    @NSManaged var categoryName: String?
    @NSManaged var categoryFile: PFFile?
    @NSManaged var createdBy: PFObject?
    
    var image: UIImage?
    
    //==========================================================================
    // MARK: PFSubclassing Protocol
    //==========================================================================

    static func parseClassName() -> String {
        return "Category"
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

    
    
}

