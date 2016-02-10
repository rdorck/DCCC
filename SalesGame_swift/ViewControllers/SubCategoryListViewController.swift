//
//  SubCategoryListViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/15/16.
//
//

import UIKit

class SubCategoryListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==============================================================================================================
    // MARK: Properties
    //==============================================================================================================
    
    // Buttons
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var overviewButton: UIButton!
    
    @IBOutlet weak var tblView: UITableView!
    
    // Custom Objects
    var category: PFObject!
    var subCategories: [PFObject] = []
    var game: PFObject?
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
        self.tblView.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        getSubCategories()
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
        
        self.getSubCategories()
        self.tblView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    //==============================================================================================================
    // MARK: Querying
    //==============================================================================================================
    
    func getSubCategories() {
        self.subCategories.removeAll()
        
        let query = PFQuery(className: "SubCategory")
        query.whereKey("parentCategory", equalTo: self.category)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.subCategories.append(temp[i])
                }
                
                hideHud(self.view)
                self.tblView.reloadData()
            } else {
                print("Error getSubCategories(): \(error)")
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: Table Datasource & Delegate
    //==============================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let subCategory = self.subCategories[indexPath.row]
        
        cell.textLabel?.text = subCategory["subCategoryName"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueGameStart", sender: self)
    }
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================
    
    @IBAction func overviewButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueGameStart" {
            if let selectedSubCategory = sender as? UITableViewCell {
                let indexPath = self.tblView.indexPathForCell(selectedSubCategory)!

                let navController = segue.destinationViewController as! UINavigationController
                let selectSubCategoryVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectSubCategoryViewController") as! SelectSubCategoryViewController
                let category: PFObject = self.category
                let subCategory: PFObject = self.subCategories[indexPath.row]
                
                self.game!["subCategory"] = subCategory
                
                selectSubCategoryVC.title = category["categoryName"] as? String
                selectSubCategoryVC.category = category
                selectSubCategoryVC.subCategory = subCategory
                selectSubCategoryVC.game = self.game
                
                navController.pushViewController(selectSubCategoryVC, animated: true)
            }
        } else if segue.identifier == "segueSearchSubCategory" {
            if let searchSubCategoryVC = segue.destinationViewController as? SearchSubCategoryViewController {
                searchSubCategoryVC.category = self.category
                searchSubCategoryVC.game = self.game
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: Progress Hud
    //==============================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    
    
    
    
}
