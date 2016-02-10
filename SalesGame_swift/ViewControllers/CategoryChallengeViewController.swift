//
//  CategoryChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/8/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import Parse

class CategoryChallengeViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var homeButton: UIButton!
    
    var Challenge: PFObject?
    var opponent: PFObject?
    
    var categories: [PFObject] = []
    var cats: [Category] = []
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategory()

    }

    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================
    
    func getCategory() {
        let query = Category.query()
        query?.addDescendingOrder("createdAt")
        query?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: [Category] = objects! as! [Category]
                
                for var i=0; i < temp.count; i++ {
                    let C: Category = temp[i]
                    self.cats.append(C)
                    //print("cats at \(i) = \(self.cats[i])")
                }
                self.collectionView.reloadData()
                
            } else {
                print("Error CategoryChallengeVC - getCategory: \(error)")
            }
        }
    }

    
    //==========================================================================================================================
    // MARK: Collection Datasource & Delegate
    //==========================================================================================================================
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("# OfRowsIn cats = \(self.cats.count)")
        return self.cats.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        
        let category: Category = self.cats[indexPath.row]
        
        cell.categoryTitleCell.text = category["categoryName"] as? String
        
        if let file = category["categoryFile"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        cell.categoryImageCell.image = UIImage(data: imageData)
                    } else {
                        cell.categoryImageCell.image = UIImage(named: "add photo-30")
                    }
                } else {
                    print("Error CategoryChallengeVC - getting categoryFile: \(error)")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let category: Category = self.cats[indexPath.row]
        print("Selected \(category["categoryName"] as! String)")
        
        performSegueWithIdentifier("segueSubCategoryChallenge", sender: self)
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSubCategoryChallenge" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath

            if let subCategoryChallengeVC = segue.destinationViewController as? SubCategoryChallengeViewController {
                let category: Category = self.cats[indexPath.row]
                
                self.Challenge!["category"] = category
                
                subCategoryChallengeVC.category = category
                subCategoryChallengeVC.Challenge = self.Challenge
                subCategoryChallengeVC.opponent = self.opponent
                subCategoryChallengeVC.navigationItem.title = category["categoryName"] as? String
            } else {
                print("Error casting SubCategoryChallengeView Controller from CategoryChallengeViewController - prepareForSegue.")
            }
        }
    }
    
    
    
    //==========================================================================================================================
    // MARK:
    //==========================================================================================================================

    
    
    
    
    
    
    
    
    
    
}

