//
//  SubCategory.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/30/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import Foundation
import Parse

class SubCategory: PFObject, PFSubclassing {
    
    //==========================================================================
    // MARK: Properties
    //==========================================================================

    @NSManaged var subCategoryName: String?
    @NSManaged var subCategoryFile: PFFile?
    var image: UIImage?
    @NSManaged var parentCategory: PFObject?
    @NSManaged var minPassingScore: NSNumber?
    
    
    //==========================================================================
    // MARK: PFSubclassing Protocol
    //==========================================================================

    static func parseClassName() -> String {
        return "SubCategory"
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
