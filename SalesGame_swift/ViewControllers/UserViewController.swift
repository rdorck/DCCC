//
//  UserViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==============================================================================================================
    // MARK: Properties
    //==============================================================================================================
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    
    var friends: [PFObject] = []
    var friendIds: [String] = []
    var available: [PFObject] = []
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)

        self.tblView.addSubview(self.refreshControl)
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getAllNonFriends()
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
        
        self.getAllNonFriends()
        self.tblView.reloadData()
        refreshControl.endRefreshing()
    }

    
    //==============================================================================================================
    // MARK: Querying
    //==============================================================================================================
    
    func getAllNonFriends() {
        let currentUser = PFUser.currentUser()!
        
        let queryFriendsFromCurrentUser = PFQuery(className: "Friend")
        queryFriendsFromCurrentUser.whereKey("from", equalTo: currentUser)
        
        let queryFriendsToCurrentUser = PFQuery(className: "Friend")
        queryFriendsToCurrentUser.whereKey("to", equalTo: currentUser)
        
        let queryAllFriends = PFQuery.orQueryWithSubqueries([queryFriendsFromCurrentUser, queryFriendsToCurrentUser])
        queryAllFriends.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]

                for var i=0; i < temp.count; i++ {
                    self.friends.append(temp[i])
                    self.friendIds.append(temp[i].objectForKey("from")!.objectId!!)
                    self.friendIds.append(temp[i].objectForKey("to")!.objectId!!)
                }
                //print("friends = \(self.friends)")
                //print("friendIds = \(self.friendIds)")
                
                self.getRest()

            } else {
                print("Error finding all friends queryAllFriends(): \(error)")
            }
        }
    }

    func getRest() {
        let queryUsers = PFUser.query()
        queryUsers?.whereKey("objectId", notContainedIn: self.friendIds)
        queryUsers?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    if temp[i] != PFUser.currentUser()! {
                        self.available.append(temp[i])
                    }
                }
                //print("available = \(self.available)")
                
                self.tblView.reloadData()

            } else {
                print("Error queryUsers(): \(error)")
            }
        }
//        hideHud(self.view)
    }
        
    
    //==============================================================================================================
    // MARK: TableDatasource & Delegate
    //==============================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.available.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserTableViewCell
        
        if let user: PFObject = self.available[indexPath.row] {
            
            let fname = user.valueForKey("firstName") as? String
            let lname = user.valueForKey("lastName") as? String
            let fullName: String? = fname! + " " + lname!
            let uname = user.valueForKey("username") as? String
            
            cell.fullNameLabel.text = fullName
            cell.usernameLabel.text = uname
            
            if let file = user["profilePic"] as? PFFile {
                file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            cell.imgView.image = UIImage(data: imageData)
                            UtilityClass.setMyViewBorder(cell.imgView, withBorder: 0, radius: 30)
                        }
                    } else {
                        print("Error getting user file: \(error)")
                    }
                }
            } else {
                cell.imgView.image = UIImage(named: "add photo-30")
            }
            
        } else {
            print("No user found.")
            cell.fullNameLabel.text = "No name"
            cell.usernameLabel.text = "No username"
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Visiting \(self.available[indexPath.row].valueForKey("username") as! String) profile page.")
        performSegueWithIdentifier("segueAddUserProfile", sender: self)
    }
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueAddUserProfile" {
            if let indexPath = tblView.indexPathForSelectedRow {
                let user = self.available[indexPath.row]
                
                let navController = segue.destinationViewController as! UINavigationController
                if let userProfile = navController.topViewController as? FriendProfileViewController {
                    userProfile.user = user
                }
                
            } else {
                print("Error with indexPath")
            }
        }
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
     }

    
    //==============================================================================================================
    // MARK: Progress Hud
    //==============================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
}
