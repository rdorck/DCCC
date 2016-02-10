//
//  ShowCategoryViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/6/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class SubCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    //=============================================================================================================
    // MARK: Properties
    //=============================================================================================================
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var game: PFObject!
    var category: PFObject?
    var subCategories: [PFObject] = []
    
    
    //==============================================================================================================
    // MARK: Lifecycle
    //==============================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
        getSubCategories()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let categoryFile = self.category!["categoryFile"] as? PFFile {
            categoryFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.imageView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting categoryFile: \(error)")
                }
            }
        } else {
            self.imageView.image = UIImage(named: "add photo-30")
        }
        
    }
    
    
    //================================================================================================================
    // MARK: Querying
    //================================================================================================================
    
    func getSubCategories() {
        let querySubCategories = PFQuery(className: "SubCategory")
        querySubCategories.whereKey("parentCategory", equalTo: self.category!)
        querySubCategories.addDescendingOrder("createdAt")
        querySubCategories.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [PFObject] = objects! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    self.subCategories.append(temp[i])
                }
                
                self.collectionView.reloadData()
                hideHud(self.view)
            } else {
                print("Error finding subCategories: \(error)")
            }
        }
    }
    
    
    //==================================================================================================================
    // MARK: CollectionView
    //==================================================================================================================
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? SubCategoryCollectionViewCell
        
        let subCategory: PFObject = self.subCategories[indexPath.row]
        
        cell?.subCategoryLabel.text = subCategory["subCategoryName"] as? String
        
        if let file = subCategory["subCategoryFile"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        cell?.imageView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Error getting subCategoryFile: \(error)")
                }
            }
        } else {
            cell?.imageView.image = UIImage(named: "BPCCicon")
        }
        
        return cell!
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueGameStart", sender: self)
    }
    
    
    //==============================================================================================================
    // MARK: Navigation
    //==============================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueGameStart" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            
            let navSelectSubCategoryVC = segue.destinationViewController as! UINavigationController
            let selectSubCategoryVC = storyboard?.instantiateViewControllerWithIdentifier("SelectSubCategoryViewController") as! SelectSubCategoryViewController
            
            let category = self.category
            let subCategory: PFObject = self.subCategories[indexPath.row]
            
            game["subCategory"] = subCategory
            
            selectSubCategoryVC.title = category!["categoryName"] as? String
            selectSubCategoryVC.category = category
            selectSubCategoryVC.subCategory = subCategory
            selectSubCategoryVC.game = self.game
            
            navSelectSubCategoryVC.pushViewController(selectSubCategoryVC, animated: true)
            
        } else if segue.identifier == "segueSearchSubCategory" {
            let searchSubCategoryVC = segue.destinationViewController as! SearchSubCategoryViewController
            
            searchSubCategoryVC.category = self.category
            searchSubCategoryVC.game = self.game
            
        } else if segue.identifier == "segueSubCategoryList" {
            let navController = segue.destinationViewController as! UINavigationController
            if let subCategoryList = navController.topViewController as? SubCategoryListViewController {
                subCategoryList.category = self.category
                subCategoryList.game = self.game
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
