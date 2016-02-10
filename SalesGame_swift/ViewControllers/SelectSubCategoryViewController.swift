//
//  SelectSubCategoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/11/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class SelectSubCategoryViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var labelCategoryTitle: UILabel!
    @IBOutlet weak var labelSubCategoryTitle: UILabel!
    @IBOutlet weak var labelQuestionCount: UILabel!
    @IBOutlet weak var subCategoryImageView: UIImageView?
    
    var game: PFObject!
    var category: PFObject!
    var subCategory: PFObject!

    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        displayInfo()
    }
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================
    
    func displayInfo() {
        let category = self.category
        let subCategory = self.subCategory
        
        self.labelCategoryTitle.text = category["categoryName"] as? String
        self.labelSubCategoryTitle.text = subCategory["subCategoryName"] as? String
        
        if let subCategoryFile = self.subCategory!["subCategoryFile"] as? PFFile {
            subCategoryFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.subCategoryImageView?.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting subCategoryFile: \(error)")
                }
            }
        } else {
            self.subCategoryImageView?.image = UIImage(named: "BPCCicon")
        }
        
        self.questionCount()
    }
    
    func questionCount() {
        let queryQuestion = PFQuery(className: "Question")
        queryQuestion.whereKey("parentSubCategory", equalTo: self.subCategory!)
        queryQuestion.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                self.labelQuestionCount?.text = String(format: "%d", count)
                hideHud(self.view)
            } else {
                print("Error in queryQuestionCount \(error)")
            }
        }
    }// END of questionCount()
    
    
    //==========================================================================================================================
    // MARK: Alert
    //==========================================================================================================================
    
    func displayAlert(title: String, error: String){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueQuestion" {
            let questionViewController = segue.destinationViewController as! QuestionViewController
            
            let category = self.category!
            let subCategory = self.subCategory!
            
            questionViewController.category = category
            questionViewController.subCategory = subCategory
            questionViewController.flagForWrongAnswerpush = false
            questionViewController.game = self.game
        }
        else if segue.identifier == "segueRankings" {
            let rankingsVC = segue.destinationViewController as! RankingsViewController
            
            rankingsVC.category = self.category
            rankingsVC.subCategory = self.subCategory
        }
        
    } // END of prepareForSegue()
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
        
    func showhud() {
        showHud(self.view)
    }
    
    
    
}
