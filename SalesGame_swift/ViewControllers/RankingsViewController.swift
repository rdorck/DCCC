//
//  RankingsViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/9/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class RankingsViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var rankingsTableView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    var category: PFObject!
    var subCategory: PFObject!
    
    var rankings: [PFObject] = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
                
        queryRankings()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    //==========================================================================================================================
    // MARK: Fetch & Query
    //==========================================================================================================================
    
    func queryRankings() {
        let queryGame = PFQuery(className: "Game")
        queryGame.whereKey("subCategory", equalTo: subCategory)
        queryGame.includeKey("category")
        queryGame.includeKey("player")
        queryGame.addDescendingOrder("score")
        queryGame.findObjectsInBackgroundWithBlock{ (success, error) -> Void in
            if error == nil {
                let temp: [PFObject] = success! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.rankings.append(temp[i])
                }
                
                self.rankingsTableView.reloadData()
                hideHud(self.view)
            } else {
                print("Error in queryRankings: \(error)")
            }
        }
    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
  
    
    
    //==========================================================================================================================
    // MARK: TableDataSource & Delegate
    //==========================================================================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rankings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = rankingsTableView!.dequeueReusableCellWithIdentifier("cell") as! RankingsTableViewCell
        
        let rank: PFObject = self.rankings[indexPath.row]
        
        cell.rankLabel?.text = String(stringInterpolationSegment: indexPath.row + 1)
        
        let score = rank["score"] as? Int!
        cell.scoreLabel?.text = String(stringInterpolationSegment: score!)
        
        cell.usernameLabel?.text = rank.objectForKey("player")?.valueForKey("username") as? String
        
//        if self.finalArray.objectAtIndex(indexPath.row).objectForKey("player")?.valueForKey("username") as? String == PFUser.currentUser()!.valueForKey("username") as? String {
//        
//        }
        
        return cell
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func homeButtonTap(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    

    //==========================================================================================================================
    // MARK: Hud
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    
    
    
    
}
