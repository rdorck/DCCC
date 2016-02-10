    //
//  HighScoreViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/13/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController {
    
    //=========================================================================================================
    // MARK: Properties
    //=========================================================================================================

    @IBOutlet weak var labelFirstPlace: UILabel!
    @IBOutlet weak var labelSecondPlace: UILabel!
    @IBOutlet weak var labelThirdPlace: UILabel!
    
    @IBOutlet weak var firstPlaceImg: UIImageView!
    @IBOutlet weak var secondPlaceImg: UIImageView!
    @IBOutlet weak var thirdPlaceImg: UIImageView!
    
    var pic:AnyObject?

    @IBOutlet weak var tblobj: UITableView?
    @IBOutlet weak var badgeButton: UIButton!
    
    var gameScores: [PFObject] = []
    
    
    //===========================================================================================================
    // MARK: Lifecycle
    //===========================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
        self.tblobj?.addSubview(self.refreshControl)
        
        UtilityClass.setMyViewBorder(firstPlaceImg, withBorder: 1, radius: 30)
        UtilityClass.setMyViewBorder(secondPlaceImg, withBorder: 1, radius: 30)
        UtilityClass.setMyViewBorder(thirdPlaceImg, withBorder: 1, radius: 30)

        getGameScores()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let count: Int = self.gameScores.count
        /* Display respective place (ie. 1st, 2nd, 3rd) by first checking if they exist */
        switch count{
        case 0...1:
            print("Only one player")
            self.getUserAtIndex(0)
            //hideHud(self.view)
        case 2:
            print("Two previous players")
            for var i=0; i < 2; i++ {
                self.getUserAtIndex(i)
            }
            //hideHud(self.view)
        case 3...count:
            print("Three or more previous players")
            for var j=0; j < 3; j++ {
                self.getUserAtIndex(j)
            }
            //hideHud(self.view)
        default:
            break
        }
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
        
        self.getGameScores()
        self.tblobj?.reloadData()
        refreshControl.endRefreshing()
    }

    
    //============================================================================================
    // MARK: Querying
    //============================================================================================
    
    func getGameScores() {
        self.gameScores.removeAll()
        
        let query = PFQuery(className: "Game")
        //query.limit = 100
        query.includeKey("player")
        query.includeKey("category")
        query.includeKey("subCategory")
        query.addDescendingOrder("score")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.gameScores.append(temp[i])
                }
                
                self.tblobj?.reloadData()
                //hideHud(self.view)
            } else {
                print("Error finding gameScores(): \(error)")
            }
        }
    }
    
    /*
     *  Given an index, will return a user (ie. player) at gameScore[index], 
     *   The first 3 will be displayed upon their exisitance w/ img while
     *  the rest are displayed as normal table rows.
     */
    func getUserAtIndex(index: Int) -> PFObject? {
        var holder: PFObject?
        /* placement is the player at the specified index */
        if let placement = self.gameScores[index].objectForKey("player") as? PFObject {
            let queryUser = PFUser.query()
            queryUser?.getObjectInBackgroundWithId(placement.objectId!, block: { (success, error) -> Void in
                if error == nil {
                    if let user = success {
                        holder = user
                        
                        if let file = user["profilePic"] as? PFFile {
                            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                                if let imageData = imgData {
                                    /* Set labels & images for top three */
                                    switch index {
                                    case 0:
                                        self.labelFirstPlace.text = user["username"] as? String
                                        self.firstPlaceImg.image = UIImage(data: imageData)
                                    case 1:
                                        self.labelSecondPlace.text = user["username"] as? String
                                        self.secondPlaceImg.image = UIImage(data: imageData)
                                    case 2:
                                        self.labelThirdPlace.text = user["username"] as? String
                                        self.thirdPlaceImg.image = UIImage(data: imageData)
                                    default:
                                        break
                                    }
                                }
                            }
                        } else {
                            print("Error getting user file: \(error)")
                        }
                    }
                } else {
                    print("Error getting user at placement \(index): \(error)")
                }
            })
        }
        return holder
    }
    

    //=============================================================================================================
    // MARK: Table Datasource & Delegate
    //=============================================================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameScores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:HighScoreTableViewCell = tblobj!.dequeueReusableCellWithIdentifier("cell") as! HighScoreTableViewCell
        
        let gameScore = self.gameScores[indexPath.row]
        
        cell.lblLevel?.text = String(stringInterpolationSegment: indexPath.row + 1)
        if gameScore["score"] != nil {
            cell.lblScore.text = String(stringInterpolationSegment: gameScore["score"]!)
        } else {
            cell.lblScore.text = "..."
        }
        cell.lblName.text = gameScore["player"]!.valueForKey("username") as? String
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    
    //===========================================================================================================
    // MARK: Actions
    //===========================================================================================================
    
    @IBAction func badgeButton(sender: AnyObject) {
        let badgeVC = self.storyboard?.instantiateViewControllerWithIdentifier("BadgeViewController") as? BadgeViewController
        self.navigationController?.pushViewController(badgeVC!, animated: true)
    }
    
    
    //===========================================================================================================
    // MARK: Progress hud display methods
    //===========================================================================================================
        
    func showhud() {
        showHud(self.view)
    }
    
    
    
    
}
