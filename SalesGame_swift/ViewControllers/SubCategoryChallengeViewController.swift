//
//  SubCategoryChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/8/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

class SubCategoryChallengeViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var homeButton: UIButton!
    
    var Challenge: PFObject?    
    var opponent: PFObject?
    
    var category: Category?
    
    var subCategories: [SubCategory] = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("SubCategoryChallenge - category = \(self.category)")
//        print("SubCategoryChallenge - Challenge = \(self.Challenge)")

        getSubCategory()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        displayCategoryInfo()
    }
    
    
    //==========================================================================================================================
    // MARK: Display Category
    //==========================================================================================================================

    func displayCategoryInfo() {
        if let category: Category = self.category {

            if let categoryFile = category["categoryFile"] as? PFFile {
                categoryFile.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                    if error == nil {
                        if let imageData = imgData {
                            self.categoryImgView.image = UIImage(data: imageData)
                        } else {
                            self.categoryImgView.image = UIImage(named: "add photo-30")
                        }
                    } else {
                        print("Error getting categoryFile: \(error)")
                    }
                }
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================

    func getSubCategory() {
        let querySubCategory = SubCategory.query()
        querySubCategory?.addDescendingOrder("createdAt")
        querySubCategory?.includeKey("parentCategory")
        querySubCategory?.whereKey("parentCategory", equalTo: self.category!)
        querySubCategory?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [SubCategory] = objects! as! [SubCategory]
                //print("SubCategoryChallengeVC getSubCategory() - temp = \(temp)")
                
                for var i=0; i < temp.count; i++ {
                    let SC: SubCategory = temp[i]
                    self.subCategories.append(SC)
                }
                
                self.collectionView.reloadData()
                
            } else {
                print("Error SubCategoryChallenge - querySubCategory: \(error)")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: CollectionView Datasource & Delegate
    //==========================================================================================================================

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("#OfRowsInSection subCategories = \(self.subCategories.count)")
        return self.subCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SubCategoryCollectionViewCell
        
        let subCategory: SubCategory = self.subCategories[indexPath.row]
        
        cell.subCategoryLabel.text = subCategory["subCategoryName"] as? String
        
        if let file = subCategory["subCategoryFile"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        cell.imageView.image = UIImage(data: imageData)
                    } else {
                        cell.imageView.image = UIImage(named: "add photo-30")
                    }
                } else {
                    print("Error SubCategoryChallenge - getting subCategoryFile: \(error)")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let subCategory: SubCategory = self.subCategories[indexPath.row]
        
        print("Selected subCategory: \(subCategory["subCategoryName"] as! String)")
        performSegueWithIdentifier("segueStartChallenge", sender: self)
    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================

    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(home, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueStartChallenge" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath

            if let startChallengeVC = segue.destinationViewController as? StartChallengeViewController {
                let subCategory: SubCategory = self.subCategories[indexPath.row]
                
                self.Challenge!["subCategory"] = subCategory
                
                startChallengeVC.Challenge = self.Challenge
                startChallengeVC.opponent = self.opponent
                startChallengeVC.category = self.category
                startChallengeVC.subCategory = subCategory
                
            } else {
                print("Error casting StartChallengeViewController from SubCategoryChallengeViewController")
            }
        }
    }
       
    
    
    
}
