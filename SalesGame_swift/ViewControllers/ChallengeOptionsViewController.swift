//
//  ChallengeOptionsViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/17/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class ChallengeOptionsViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var challengeFriendButton: UIButton!
    @IBOutlet weak var challengeRandomButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
            
    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
   
    

   

}
