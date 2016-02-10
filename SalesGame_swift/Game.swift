//
//  Game.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/5/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import Foundation
import Parse

class Game: PFObject, PFSubclassing {
    
    //=======================================================================================
    // MARK: Properties
    //=======================================================================================
    
    @NSManaged var player: PFObject!
    @NSManaged var category: PFObject!
    @NSManaged var subCategory: SubCategory!
    @NSManaged var score: NSNumber?
    @NSManaged var wld: String?
    @NSManaged var badgesWon: [Badges]?
    @NSManaged var correctAnswers: [PFObject]?
    @NSManaged var wrongAnswers: [PFObject]?
    

    //=======================================================================================
    // MARK: PFSubclassing Protocol
    //=======================================================================================
    
    static func parseClassName() -> String {
        return "Game"
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
    // MARK: Methods
    //=======================================================================================
    
    
    
    
    
    
    
}