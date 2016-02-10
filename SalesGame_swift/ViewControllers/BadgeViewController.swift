//
//  BadgeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/10/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class BadgeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var badgeTableView: UITableView!
    
    var badges: [PFObject] = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
                
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        self.badgeTableView.addSubview(self.refreshControl)
        //NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getBadges()
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
        
        self.getBadges()
        self.badgeTableView.reloadData()
        refreshControl.endRefreshing()
    }

    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================

    func getBadges() {
        self.badges.removeAll()
        
        let currentUser = PFUser.currentUser()!
        let queryUser = PFUser.query()
        
        queryUser?.getObjectInBackgroundWithId(currentUser.objectId!, block: { (success, error) -> Void in
            if error == nil {
                if let badges = success!["badges"] {
                    for var i=0; i < badges.count; i++ {
                        self.badges.append(badges.objectAtIndex(i) as! PFObject)
                    }
                    print("badges = \(self.badges)")
                    
                    self.badgeTableView.reloadData()
//                    hideHud(self.view)
                } else {
                    print("User does not have any badges.")
                }
            } else {
                print("Error: \(error)")
            }
        })
    }
    
    
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
    // MARK: Table datasource and delegate methods
    //==========================================================================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.badges.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BadgeTableViewCell = badgeTableView!.dequeueReusableCellWithIdentifier("cell") as! BadgeTableViewCell
    
        let badge = self.badges[indexPath.row]
        
        /* Prevents error: badge["badgeName"] has no data, call fetchIfNeeded */
        badge.fetchIfNeededInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                cell.labelTitle.text = badge["badgeName"] as? String
                cell.labelDescription.text = badge["badgeDescription"] as? String
                
                if let badgeFile = badge["badgeImg"] as? PFFile {
                    badgeFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                        if error == nil {
                            if let imageData = imgData {
                                cell.badgeImgView.image = UIImage(data: imageData)
                            }
                        } else {
                            print("Error getting badgeImg: \(error)")
                        }
                    }
                } else {
                    cell.badgeImgView.image = UIImage(named: "add photo-30")
                }
                
            } else {
                print("Error fetchIfNeededInBackground(): \(error)")
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        displayAlert("\(self.badges[indexPath.row].valueForKey("badgeName")!)", error: "\(self.badges[indexPath.row].valueForKey("badgeDescription")!)")
    }
    
    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    

    

}
