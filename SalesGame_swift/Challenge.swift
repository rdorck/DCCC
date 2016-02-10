//
//  Challenge.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/10/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import Foundation
import Parse

class Challenge: PFObject, PFSubclassing {
    
    //=======================================================================================
    // MARK: Properties
    //=======================================================================================
    
    @NSManaged var challenger: PFObject!
    @NSManaged var challengerTurn: Bool
    @NSManaged var opponent: PFObject!
    @NSManaged var challengerScore: NSNumber?
    @NSManaged var opponentScore: NSNumber?
    @NSManaged var challengerCorrect: [PFObject]?
    @NSManaged var challengerWrong: [PFObject]?
    @NSManaged var opponentCorrect: [PFObject]?
    @NSManaged var opponentWrong: [PFObject]?
    @NSManaged var category: Category?
    @NSManaged var subCategory: SubCategory?
    @NSManaged var badgesWon: [PFObject]?
    @NSManaged var lifeLinesUsed: [String]?
    
    
    //=======================================================================================
    // MARK: PFSubclassing Protocol
    //=======================================================================================
    
    static func parseClassName() -> String {
        return "Challenge"
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
    
    //=======================================================================================
    // MARK: 
    //=======================================================================================
    
}
