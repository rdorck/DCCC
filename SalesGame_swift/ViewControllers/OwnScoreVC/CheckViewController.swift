//
//  CheckViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/30/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class CheckViewController: UIViewController {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        checkApprentice()
        checkVeteran()
        checkCrusader()
        checkMasterOfDisaster()
    }

    
    //==========================================================================================================================
    // MARK: Check if Badge earned
    //==========================================================================================================================

    /*
     * Checks if currentUser has already earned a specific badge. Passed in 
     *  by earnBadgeName: String
     */
    func earned(earnBadgeName: String) -> Bool {
        let query = PFQuery(className: "UserBadges")
        query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
        query.whereKey("badgeName", equalTo: earnBadgeName)
        if query.countObjects() > 0 {
            print("Already earned \(earnBadgeName)")
            return true
        } else {
            print("Have not earned \(earnBadgeName) yet")
            return false
        }
    }
    
    /* 
     * Function to add badge after confirming it was earned &
     *  currentUser did not already have it (!=)
     */
    func addBadge(addBadgeName: String){
        print("Adding badge: \(addBadgeName)")
        let UserBadge = PFObject(className: "UserBadges")
        let query = PFQuery(className: "Badges")
        query.whereKey("badgeName", equalTo: addBadgeName)
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil{
                print("Badge found: \(objects)")
                
                UserBadge["badgeName"] = addBadgeName
                UserBadge["createdBy"] = PFUser.currentUser()
                UserBadge["badge"] = objects![0]
                UserBadge.saveInBackgroundWithBlock{ (success, error) -> Void in
                    if error == nil {
                        print("Badge \(addBadgeName) successfully saved!")
                    } else{
                        print("Error saving badge \(addBadgeName): \(error)")
                    }
                }
            } else{
                print("Error addBadge(\(addBadgeName)): \(error)")
            }
        }
    }
    
    /* 
     * Practice makes prefect and playing 50 matches is not for the faint at heart.
     *  Keep sharpening your skills and making your boss proud. You got this!
     */
    func checkApprentice() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 50 {
                    if !self.earned("The Apprentice") {
                        self.addBadge("The Apprentice")
                    }
                } else {
                    print("\(50 - count) games left until earning The Apprentice, but here is a test run.")
                    self.addBadge("The Apprentice")
                }
            } else {
                print("Error checkApprentince(): \(error)")
            }
        }
    }
    
    /* You may or may not have served in any wars but playing 100 matches
     *  deserves some recognition in our book.
     *  The Digital War Heroes salute you.
     */
    func checkVeteran() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 100 {
                    if !self.earned("The Veteran") {
                        self.addBadge("The Veteran")
                    }
                } else {
                    print("\(100 - count) games left until earning The Veteran.")
                }
            } else {
                print("Error checkVeteran(): \(error)")
            }
        }
    }
    
    /* A sword and shield may not be part of your usual work attire
     *  but you’re for sure making moves with playing 200 matches!
     */
    func checkCrusader() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 200 {
                    if !self.earned("The Crusader") {
                        self.addBadge("The Crusader")
                    }
                } else {
                    print("\(200 - count) games left until earning The Crusader.")
                }
            } else {
                print("Error checkCrusader(): \(error)")
            }
        }
    }
    
    /* 
     * Do you know that saying about losing a game 5 times in a row?
     *  Yeah, we don’t either. Hold your head up high though,
     *      change is a coming (hopefully).
     */
    func checkMasterOfDisaster() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.addDescendingOrder("createdAt")
        query.limit = 5
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    if temp.objectAtIndex(i).valueForKey("WLD") as! String != "L" {
                        print("Non loss status, not a Master of Disaster.")
                    } else {
                        if !self.earned("Master of Disaster") {
                            self.addBadge("Master of Disaster")
                        }
                    }
                }
            } else {
                print("Error checkMasterOfDisaster() query: \(error)")
            }
        }
    }

    func checkIntern() {
        
    }
    
    
    func checkGameCount() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                switch count {
                case 50...99:
                    print("You played \(count) games & earned The Apprentice.")
                    if !self.earned("The Apprentice") {
                        self.addBadge("The Apprentice")
                    }
                case 100...199:
                    print("You played \(count) games & earned The Veteran.")
                    if !self.earned("The Veteran") {
                        self.addBadge("The Veteran")
                    }
                case 200...299:
                    print("You played \(count) games & earned The Crusader.")
                    if !self.earned("The Crusader") {
                        self.addBadge("The Crusader")
                    }
                default:
                    break
                }
            } else {
                print("Error checkGameCount(): \(error)")
            }
        }
    }

}
