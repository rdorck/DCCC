//
//  CheckAnswersViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 12/20/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class CheckAnswersViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    //var games: [Game] = []
    var gameSubCategory: [SubCategory] = []
    var gameCategory: Category?
    //var gameQuestions: [Question] = []
    var games: [PFObject] = []
    var gameQuestions: [PFObject] = []
    var subCategory: PFObject?
    
    
    var correctAnswers: NSMutableArray = []
    var wrongAnswers: NSMutableArray = []
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
                
//        fetchAllObjectFromLocalDatastore()
//        fetchAllObjects()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getRecentGame()
    }
    
    
    //==========================================================================================================================
    // MARK: Fetch & Query
    //==========================================================================================================================
    
    func getRecentGame() {
        self.games.removeAll()
        //let queryGame = Game.query()
        //let querySubCategory = SubCategory.query()
        let queryGame = PFQuery(className: "Game")
        let querySubCategory = PFQuery(className: "SubCategory")
        
        queryGame.whereKey("player", equalTo: PFUser.currentUser()!)
        queryGame.addDescendingOrder("createdAt")
        queryGame.limit = 1
        queryGame.includeKey("category")
        queryGame.includeKey("subCategory")
        queryGame.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                let temp: NSArray = success! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    self.games.append((temp.objectAtIndex(i) as? PFObject)!)
                }
                print("queryGame found = \(self.games) with the correctAnswers = \(self.correctAnswers)")
                
                let sub = self.games[0].objectForKey("subCategory")
                let subId = sub?.objectId!
                //print("sub has subId = \(subId!)")
                
                querySubCategory.whereKey("objectId", equalTo: subId!)
                querySubCategory.findObjectsInBackgroundWithBlock { (object, error) -> Void in
                    if error == nil {
                        let obj: NSArray = object! as NSArray
                        
                        self.subCategory = obj[0] as? PFObject
                        print("subCategory = \(self.subCategory!)")
                        
//                        for var j=0; j < obj.count; j++ {
//                            self.gameSubCategory.append((obj.objectAtIndex(j) as? SubCategory)!)
//                        }
//                        print("gameSubCategory = \(self.gameSubCategory)")
                        
                        self.getQuestions()
                        
                    } else {
                        print("Error querySubCategory(): \(error)")
                    }
                }
                
                self.tblView.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    func getQuestions() {
        //let queryQuestions = Question.query()
        let queryQuestions = PFQuery(className: "Question")
        queryQuestions.whereKey("parentSubCategory", equalTo: self.subCategory!)
        queryQuestions.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    self.gameQuestions.append((temp.objectAtIndex(i) as? PFObject)!)
                }
                print("gameQuestions = \(self.gameQuestions)")
                
                self.getChoosenCorrectAnswers()
                
                self.tblView.reloadData()
            } else {
                print("Error getQuestions(): \(error)")
            }
        }
    }
    
    func getChoosenCorrectAnswers() {
        for game in self.games {
            if let correct = game["correctAnswers"] {
                self.correctAnswers = correct as! NSMutableArray
            } else {
                print("Error casting correct.")
            }
            print("correctAnswers = \(self.correctAnswers)")
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Table datasource and delegate methods
    //==========================================================================================================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* Returns question count in subCategory not self.games.count */
        
        //print("# OfRowsInSection = \(self.gameQuestions.count)")
        return self.gameQuestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? ReviewTableViewCell
        
        if let question: PFObject = self.gameQuestions[indexPath.row] {
            
            cell?.questionLabel.text = question["questionText"] as? String
            
            for var i=0; i < question["options"]?.count; i++ {
                let answer: String = question["answer"] as! String // The actual answer to the question
                //print("option \(i) = \(question["options"]!.objectAtIndex(i))")
                
                if answer == "\(question["options"]!.objectAtIndex(i))" {
                    print("answer = \(answer)")
                    switch i {
                    case 0:
                        cell?.optionALabel.backgroundColor = UIColor.greenColor()
                    case 1:
                        cell?.optionBLabel.backgroundColor = UIColor.greenColor()
                    case 2:
                        cell?.optionCLabel.backgroundColor = UIColor.greenColor()
                    case 3:
                        cell?.optionDLabel.backgroundColor = UIColor.greenColor()
                    default:
                        break
                    }
                }
                
//                if "\(choosenAnswer)" == "\(question["options"]!.objectAtIndex(i))" {
//                    print("choosenAnswer = \(choosenAnswer)")
//                    switch i {
//                    case 0:
//                        cell?.optionALabel.backgroundColor = UIColor.blueColor()
//                    case 1:
//                        cell?.optionBLabel.backgroundColor = UIColor.blueColor()
//                    case 2:
//                        cell?.optionCLabel.backgroundColor = UIColor.blueColor()
//                    case 3:
//                        cell?.optionDLabel.backgroundColor = UIColor.blueColor()
//                    default:
//                        break
//                    }
//                }
                
                let optionA = question["options"]?.objectAtIndex(0)
                let optionB = question["options"]?.objectAtIndex(1)
                let optionC = question["options"]?.objectAtIndex(2)
                let optionD = question["options"]?.objectAtIndex(3)
                
                cell?.optionALabel.text = optionA as? String
                cell?.optionBLabel.text = optionB as? String
                cell?.optionCLabel.text = optionC as? String
                cell?.optionDLabel.text = optionD as? String
            }

        } else {
            cell?.questionLabel.text = "No Question Found"
            cell?.optionALabel.text = "Option A"
            cell?.optionBLabel.text = "Option B"
            cell?.optionCLabel.text = "Option C"
            cell?.optionDLabel.text = "Option D"
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Game selected")
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================

    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK:
    //==========================================================================================================================

    
    

    

}
