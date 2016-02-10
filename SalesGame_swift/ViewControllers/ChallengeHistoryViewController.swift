//
//  ChallengeHistoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/10/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class ChallengeHistoryViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var tblView: UITableView!
    
    //var challenges: [Challenge] = []
    var challenges: [PFObject] = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.addSubview(self.refreshControl)
        
        getChallenges()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //getChallenges()
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
        
        self.getChallenges()
        self.tblView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================

    func getChallenges() {
        self.challenges.removeAll()
        
        //let queryChallenges = Challenge.query()
        /* NOTE: might have just needed to call Challenge.fetchIfNeeded() */
        
        let queryChallenges = PFQuery(className: "Challenge")
        queryChallenges.whereKey("challenger", equalTo: PFUser.currentUser()!)
        
        //let queryChallenged = Challenge.query()
        let queryChallenged = PFQuery(className: "Challenge")
        queryChallenged.whereKey("opponent", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([queryChallenges, queryChallenged])
        query.includeKey("challenger")
        query.includeKey("opponent")
        query.includeKey("category")
        query.includeKey("subCategory")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
//                let temp: [Challenge] = objects! as! [Challenge]
//                PFObject.pinAllInBackground(temp)
//                for var i=0; i < temp.count; i++ {
//                    let CH: Challenge = temp[i]
//                    self.challenges.append(CH)
//                }
                
                let temp: NSArray = objects! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    let challenge: PFObject = temp[i] as! PFObject
                    self.challenges.append(challenge)
                }
                
                //print("challenges as PFObjects = \(self.challenges)")
                
                self.tblView.reloadData()
                
            } else {
                print("Error finding objects in query: \(error)")
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
        return self.challenges.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ChallengeTableViewCell
        
        let challenge: PFObject = self.challenges[indexPath.row]
        let challenger = challenge["challenger"] as! PFObject
        let opponent = challenge["opponent"] as! PFObject
        let currentUser = PFUser.currentUser()
        
        /* You are the opponent (ie. someone challenged you) so we change the display to display the challenger in the row */
        if opponent["username"] as? String == currentUser?.username {
            cell.opponentUsernameLabel?.text = challenger.valueForKey("username") as? String
            
            if let file = challenger["profilePic"] as? PFFile {
                file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            cell.opponentImgView.image = UIImage(data: imageData)
                        }
                    } else {
                        print("Error getting file: \(error)")
                    }
                }
            } else {
                cell.opponentImgView.image = UIImage(named: "add photo-30")
            }
            UtilityClass.setMyViewBorder(cell.opponentImgView, withBorder: 0, radius: 25)
            
            if challenge["opponentAccepted"] === false {
                cell.newLabel.text = "NEW"
            } else {
                cell.newLabel.text = " "
            }
            
            if currentUser! == opponent && challenge["turn"] === opponent {
                cell.turnLabel.text = "Your turn"
                cell.turnLabel.textColor = UIColor.greenColor()
            } else if currentUser! == opponent && challenge["turn"] === challenger {
                cell.turnLabel.text = "Their turn"
                cell.turnLabel.textColor = UIColor.redColor()
            }
            
        } else {
            /* You are the challenger, display the opponent in row */
            cell.opponentUsernameLabel?.text = opponent.valueForKey("username") as? String
            
            if let file = opponent["profilePic"] as? PFFile {
                file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            cell.opponentImgView.image = UIImage(data: imageData)
                        }
                    } else {
                        print("Error getting challenge file: \(error)")
                    }
                }
            } else {
                cell.opponentImgView.image = UIImage(named: "add photo-30")
            }
            UtilityClass.setMyViewBorder(cell.opponentImgView, withBorder: 0, radius: 25)
            
            if currentUser! == challenger && challenge["turn"] === challenger {
                cell.turnLabel.text = "Your turn"
                cell.turnLabel.textColor = UIColor.greenColor()
            } else if currentUser! == challenger && challenge["turn"] === opponent {
                cell.turnLabel.text = "Their turn"
                cell.turnLabel.textColor = UIColor.redColor()
            }
            
            cell.newLabel.hidden = true
        }
        
        if challenge["challengeOver"] === true {
            cell.turnLabel.text = "Completed"
            cell.turnLabel.textColor = UIColor.greenColor()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let challenge: PFObject = self.challenges[indexPath.row]
        let opponent = challenge["opponent"]
        
        /* Display alert message confirming the accepting of this challenge */
        let actionSheetController: UIAlertController = UIAlertController(title: "Accept Invite", message: "Do you want to accept this challenge?", preferredStyle: .Alert)
        
        /* Create & add a NO action, erasing the challenge from database, direct back home for proper loading of indicator */
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .Cancel) { action -> Void in
            challenge.deleteInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully denied challenge.")
                    self.handleRefresh(self.refreshControl)
//                    let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
//                    let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
//                    swReveal.pushFrontViewController(homeVC, animated: true)
//                    self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
                } else {
                    print("Error deleting denied challenge: \(error)")
                }
            }
        }
        actionSheetController.addAction(cancelAction)
        
        /* Create & add a YES Action, changing opponentAccepted = true, saving challenge, review current stats */
        let acceptAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            challenge["opponentAccepted"] = true
            challenge.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully accepted challenge.")
                    self.performSegueWithIdentifier("segueResumeChallenge", sender: self)
                } else {
                    print("Error accepting challenge: \(error)")
                }
            }
        }
        actionSheetController.addAction(acceptAction)
        
        /* currentUser is the opponent, we must (accept||deny) the challenge.
         *  If we have not accepted it, present actionSheetController to confirm invitation.
         *  If we have already accpeted the invitation, present ResumeChallengeViewController.
         */
        if challenge["opponentAccepted"] === false && opponent === PFUser.currentUser()! {
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
        /* If we are the challenger, no need to confirm any invitation */
        performSegueWithIdentifier("segueResumeChallenge", sender: self)
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueResumeChallenge" {
            if let indexPath = tblView.indexPathForSelectedRow {
                let navController = segue.destinationViewController as! UINavigationController
                if let resumeChallengeVC = navController.topViewController as? ResumeChallengeViewController {
                    
                    let challenge: PFObject = self.challenges[indexPath.row]
                    
                    resumeChallengeVC.challenge = challenge
                    
                } else {
                    print("Error casting ResumeChallengeViewController from ChallengeHistoryViewController.")
                }
            }
        }
    }
    
   
    
    

}
