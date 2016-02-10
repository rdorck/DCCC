//
//  AllCategoryViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/11/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit

class AllCategoryViewController: UIViewController {

    //==============================================================================================================
    // MARK: Properties
    //==============================================================================================================
    
    @IBOutlet weak var tblObj : UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var categoryCollectionViewButton: UIButton!
    
    var categories: [PFObject] = []
    var Game: PFObject!

    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Categories"
        
        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
     
        self.tblObj.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.queryCategories()
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
        
        self.queryCategories()
        self.tblObj.reloadData()
        refreshControl.endRefreshing()
    }

    
    //==============================================================================================================
    // MARK: Querying
    //==============================================================================================================
    
    func queryCategories() {
        self.categories.removeAll()
        
        let query = PFQuery(className: "Category")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (objArray, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objArray! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.categories.append(temp[i])
                }
                
                self.tblObj.reloadData()
                hideHud(self.view)
            } else {
                print("Error AllCategoryVC queryCategories(): \(error)")
            }
        }
    } //END of queryForTable()
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSubCategory" {
            
            if let subCategoryVC = segue.destinationViewController as? SubCategoryViewController {
                if let selectedCategoryCell = sender as? UITableViewCell {
                    let indexPath = self.tblObj.indexPathForCell(selectedCategoryCell)!
                    
                    let category: PFObject = self.categories[indexPath.row]
                    
                    let game = PFObject(className: "Game")
                    print("game: \(game)")
                    game["player"] = PFUser.currentUser()!
                    game["category"] = category
                    self.Game = game
                    
                    subCategoryVC.title = category["categoryName"] as? String
                    subCategoryVC.category = category
                    subCategoryVC.game = game
                    
                    if let categoryFile = category["categoryFile"] as? PFFile {
                        categoryFile.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    subCategoryVC.imageView?.image = UIImage(data: imageData)
                                }
                            } else{
                                print("Error AllCategoryVC categoryFile: \(error)")
                            }
                        }
                    } else {
                        subCategoryVC.imageView.image = UIImage(named: "add photo-30")
                    }
                }
            } else {
                print("Error casting SubCategoryVC.")
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: Table datasource and delegate methods
    //==============================================================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblObj.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let category: PFObject = self.categories[indexPath.row]
        
        cell.textLabel?.text = category["categoryName"] as? String
        
        return cell
    }
    
    
    //==============================================================================================================
    // MARK: Actions
    //==============================================================================================================
    
    @IBAction func categoryCollectionViewButtonTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    //==============================================================================================================
    // MARK: Progress Hud
    //==============================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    
}
