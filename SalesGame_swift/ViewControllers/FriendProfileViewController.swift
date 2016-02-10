//
//  FriendProfileViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import Parse

class FriendProfileViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    var friend: PFObject?
    var user: PFObject?
    
    var userObjects: [PFObject] = []
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Will enable or disable addButton depending if currentUser is already Friends w/ selected User */
        checkFriendship()
        
        if friend != nil {
            self.navigationItem.title = self.friend!.valueForKey("username") as? String
            displayImg()
        }
    
        if user != nil {
            self.navigationItem.title = self.user!.valueForKey("username") as? String
            displayImg()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    //==========================================================================================================================
    // MARK: Methods
    //==========================================================================================================================
    
    func displayImg() {
        if let file = self.friend?.valueForKey("profilePic") as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.imgView.image = UIImage(data: imageData)
                    }
                } else{
                    print("Error FriendProfile displayImg(): \(error)")
                }
            }
        } else if let file = self.user?.valueForKey("profilePic") as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.imgView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error displayImg() else if let file: \(error)")
                }
            }
        }
    }
    
    func checkFriendship() {
        let query = PFQuery(className: "Friend")
        query.whereKey("from", equalTo: PFUser.currentUser()!)
        query.includeKey("to")
        query.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let temp: NSArray = success! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    self.userObjects.append(temp.objectAtIndex(i).objectForKey("to") as! PFObject)
                }
                //print("checkFriendship() userObjects = \(self.userObjects)")
    
            } else {
                print("Error checkFriendship(): \(error)")
            }
        }
        
        let queryFriends = PFQuery(className: "Friend")
        queryFriends.whereKey("to", equalTo: PFUser.currentUser()!)
        queryFriends.includeKey("from")
        queryFriends.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var j=0; j < temp.count; j++ {
                    self.userObjects.append(temp[j].objectForKey("from") as! PFObject)
                }
                
                if self.user != nil {
                    for user in self.userObjects {
                        if user == self.user {
                            print("User Match, you're friends with \(user)")
                            self.addButton.enabled = false
                        } else {
                            print("User No Match")
                        }
                    }
                } else if self.friend != nil {
                    for user in self.userObjects {
                        if user == self.friend {
                            print("Friend Match, you're friends with \(user)")
                            self.addButton.enabled = false
                        } else {
                            print("Friend No Match")
                        }
                    }
                }
            } else {
                print("Error finding more friends: \(error)")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if self.friend != nil {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        print("Checking friendship.")
        checkFriendship()
        let newFriend = PFObject(className: "Friend")
        newFriend["from"] = PFUser.currentUser()!
        
        if self.user != nil {
            newFriend["to"] = self.user
            newFriend["accepted"] = false
        } else if self.friend != nil {
            newFriend["to"] = self.friend
        }
        
        newFriend.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("Successfully requested newFriend.")
                self.addButton.enabled = false
            } else {
                print("Error saving newFriend: \(error)")
            }
        }
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    

}
