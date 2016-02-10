//
//  StartChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/8/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import Parse

class StartChallengeViewController: UIViewController {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    var Challenge: PFObject?
    var opponent: PFObject?
    var category: Category?
    var subCategory: SubCategory?

    @IBOutlet weak var currentUserImgView: UIImageView!
    @IBOutlet weak var currentUsernameLabel: UILabel!
    @IBOutlet weak var opponentImgView: UIImageView!
    @IBOutlet weak var opponentUsernameLabel: UILabel!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        UtilityClass.setMyViewBorder(currentUserImgView, withBorder: 0, radius: 50)
        UtilityClass.setMyViewBorder(opponentImgView, withBorder: 0, radius: 50)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        displayCurrentUser()
        displayOpponent()
    }
    
    
    //==========================================================================================================================
    // MARK: Display currentUser & opponent
    //==========================================================================================================================

    func displayCurrentUser() {
        self.currentUsernameLabel.text = PFUser.currentUser()!.valueForKey("username") as? String
        
        if let file = PFUser.currentUser()!.objectForKey("profilePic") as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.currentUserImgView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting currentUser file: \(error)")
                }
            }
        } else {
            self.currentUserImgView.image = UIImage(named: "add photo-30")
        }
    }
    
    func displayOpponent() {
        self.opponentUsernameLabel.text = self.opponent!["username"] as? String
        
        if let opponentFile = self.opponent!["profilePic"] as? PFFile {
            opponentFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.opponentImgView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting opponentFile: \(error)")
                }
            }
        } else {
            self.opponentImgView.image = UIImage(named: "add photo-30")
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(home, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueQuestionChallenge" {
            if let questionChallengeVC = segue.destinationViewController as? QuestionChallengeViewController {
                
                questionChallengeVC.category = self.category
                questionChallengeVC.subCategory = self.subCategory
                questionChallengeVC.challenge = self.Challenge
                questionChallengeVC.flagForWrongAnswerpush = false
                
            } else {
                print("Error casting QuestionChallengeViewController from ")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================

    @IBAction func startButtonTapped(sender: AnyObject) {
        let challenge: PFObject = self.Challenge!
//        let currentInstallation = PFInstallation.currentInstallation()
        
        let challengeCategoryName: String = challenge.objectForKey("category")!.valueForKey("categoryName") as! String
        let condensed: String = challengeCategoryName.stringByReplacingOccurrencesOfString(" ", withString: "")
        //print("condensed = \(condensed)")
        
//        currentInstallation.addUniqueObject(condensed, forKey: "channels")
//        currentInstallation.saveInBackground()

        challenge["challengerScore"] = 0
        challenge["opponentScore"] = 0
        challenge["opponentAccepted"] = false
        challenge["cycle"] = 1 // Indicates we are cycling the first sub-set of questions (aka 1st half)
        challenge["challengeOver"] = false
        challenge["turn"] = PFUser.currentUser()!
        
        challenge.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("Successfully saved new Challenge.")
            } else {
                print("Error saving new Challenge.")
            }
        }
        
        
    }
    
    

    
}
