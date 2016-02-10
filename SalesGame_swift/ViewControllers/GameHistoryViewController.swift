//
//  GameHistoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/18/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class GameHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var tblView: UITableView!
    
    var anyObj: AnyObject?
    var array: NSMutableArray = []
    
    var holder: PFObject!
    var subHolder: PFObject!
    var categoryString: String!
    var subCategoryString: String!
    
    var historyDataAnyObject: AnyObject?
    var historyArray: NSMutableArray = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
                
        let queryGames = PFQuery(className: "Game")
        queryGames.limit = 100
        queryGames.whereKey("player", equalTo: PFUser.currentUser()!)
        queryGames.addDescendingOrder("createdAt")
        queryGames.includeKey("category")
        queryGames.includeKey("subCategory")
        queryGames.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.anyObj = success
                for var i=0; i < self.anyObj!.count; i++ {
                    let PFObj: PFObject = (self.anyObj as! Array)[i]
                    self.array.addObject(PFObj)
                }
                
                //print("array: \(self.array)")
                self.tblView!.reloadData()
                hideHud(self.view)
            } else {
                print("Error in queryGames: \(error)")
            }
        }
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
        if self.array.count == 0 {
            return 0
        } else{
            return self.array.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: GameHistoryTableViewCell = tblView!.dequeueReusableCellWithIdentifier("cell") as! GameHistoryTableViewCell
       
        self.holder = self.array.objectAtIndex(indexPath.row).valueForKey("category")! as! PFObject
        self.subHolder = self.array.objectAtIndex(indexPath.row).valueForKey("subCategory")! as! PFObject

        cell.labelCategoryTitle?.text = self.holder.valueForKey("categoryName") as? String
        cell.labelSubCategoryTitle?.text = self.subHolder.valueForKey("subCategoryName") as? String
        
        self.categoryString = self.holder.valueForKey("categoryName") as? String
        self.subCategoryString = self.subHolder.valueForKey("subCategoryName") as? String
        
        if let gameFile = self.array.objectAtIndex(indexPath.row).valueForKey("category")?.valueForKey("categoryFile") as? PFFile {
            gameFile.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.img.image = UIImage(data: imageData)
                        hideHud(self.view)
                    }
                } else{
                    print("Error in gameFile: \(error)")
                }
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        displayAlert("\(self.subCategoryString)", error: "You played this game on \(self.array[indexPath.row].createdAt)")
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        let deletedRow = tblView.cellForRowAtIndexPath(indexPath)!
//        let deletedGame: PFObject = self.array[indexPath.row] as! PFObject
//        
//        if editingStyle == UITableViewCellEditingStyle.Delete {
//            array.removeObjectAtIndex(indexPath.row)
//            
//            tblView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            deletedRow.accessoryType = UITableViewCellAccessoryType.None
//            
//            deletedGame.deleteInBackgroundWithBlock { (success, error) -> Void in
//                if error == nil {
//                    
//                } else {
//                    print("Error deleting Game: \(error)")
//                }
//            }
//            
//        }
//        
//        
//    }
    
    
    //==========================================================================================================================
    // MARK: Fetch & Query
    //==========================================================================================================================
    
    func queryCategoryWithID(){
        let queryCateory = PFQuery(className: "Category")
        queryCateory.whereKey("objectId", equalTo: self.holder.objectId!)
        queryCateory.findObjectsInBackgroundWithBlock{ (success, error) -> Void in
            if error == nil {
                //print("success: \(success)")
                for var l=0; l < success!.count; l++ {
                    let obj: PFObject = (success! as! Array)[l]
                    //print("obj: \(obj.valueForKey("categoryName"))")
                    self.categoryString = obj.valueForKey("categoryName")! as? String
                    //print("string: \(self.categoryString)")
                }
            } else{
                print("Error in queryCategory: \(error)")
            }
        }
    }
    
    func querySubCategory(){
        let querySubCateory = PFQuery(className: "SubCategory")
        querySubCateory.whereKey("objectId", equalTo: self.subHolder.objectId!)
        querySubCateory.findObjectsInBackgroundWithBlock{ (success, error) -> Void in
            if error == nil {
                //print("success: \(success)")
                for var l=0; l < success!.count; l++ {
                    let obj: PFObject = (success! as! Array)[l]
                    //print("obj: \(obj.valueForKey("categoryName"))")
                    self.subCategoryString = obj.valueForKey("subCategoryName")! as? String
                    //print("string: \(self.categoryString)")
                }
            } else{
                print("Error in querySubCategory: \(error)")
            }
        }
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
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    

    
}
