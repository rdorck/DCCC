//
//  CategoryCollectionViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/6/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
        
    var strMainCategory: String?
    var PFMainCategory: PFObject?
    
    var Game: PFObject!
    
    //var category: [Category] = []
    var categories: [PFObject] = []
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)

        self.collectionView.addSubview(self.refreshControl)
        self.getLocalCategories()
//        self.getAllCategories()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
//        self.getLocalCategories()
        self.getAllCategories()

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
        
        self.getAllCategories()
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
    }

    
    //==============================================================================================================
    // MARK: Querying
    //==============================================================================================================
    
    func getAllCategories() {
        PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
        
        let query = PFQuery(className: "Category")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                PFObject.pinAllInBackground(objects)
                
                self.getLocalCategories()
                hideHud(self.view)
            } else {
                print("Error finding allCategories: \(error)")
            }
        }
    }
    
    func getLocalCategories() {
        let queryLocal = PFQuery(className: "Category")
        queryLocal.addDescendingOrder("createdAt")
        queryLocal.fromLocalDatastore()
        queryLocal.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.categories.append(temp[i])
                }
                
                self.collectionView.reloadData()
                hideHud(self.view)
            } else {
                print("Error finding localCategories: \(error)")
            }
        }
    }
    
    
    //==============================================================================================================
    // MARK: CollectionView
    //==============================================================================================================
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as?CategoryCollectionViewCell
        
        let category = self.categories[indexPath.row]
        
        cell?.categoryTitleCell.text = category["categoryName"] as? String
        
        if let file = category["categoryFile"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        cell?.categoryImageCell.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting categoryFile: \(error)")
                }
            }
        } else {
            cell?.categoryImageCell.image = UIImage(named: "BPCCicon")
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueSubCategory", sender: self)
    }
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSubCategory" {
                        
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            
            if let subCategoryVC = segue.destinationViewController as? SubCategoryViewController {
                let category: PFObject = self.categories[indexPath.row]
                
                let game = PFObject(className: "Game")
                print("game was prepared: \(game)")
                game["player"] = PFUser.currentUser()!
                game["category"] = category
                self.Game = game
                
                subCategoryVC.title = category["categoryName"] as? String
                subCategoryVC.category = category
                subCategoryVC.game = game
                
                if let categoryFile = category.valueForKey("categoryFile") as? PFFile {
                    categoryFile.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                subCategoryVC.imageView?.image = UIImage(data: imageData)
                            }
                        } else{
                            print("Error in prepareForSegue categoryFile: \(error)")
                        }
                    }
                }
            }
        } else if segue.identifier == "segueSearchCategory" {
            print("segue to SearchCategory")
        }
        
    } // END of prepareForSegue()
    
    
    //==============================================================================================================
    // MARK: Actions
    //==============================================================================================================
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //==============================================================================================================
    // MARK: Progress Hud
    //==============================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
    
    
}
