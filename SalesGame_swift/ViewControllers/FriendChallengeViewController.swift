//
//  FriendChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/7/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class FriendChallengeViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    var friends: [PFObject] = []
    
    var Challenge: PFObject?
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getFriends()
    }
    
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================
    
    func getFriends() {
        self.friends.removeAll()
        
        let queryFriends = PFQuery(className: "Friend")
        queryFriends.whereKey("from", equalTo: PFUser.currentUser()!)
        queryFriends.includeKey("to")
        queryFriends.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let temp: NSArray = success! as NSArray

                for var i=0; i < temp.count; i++ {
                    self.friends.append(temp.objectAtIndex(i).objectForKey("to") as! PFObject)
                }
                
                //print("friends[] : \(self.friends)")
                self.tblView.reloadData()
            } else{
                print("Error getFriends(); queryFriends: \(error)")
            }
        }
        
        let queryFriendsTo = PFQuery(className: "Friend")
        queryFriendsTo.whereKey("to", equalTo: PFUser.currentUser()!)
        queryFriendsTo.includeKey("from")
        queryFriendsTo.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let temp: NSArray = success! as NSArray
                
                for var j=0; j < temp.count; j++ {
                    self.friends.append(temp.objectAtIndex(j).objectForKey("from") as! PFObject)
                }
                
                self.tblView.reloadData()
                
            } else {
                print("Error queryFriendsTo: \(error)")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Table Datasource & Delegate
    //==========================================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("#OfRowsInSection friends = \(self.friends.count)")
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? FriendTableViewCell{
            
            let friend: PFObject = self.friends[indexPath.row]
            
            let fname = friend.valueForKey("firstName") as? String
            let lname = friend.valueForKey("lastName") as? String
            let fullName: String = fname! + " " + lname!
            
            cell.usernameLabel.text = friend.valueForKey("username") as? String
            cell.fullNameLabel.text = fullName
            
            if let friendFile = friend.valueForKey("profilePic") as? PFFile {
                friendFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            cell.friendImgView.image = UIImage(data: imageData)
                        }
                    } else {
                        print("Error getting friendFile: \(error)")
                    }
                }
            } else {
                cell.friendImgView.image = UIImage(named: "add photo-30")
            }
            
            return cell
        } else {
            let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.textLabel?.text = "No Friend"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected friend at indexPath.row = \(indexPath.row)")
        //performSegueWithIdentifier("segueChallengeCategory", sender: self)
    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
        self.navigationController?.pushViewController(homeVC!, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueChallengeCategory" {
            if let categoryChallengeVC = segue.destinationViewController as? CategoryChallengeViewController {
                if let selectedOpponentCell = sender as? FriendTableViewCell {
                    let indexPath = self.tblView.indexPathForCell(selectedOpponentCell)!
                    
                    let opponent: PFObject = self.friends[indexPath.row]
                    
                    let challenge = PFObject(className: "Challenge")
                    challenge["challenger"] = PFUser.currentUser()!
                    challenge["opponent"] = opponent
                    self.Challenge = challenge
                    categoryChallengeVC.Challenge = challenge
                    categoryChallengeVC.opponent = opponent
                    print("Challenge created")
                    
//                    challenge.saveInBackgroundWithBlock { (success, error) -> Void in
//                        if error == nil {
//                            print("Challenge successfully created.")
//                            categoryChallengeVC.Challenge = challenge
//                        } else {
//                            print("Error saving challenge: \(error)")
//                        }
//                    }
                }
            } else {
                print("Error casting CategoryChallengeViewController from FriendChallengeViewController.")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK:
    //==========================================================================================================================
    
    
    
    
    
   
}
