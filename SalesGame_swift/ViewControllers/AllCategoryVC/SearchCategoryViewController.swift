//
//  SearchCategoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/16/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class SearchCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    //==============================================================================================================
    // MARK: Properties
    //==============================================================================================================
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    var filteredCategories = [String]()
    var resultSearchController: UISearchController!
    
    var categories: [PFObject] = []
    var categoriesNS: NSMutableArray = [] // Needed for searching b/c SELF CONTAINS can't be used on [PFObject] collections
    
    var Game: PFObject?
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryCategories()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tblView.tableHeaderView = self.resultSearchController.searchBar
        self.tblView.reloadData() // adds searchBar to tblView
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    //==============================================================================================================
    // MARK: Querying
    //==============================================================================================================
    
    func queryCategories(){
        self.categories.removeAll()
        
        let query = PFQuery(className: "Category")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.categories.append(temp[i])
                    
                    /* Just the name so we can search but maintain indexing the with our [PFObject] */
                    self.categoriesNS.addObject(temp[i].valueForKey("categoryName")!)
                }
                
                self.tblView.reloadData()
                
            } else{
                print("Error \(error)")
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSearchResultSubCategory" {
            if let subCategoryVC = segue.destinationViewController as? SubCategoryViewController {
                if let selectedCategoryCell = sender as? UITableViewCell {
                    let indexPath = self.tblView.indexPathForCell(selectedCategoryCell)!
                    
                    var selectedCategory: PFObject = self.categories[indexPath.row]
                    var selectedFilteredCategory: String?

                    if self.resultSearchController.active {
                        selectedFilteredCategory = self.filteredCategories[indexPath.row]
                        for var i=0; i < self.categories.count; i++ {
                            if selectedFilteredCategory == self.categories[i].valueForKey("categoryName") as? String {
                                selectedCategory = self.categories[i]
                            }
                        }
                    }else {
                        selectedCategory = self.categories[indexPath.row]
                    }
                    
                    print("selectedCategory in prepareForSegue: \(selectedCategory)")
                    
                    let game = PFObject(className: "Game")
                    game["player"] = PFUser.currentUser()!
                    game["category"] = selectedCategory
                    self.Game = game
                    
                    subCategoryVC.title = selectedCategory.valueForKey("categoryName") as? String
                    subCategoryVC.category = selectedCategory
                    subCategoryVC.game = game
                    
                    if let categoryFile = selectedCategory.valueForKey("categoryFile") as? PFFile {
                        categoryFile.getDataInBackgroundWithBlock{ (imgData, error) -> Void in
                            if error == nil {
                                if let imageData = imgData {
                                    subCategoryVC.imageView?.image = UIImage(data: imageData)
                                }
                            } else{
                                print("Error in prepareForSegue categoryFile: \(error)")
                            }
                        }
                    } else {
                        subCategoryVC.imageView.image = UIImage(named: "add photo-30")
                    }
                }
            } else {
                print("Error casting SubCategoryViewController from SearchCategoryViewController.")
            }
        }
    } // END of prepareForSegue()
    
    
    //================================================================================================================
    // MARK: Table datasource and delegate methods
    //================================================================================================================
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return self.filteredCategories.count
        } else {
            return self.categories.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        let category = self.categories[indexPath.row]
        
        if self.resultSearchController.active {
            cell!.textLabel?.text = self.filteredCategories[indexPath.row]
        } else {
            cell!.textLabel?.text = category["categoryName"] as? String
        }
        
        return cell!
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Removes all items from filteredCategories array
        self.filteredCategories.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.categoriesNS as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        // Casts array back into array of Strings b/c above we cast to NSArray, placing the value in the filteredCategories array
        self.filteredCategories = array as! [String]
        
        self.tblView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        self.updateSearchResultsForSearchController(self.resultSearchController)
    }
    
    
    //===============================================================================================================
    // MARK: Actions
    //===============================================================================================================
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    //===============================================================================================================
    // MARK: Progress hud display methods
    //===============================================================================================================
    
    func showhud() {
        showHud(self.view)
    }

    
    
}
