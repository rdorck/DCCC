//
//  Question.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/5/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import Foundation
import Parse

class Question: PFObject, PFSubclassing {
    
    //=======================================================================================
    // MARK: Properties
    //=======================================================================================
    
    @NSManaged var parentCategory: PFObject!
    @NSManaged var parentSubCategory: PFObject?
    @NSManaged var questionFile: PFFile?
    @NSManaged var difficulty: String?
    @NSManaged var questionText: String!
    @NSManaged var answer: String!
    @NSManaged var options: [String]?
    @NSManaged var mostCorrect: String?
    @NSManaged var partialCorrect: String?
    @NSManaged var partialWrong: String?
    @NSManaged var mostWrong: String?
    
    var image: UIImage?
    
    var optionA: String {
        if options?.count > 0 {
            return options![0]
        }
        return options![0]
    }


    //=======================================================================================
    // MARK: PFSubclassing Protocol
    //=======================================================================================
    static func parseClassName() -> String {
        return "Question"
    }
    
    override init(){
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
