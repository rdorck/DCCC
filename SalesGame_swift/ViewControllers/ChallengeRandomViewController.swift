//
//  ChallengeRandomViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/17/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class ChallengeRandomViewController: UIViewController, UINavigationControllerDelegate {

    //=======================================================================================
    // MARK: Properties
    //=======================================================================================
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var opponentImg: UIImageView!
    
    var users: [PFObject] = []
    var opponent: PFObject?
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    //=======================================================================================
    // MARK: LifeCycle
    //=======================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getAllUsers()
    }
    
    
    //=======================================================================================
    // MARK: Querying
    //=======================================================================================

    func getAllUsers() {
        let queryUsers = PFUser.query()
        queryUsers?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    if temp.objectAtIndex(i).objectId != PFUser.currentUser()?.objectId {
                        self.users.append(temp.objectAtIndex(i) as! PFObject)
                    }else {
                        print("Dont worry we didn't add you \(temp.objectAtIndex(i).valueForKey("username")!)")
                    }
                }
                self.randomUser()
            } else {
                print("Error ChallengeRandom getAllUsers(): \(error)")
            }
        }
    }
    
    
    //=======================================================================================
    // MARK: Randomization
    //=======================================================================================
    
    func randomUser() {
        let random = Int(arc4random_uniform(UInt32(self.users.count)))
        
        let randomOpponent: PFObject = self.users[random]
        
        self.opponent = randomOpponent
        
        self.opponentNameLabel.text = randomOpponent.valueForKey("username") as? String
        
        if let file = randomOpponent.objectForKey("profilePic") as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.opponentImg.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting file: \(error)")
                }
            }
        } else {
            self.opponentImg.image = UIImage(named: "add photo-30")
        }
        
    }
    
    
    //=======================================================================================
    // MARK: Shaking
    //=======================================================================================

    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        shuffleButtonTapped(self)
    }
    
    
    //=======================================================================================
    // MARK: Navigation
    //=======================================================================================
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(home, animated: true)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        print("Next button tapped.")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueCategoryChallenge" {
            if let categoryChallengeVC = segue.destinationViewController as? CategoryChallengeViewController {

                let opponent = self.opponent
                
                let challenge = PFObject(className: "Challenge")
                challenge["challenger"] = PFUser.currentUser()!
                challenge["opponent"] = opponent
                
                categoryChallengeVC.Challenge = challenge
                categoryChallengeVC.opponent = opponent
                
                print("Random user Challenge successfully created.")
            } else {
                print("Error casting CategoryChallengeViewController from ChallengeRandomViewController.")
            }
        }
    }
    
    
    //=======================================================================================
    // MARK: Actions
    //=======================================================================================
    
    @IBAction func shuffleButtonTapped(sender: AnyObject) {
        randomUser()
    }
    
    
    
    
    
    

}
