//
//  SearchSubCategoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/16/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class SearchSubCategoryViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating{

    //==============================================================================================================
    // MARK: Properties
    //==============================================================================================================
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    var filteredSubCategories = [String]()
    var resultSearchController: UISearchController!
    
    var category: PFObject!
    var subCategories: [PFObject] = []
    var subCategoriesNS: NSMutableArray = [] // Needed for searching with string names
    var game: PFObject?
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        getSubCategories()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tblView.tableHeaderView = self.resultSearchController.searchBar
        self.tblView.reloadData()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
                    
                    // Add just subCategoryNames for filtering
                    self.subCategoriesNS.addObject(temp[i].valueForKey("subCategoryName")!)
                }
                
                self.tblView.reloadData()
                
            } else {
                print("Error finding subCategories: \(error)")
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: Table datasource and delegate methods
    //==============================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return self.filteredSubCategories.count
        } else {
            return self.subCategories.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblView!.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let subCategory = self.subCategories[indexPath.row]
        
        if self.resultSearchController.active {
            cell.textLabel?.text = self.filteredSubCategories[indexPath.row]
        } else {
            cell.textLabel?.text = subCategory["subCategoryName"] as? String
        }
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredSubCategories.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.subCategoriesNS as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        // casts array back into array of Strings b/c above we cast to NSArray, placing the value in the filteredSubCategories array
        self.filteredSubCategories = array as! [String]
        
        self.tblView.reloadData()
    }
    

    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueStartGame" {
            if let selectedSubCategoryCell = sender as? UITableViewCell {
                let indexPath = self.tblView.indexPathForCell(selectedSubCategoryCell)!
                
                let navSelectSubCategoryVC = segue.destinationViewController as! UINavigationController
                let selectSubCategoryVC = storyboard?.instantiateViewControllerWithIdentifier("SelectSubCategoryViewController") as! SelectSubCategoryViewController
                
                let selectedCategory = self.category
                var selectedSubCategory = self.subCategories[indexPath.row]
                var selectedFiliteredSubCategory: String?
                
                if self.resultSearchController.active && self.resultSearchController.searchBar.text != "" {
                    selectedFiliteredSubCategory = self.filteredSubCategories[indexPath.row]
                    for var i=0; i < self.subCategories.count; i++ {
                        if selectedFiliteredSubCategory == self.subCategories[i].valueForKey("subCategoryName") as? String {
                            selectedSubCategory = self.subCategories[i]
                        }
                    }
                } else {
                    selectedSubCategory = self.subCategories[indexPath.row]
                }
                
                game!["subCategory"] = selectedSubCategory
                
                selectSubCategoryVC.title = selectedSubCategory["subCategoryName"] as? String
                selectSubCategoryVC.category = selectedCategory
                selectSubCategoryVC.subCategory = selectedSubCategory
                selectSubCategoryVC.game = self.game
                
                if let subCategoryFile = selectedSubCategory["subCategoryFile"] as? PFFile {
                    subCategoryFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                        if error == nil {
                            if let imageData = imgData {
                                selectSubCategoryVC.subCategoryImageView?.image = UIImage(data: imageData)
                            }
                        } else {
                            print("Error in categoryFile getDataInBackground: \(error)")
                        }
                    }
                } else {
                    selectSubCategoryVC.subCategoryImageView?.image = UIImage(named: "add photo-30")
                }
                
                navSelectSubCategoryVC.pushViewController(selectSubCategoryVC, animated: true)
            }
        }
    } // END of prepareForSegue()
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
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
