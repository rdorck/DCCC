//
//  FriendsViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    
    var friends: [PFObject] = []
    var pending: [PFObject] = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)

        self.tblView.addSubview(self.refreshControl)
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
     
        getPending()
    }
    
    
    //==========================================================================================================================
    // MARK: Refreshing
    //==========================================================================================================================
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        self.getPending()
        self.tblView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================
    
    func queryFriend() {
        self.friends.removeAll() // Removes the previously add objects, reduces duplication when revisiting this screen
        
        let friendQuery = PFQuery(className: "Friend")
        friendQuery.whereKey("from", equalTo: PFUser.currentUser()!)
        friendQuery.includeKey("to")
    
        friendQuery.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let temp: NSArray = success! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    self.friends.append(temp.objectAtIndex(i).objectForKey("to") as! PFObject)
                }
                
                self.tblView.reloadData()
            } else{
                print("Error queryFriend(); friendquery: \(error)")
            }
        }
        
        let query = PFQuery(className: "Friend")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.includeKey("from")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var j=0; j < temp.count; j++ {
                    self.friends.append(temp[j].objectForKey("from") as! PFObject)
                }
                //print("friends = \(self.friends)")
                
                self.tblView.reloadData()
            } else {
                print("Error in query: \(error)")
            }
        }
        //hideHud(self.view)
    }
    
    func getPending() {
        self.pending.removeAll()
        
        let query = PFQuery(className: "Friend")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.whereKey("accepted", notEqualTo: true)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.pending.append(temp[i])
                }
                //print("getPending() pending: = \(self.pending)")

                self.queryFriend()
                
            } else {
                print("Error getPending(): \(error)")
            }
        }
    }
    

    //==========================================================================================================================
    // MARK: TableDatasource & Delegate
    //==========================================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.pending.count > 0 {
//            print("# of rows getting from pending.")
//            return self.pending.count
//        } else {
//            print("# of rows getting from friends.")
//            return self.friends.count
//        }
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FriendTableViewCell
        
        if self.pending.count > 0 {
            let pender: PFObject = self.pending[indexPath.row]
            let friend: PFObject = self.friends[indexPath.row]
            
            if let from: PFObject = pender["from"] as? PFObject {
                if from == friend {
                    let fname = from["firstName"] as! String
                    let lname = from["lastName"] as! String
                    let fullName: String = fname + " " + lname
                    
                    cellIdentifier.newLabel.hidden = false
                    cellIdentifier.usernameLabel.text = from["username"] as? String
                    cellIdentifier.fullNameLabel.text = fullName
                    
                    if let fromFile = from["profilePic"] as? PFFile {
                        fromFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                            if error == nil {
                                if let imageData = imgData {
                                    cellIdentifier.friendImgView.image = UIImage(data: imageData)
                                    UtilityClass.setMyViewBorder(cellIdentifier.friendImgView, withBorder: 0, radius: 30)
                                }
                            } else {
                                print("Error getting fromFile: \(error)")
                            }
                        }
                    }
                }
            } else {
                print("Error casting 'from' as? PFObject from pender.")
            }
        } else {
            let friend: PFObject = self.friends[indexPath.row]

            let fname = friend["firstName"] as! String
            let lname = friend["lastName"] as! String
            let fullName: String! = fname + " " + lname
            
            cellIdentifier.newLabel.hidden = true
            cellIdentifier.usernameLabel.text = friend["username"] as? String
            cellIdentifier.fullNameLabel.text = fullName
            
            if let friendFile = friend["profilePic"] as? PFFile {
                friendFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            cellIdentifier.friendImgView.image = UIImage(data: imageData)
                            UtilityClass.setMyViewBorder(cellIdentifier.friendImgView, withBorder: 0, radius: 30)
                        }
                    } else {
                        print("Error getting friendFile: \(error)")
                    }
                }
            } else {
                print("Error casting friendFile.")
            }
        }
        
        return cellIdentifier
    }
    
    /*
     * If we are already friends we can push the profile page b/c no new information is being constructed.
     *  If we are NOT friends yet with a user, we present profile page modally because we may be creating new data.
     *
     *  NOTE: May change pushing to all modally because if we want to delete friends perhaps, or make posts to 
     *      thier wall etc.??
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("Visiting \(self.friends[indexPath.row].valueForKey("username") as! String) profile page.")
        
        if self.pending.count > 0 {
            let friend = self.friends[indexPath.row]
            let pender = self.pending[indexPath.row]
            let penderFrom: PFObject = pender["from"] as! PFObject
            
            print("friend = \(friend) and pender = \(pender)")
            
            if penderFrom == friend {
                /* Display alert message confirming the accepting of this challenge */
                let actionSheetController: UIAlertController = UIAlertController(title: "Accept Invite", message: "Do you want to accept friend request?", preferredStyle: .Alert)
                
                /* Create & add a NO action, erasing the challenge from database, direct back home for proper loading of indicator */
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .Cancel) { action -> Void in
                    pender.deleteInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully denied friend request.")
                            self.handleRefresh(self.refreshControl)
                           // self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            print("Error deleting friend request: \(error)")
                        }
                    }
                }
                actionSheetController.addAction(cancelAction)
                
                /* Create & add a YES Action, changing opponentAccepted = true, saving challenge, review current stats */
                let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                    pender["accepted"] = true
                    pender.saveInBackgroundWithBlock{ (success, error) -> Void in
                        if error == nil {
                            print("Successfully saved friendship.")
                            self.performSegueWithIdentifier("segueFriendProfile", sender: self)
                        } else {
                            print("Error saving friendship: \(error)")
                        }
                    }
                }
                actionSheetController.addAction(acceptAction)
                
                self.presentViewController(actionSheetController, animated: true, completion: nil)
            }else {
                performSegueWithIdentifier("segueFriendProfile", sender: self)
            }

        } else {
            performSegueWithIdentifier("segueFriendProfile", sender: self)
        }
        
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFriendProfile" {
            if let indexPath = tblView.indexPathForSelectedRow {
                
                let friend: PFObject = self.friends[indexPath.row]
                
                if let friendProfile = segue.destinationViewController as? FriendProfileViewController {
                    friendProfile.friend = friend
                    friendProfile.addButton.enabled = false
                }
            }
        }
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    
    
    
}
