//
//  ScoreChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/10/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class ScoreChallengeViewController: UIViewController, UINavigationControllerDelegate {

    //====================================================================================================================
    // MARK: Properties
    //====================================================================================================================
    
    @IBOutlet weak var homeButton: UIButton!
    
    // Challenger Display Outlets
    @IBOutlet weak var challengerUsernameLabel: UILabel!
    @IBOutlet weak var challengerImgView: UIImageView!
    @IBOutlet weak var challengerScoreLabel: UILabel!
    @IBOutlet weak var challengerFiftyFiftyIcon: UIImageView!
    @IBOutlet weak var challengerHintIcon: UIImageView!
    @IBOutlet weak var challengerStopwatchIcon: UIImageView!
    
    // Opponent Display Outlets
    @IBOutlet weak var opponentUsernameLabel: UILabel!
    @IBOutlet weak var opponentImgView: UIImageView!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentFiftyFiftyIcon: UIImageView!
    @IBOutlet weak var opponentHintIcon: UIImageView!
    @IBOutlet weak var opponentStopwatchIcon: UIImageView!

    @IBOutlet weak var turnStatusBar: UILabel!
    
    // Custom Objects
    var category: Category?
    var subCategory: SubCategory?
    var challenge: PFObject?
    
    
    //====================================================================================================================
    // MARK: Lifecycle
    //====================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
//        let accepted = self.challenge!["opponentAccepted"]
//        if accepted === false {
//            displayNotification()
//        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        displayChallenger()
        displayOpponent()

        
        UtilityClass.setMyViewBorder(self.challengerFiftyFiftyIcon, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.challengerHintIcon, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.challengerStopwatchIcon, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentFiftyFiftyIcon, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentHintIcon, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentStopwatchIcon, withBorder: 0, radius: 25)
        
        UtilityClass.setMyViewBorder(self.challengerImgView, withBorder: 0, radius: 50)
        UtilityClass.setMyViewBorder(self.opponentImgView, withBorder: 0, radius: 50)

        
    }
    
    
    //==========================================================================================================================
    // MARK: Display Challenger & Opponent
    //==========================================================================================================================

    func displayChallenger() {
        let challenger = self.challenge!["challenger"]
        
        self.challengerUsernameLabel.text = challenger!["username"] as? String
        self.challengerScoreLabel.text = "\(self.challenge!["challengerScore"]!)"
        self.turnStatusBar.text = "Challenge sent ... "
        self.turnStatusBar.textColor = UIColor.greenColor()
        
        if let file = challenger!["profilePic"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.challengerImgView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting challenger file: \(error)")
                }
            }
        } else {
            self.challengerImgView.image = UIImage(named: "add photo-30")
        }
        
        if let lifeLines = self.challenge!["challengerLifeLinesUsed"] {
            for var i=0; i < lifeLines.count; i++ {
                if lifeLines[i] == "50-50" {
                    self.challengerFiftyFiftyIcon.image = UIImage(named: "used fiftyfifty icon")
                    self.challengerFiftyFiftyIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.challengerFiftyFiftyIcon.backgroundColor = UIColor.greenColor()
                }
                
                if lifeLines[i] == "Hint" {
                    self.challengerHintIcon.image = UIImage(named: "used hint icon")
                    self.challengerHintIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.challengerHintIcon.backgroundColor = UIColor.greenColor()
                }
                
                if lifeLines[i] == "Pause" {
                    self.challengerStopwatchIcon.image = UIImage(named: "used stopwatch icon")
                    self.challengerStopwatchIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.challengerStopwatchIcon.backgroundColor = UIColor.greenColor()
                }
            }
        }
        else {
            // LifeLines was empty, indicating they haven't been used yet, therefore they must be available.
            self.challengerFiftyFiftyIcon.backgroundColor = UIColor.greenColor()
            self.challengerHintIcon.backgroundColor = UIColor.greenColor()
            self.challengerStopwatchIcon.backgroundColor = UIColor.greenColor()
        }

    }
    
    func displayOpponent() {
        let oppont = self.challenge!["opponent"] as! PFObject
        
        self.opponentUsernameLabel.text = oppont["username"] as? String
        self.opponentScoreLabel.text = "\(self.challenge!["opponentScore"]!)"
        
        if let file = oppont["profilePic"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.opponentImgView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting opponent file: \(error)")
                }
            }
        } else {
            self.opponentImgView.image = UIImage(named: "add photo-30")
        }
        
        if let oppontLifeLines = self.challenge!["opponentLifeLinesUsed"] {
            
            for var i=0; i < oppontLifeLines.count; i++ {
                if oppontLifeLines[i] == "50-50" {
                    self.opponentFiftyFiftyIcon.image = UIImage(named: "used fiftyfifty icon")
                    self.opponentFiftyFiftyIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.opponentFiftyFiftyIcon.backgroundColor = UIColor.greenColor()
                }
                
                if oppontLifeLines[i] == "Hint" {
                    self.opponentHintIcon.image = UIImage(named: "used hint icon")
                    self.opponentHintIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.opponentHintIcon.backgroundColor = UIColor.greenColor()
                }
                
                if oppontLifeLines[i] == "Pause" {
                    self.opponentStopwatchIcon.image = UIImage(named: "used stopwatch icon")
                    self.opponentStopwatchIcon.backgroundColor = UIColor.clearColor()
                } else {
                    self.opponentStopwatchIcon.backgroundColor = UIColor.greenColor()
                }
            }
        } else {
            // The opponent has only been sent a request for the challenge, so we can just display lifelines as available
            self.opponentFiftyFiftyIcon.backgroundColor = UIColor.greenColor()
            self.opponentHintIcon.backgroundColor = UIColor.greenColor()
            self.opponentStopwatchIcon.backgroundColor = UIColor.greenColor()
        }
        //hideHud(self.view)

    }
    
    func displayNotification() {
        let oppnt = self.challenge!["opponent"] as! PFObject
        let opponentUsername: String = oppnt["username"] as! String
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Challenge Sent", message: "\(opponentUsername) has been challenged !", preferredStyle: .Alert)
        
        /* Create an Ok action that will represent the view upon being tapped */
        let okayAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            //self.viewDidAppear(true)
        
        }
        actionSheetController.addAction(okayAction)
        
        presentViewController(actionSheetController, animated: true, completion: nil)
    
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swRevealVC = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swRevealVC.pushFrontViewController(homeVC, animated: true)
        
        self.navigationController?.presentViewController(swRevealVC, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Progress Hud
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }

    

    
    
    
}
