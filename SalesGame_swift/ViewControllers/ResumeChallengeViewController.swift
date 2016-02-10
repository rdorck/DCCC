//
//  ResumeChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/11/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class ResumeChallengeViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    var challenge: PFObject?
    var cycle: Int?
    
    // Turn Status-Bar Outlets
    @IBOutlet weak var turnStatusLabel: UILabel!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    
    // Challenger Outlets
    @IBOutlet weak var challengerUsernameLabel: UILabel!
    @IBOutlet weak var challengerImgView: UIImageView!
    @IBOutlet weak var challengerScore: UILabel!
    @IBOutlet weak var challengerFiftyLifelineImgView: UIImageView!
    @IBOutlet weak var challengerHintLifeLineImgView: UIImageView!
    @IBOutlet weak var challengerStopwatchLifelineImgView: UIImageView!
    
    // Opponent Outlets
    @IBOutlet weak var opponentUsernameLabel: UILabel!
    @IBOutlet weak var opponentImgView: UIImageView!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentFiftyLifelineImgView: UIImageView!
    @IBOutlet weak var opponentHintLifeLineImgView: UIImageView!
    @IBOutlet weak var opponentStopwatchLifelineImgView: UIImageView!
    
    // Buttons
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resumeButton.enabled = false
        
        getTurn()
        
        self.cycle = self.challenge!["cycle"] as? Int
        print("cycle = \(self.cycle!)")
        
        UtilityClass.setMyViewBorder(self.challengerFiftyLifelineImgView, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.challengerHintLifeLineImgView, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.challengerStopwatchLifelineImgView, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentFiftyLifelineImgView, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentHintLifeLineImgView, withBorder: 0, radius: 25)
        UtilityClass.setMyViewBorder(self.opponentStopwatchLifelineImgView, withBorder: 0, radius: 25)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Is it better to check who is an opponent & challenger first, then display data given a PFUser?
         *
        let opponent = self.challenge!["opponent"]
        let challenger = self.challenge!["challenger"]
        
        if opponent!["username"] as? String == PFUser.currentUser()!.username {
            displayOpponent(PFUser.currentUser()!)
        } else {
            displayOpponent(opponent as? PFUser)
        }
        
        if challenger!["username"] as? String == PFUser.currentUser()!.username {
            displayChallenger(PFUser.currentUser()!)
        } else {
            displayChallenger(challenger as? PFUser)
        }
        */
        
        displayChallenger()
        displayOpponent()
        if isChallengeOver() {
            self.turnStatusLabel.text = "Challenge Complete"
            self.turnStatusLabel.textColor = UIColor.yellowColor()
            self.resumeButton.enabled = false
        }
        
    }
    
    
    //==========================================================================================================================
    // MARK: Updating Turn Status bar
    //==========================================================================================================================
    
    func getTurn() {
        let challenger = self.challenge!["challenger"] as! PFObject
        let opponent = self.challenge!["opponent"] as! PFObject
        let currentUser = PFUser.currentUser()!
        
        if let turn = self.challenge!["turn"] {
            if turn === challenger {
                if challenger === currentUser {
                    self.turnStatusLabel.text = "Your turn !"
                    self.turnStatusLabel.textColor = UIColor.greenColor()
                    self.resumeButton.enabled = true
                } else {
                    self.turnStatusLabel.text = "Their turn ..."
                    self.turnStatusLabel.textColor = UIColor.redColor()
                }
            } else {
                if opponent === currentUser {
                    self.turnStatusLabel.text = "Your turn !"
                    self.turnStatusLabel.textColor = UIColor.greenColor()
                    self.resumeButton.enabled = true
                } else {
                    self.turnStatusLabel.text = "Their turn ..."
                    self.turnStatusLabel.textColor = UIColor.redColor()
                }
            }
        } else {
            print("Error casting turn from the challenge.")
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Displaying Challenger & Opponent
    //==========================================================================================================================
    
    func displayChallenger() {
        if let challenger = self.challenge!["challenger"] {
            self.challengerUsernameLabel.text = challenger["username"] as? String
            self.challengerScore.text = "\(self.challenge!["challengerScore"]!)"
            
            if let challengerFile = challenger["profilePic"] as? PFFile {
                challengerFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            self.challengerImgView.image = UIImage(data: imageData)
                            UtilityClass.setMyViewBorder(self.challengerImgView, withBorder: 0, radius: 50)
                        }
                    } else {
                        print("Error getting challengerFile: \(error)")
                    }
                }
            } else {
                self.challengerImgView.image = UIImage(named: "add photo-30")
            }
            
            //self.checkLifeLines()
            if let challengerLifeLines = self.challenge!["challengerLifeLinesUsed"] {
                for var i=0; i < challengerLifeLines.count; i++ {
                    if challengerLifeLines[i] == "50-50" {
                        self.challengerFiftyLifelineImgView.image = UIImage(named: "used fiftyfifty icon")
                        self.challengerFiftyLifelineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.challengerFiftyLifelineImgView.backgroundColor = UIColor.greenColor()
                    }
                    
                    if challengerLifeLines[i] == "Hint" {
                        self.challengerHintLifeLineImgView.image = UIImage(named: "used hint icon")
                        self.challengerHintLifeLineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.challengerHintLifeLineImgView.backgroundColor = UIColor.greenColor()
                    }
                    
                    if challengerLifeLines[i] == "Pause" {
                        self.challengerStopwatchLifelineImgView.image = UIImage(named: "used stopwatch icon")
                        self.challengerStopwatchLifelineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.challengerStopwatchLifelineImgView.backgroundColor = UIColor.greenColor()
                    }
                }
                
            } else {
                self.challengerFiftyLifelineImgView.backgroundColor = UIColor.greenColor()
                self.challengerHintLifeLineImgView.backgroundColor = UIColor.greenColor()
                self.challengerStopwatchLifelineImgView.backgroundColor = UIColor.greenColor()
            }
            
        } else {
            print("Error finding challenger.")
        }
    }
    
    func displayOpponent() {
        if let opponent = self.challenge!["opponent"] {
            self.opponentUsernameLabel.text = opponent["username"] as? String
            self.opponentScoreLabel.text = "\(self.challenge!["opponentScore"]!)"
            
            if let opponentFile = opponent["profilePic"] as? PFFile {
                opponentFile.getDataInBackgroundWithBlock{ (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            self.opponentImgView.image = UIImage(data: imageData)
                            UtilityClass.setMyViewBorder(self.opponentImgView, withBorder: 0, radius: 50)
                        }
                    } else {
                        print("Error getting opponentFile: \(error)")
                    }
                }
            } else {
                self.opponentImgView.image = UIImage(named: "add photo-30")
            }
            
            //self.checkLifeLines()
            if let opponentLifeLines = self.challenge!["opponentLifeLinesUsed"] {
                for var j=0; j < opponentLifeLines.count; j++ {
                    if opponentLifeLines[j] == "50-50" {
                        self.opponentFiftyLifelineImgView.image = UIImage(named: "used fiftyfifty icon")
                        self.opponentFiftyLifelineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.opponentFiftyLifelineImgView.backgroundColor = UIColor.greenColor()
                    }
                    
                    if opponentLifeLines[j] == "Hint" {
                        self.opponentHintLifeLineImgView.image = UIImage(named: "used hint icon")
                        self.opponentHintLifeLineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.opponentHintLifeLineImgView.backgroundColor = UIColor.greenColor()
                    }
                    
                    if opponentLifeLines[j] == "Pause" {
                        self.opponentStopwatchLifelineImgView.image = UIImage(named: "used stopwatch icon")
                        self.opponentStopwatchLifelineImgView.backgroundColor = UIColor.clearColor()
                    } else {
                        self.opponentStopwatchLifelineImgView.backgroundColor = UIColor.greenColor()
                    }
                }
                
            } else {
                self.opponentFiftyLifelineImgView.backgroundColor = UIColor.greenColor()
                self.opponentHintLifeLineImgView.backgroundColor = UIColor.greenColor()
                self.opponentStopwatchLifelineImgView.backgroundColor = UIColor.greenColor()
            }
            
        } else {
            print("Error finding opponent.")
        }
    }
    
    func isChallengeOver() -> Bool {
        let challenge = self.challenge
        return challenge!["challengeOver"] as! Bool
    }
    

    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swRevealVC = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swRevealVC.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swRevealVC, animated: true, completion: nil)
    }
    
    @IBAction func resumeButtonTapped(sender: AnyObject) {
        print("Loading challenge ... ")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueResumeQuestionChallenge" {
            let challenge = self.challenge
            
            let questionChallengeVC = segue.destinationViewController as! QuestionChallengeViewController
            questionChallengeVC.category = challenge?.objectForKey("category") as? Category
            questionChallengeVC.subCategory = challenge?.objectForKey("subCategory") as? SubCategory
            questionChallengeVC.challenge = challenge
            questionChallengeVC.cycle = challenge!["cycle"] as? PFObject

//            if opponent === PFUser.currentUser() {
//                questionChallengeVC.opponent = opponent
//            } else {
//                questionChallengeVC.opponent = challenge!.objectForKey("challenger") as? PFObject
//            }
            
            questionChallengeVC.flagForWrongAnswerpush = false
                        
            print("in resume challenge prepareForSegue = \(challenge)")
            
        }
    }


    

}
