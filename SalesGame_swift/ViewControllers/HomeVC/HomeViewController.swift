//
//  HomeViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/11/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {

    //======================================================================================================================
    // MARK: Properties
    //======================================================================================================================

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var btnScore : UIButton!
    @IBOutlet var btnLogout : UIButton!
    @IBOutlet weak var btnChallenge: UIButton!
    @IBOutlet weak var newChallengeLabel: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView?
    
    var emailObj: AnyObject?

    
    //======================================================================================================================
    // MARK: Lifecycle
    //======================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)

        navigationItem.title = "Home"
        self.newChallengeLabel.text = ""
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        displayUserImg()
        checkNewChallenges()

    }
    
    
    //=====================================================================================================================
    // MARK: Methods
    //=====================================================================================================================
    
    /*
     *  Retrieve user's profile pic and display it
     */
    func displayUserImg(){
        if let currentUser = PFUser.currentUser() {
            if let file: PFFile = currentUser["profilePic"] as? PFFile {
                file.getDataInBackgroundWithBlock({
                    (imageData, error) -> Void in
                    if error == nil {
                        let Image: UIImage = UIImage(data: imageData!)!

                        self.profilePic!.image = Image
                        UtilityClass.setMyViewBorder(self.profilePic, withBorder: 0, radius: 75)
                        
                        hideHud(self.view)
                    } else {
                        print("Error \(error)")
                    }
                })
            }
        } else {
            print("Error at Home, seems there is no currentUser.")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    } // END of displayUserImg()
    
    func checkNewChallenges() {
        let queryChallenge = PFQuery(className: "Challenge")
        queryChallenge.whereKey("opponent", equalTo: PFUser.currentUser()!)
        queryChallenge.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    let challenge: PFObject = temp[i]
                    if let accepted = challenge["opponentAccepted"] {
                        if accepted as! NSObject == false {
                            self.newChallengeLabel.text = "\(i + 1) new"
                        }
                    } else {
                        print("Error challenge has no opponentAccepted status.")
                    }
                }
                
            } else {
                print("Error checkNewChallenges() - finding challenges: \(error)")
            }
        }
        hideHud(self.view)
    }
    
//    func checkNewFriendRequests() {
//        let queryFriend = PFQuery(className: "Friend")
//        queryFriend.whereKey("to", equalTo: PFUser.currentUser()!)
//        queryFriend.whereKey("accepted", notEqualTo: true)
//        queryFriend.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
//            if error == nil {
//                let temp: [PFObject] = requests! as! [PFObject]
//                
//                for var i=0; i < temp.count; i++ {
//                    let friendship: PFObject = temp[i]
//                    if let request = friendship["accepted"] {
//                        if request as! NSObject != true {
//                            self.newFriendRequestsLabel.text = "\(i + 1)"
//                        }
//                    } else {
//                        print("Error friend has no requested status.")
//                    }
//                }
//                
//            } else {
//                print("Error getting friend request: \(error)")
//            }
//        }
//    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    @IBAction func btnLeader(sender: UIButton) {
       let highScoreVC = self.storyboard?.instantiateViewControllerWithIdentifier("HighScoreViewController") as! HighScoreViewController
        self.navigationController!.pushViewController(highScoreVC, animated: true)
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOutInBackground()
        let navController = self.storyboard?.instantiateInitialViewController()
        self.navigationController?.presentViewController(navController!, animated: true, completion: nil)
    }
    
    @IBAction func unwindToHomeFromSettings(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? SettingViewController, email = sourceViewController.email {
            
            // If email isn't empty, user wants to reset password
            let queryEmails = PFUser.query()
            queryEmails?.whereKey("email", equalTo: email)
            queryEmails?.findObjectsInBackgroundWithBlock{
                (emailObjects, error) -> Void in
                if error == nil {
                    self.emailObj = emailObjects
                    let obj:PFObject = (self.emailObj as! Array)[0];
                    
                    PFUser.requestPasswordResetForEmailInBackground(obj.objectForKey("email") as! String)
                }
                else {
                    print("Error in queryEmails: \(error)")
                }
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }

}
