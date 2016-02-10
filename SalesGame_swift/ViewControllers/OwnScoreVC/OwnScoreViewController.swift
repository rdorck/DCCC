//
//  OwnScoreViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/13/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit
import Charts

class OwnScoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var lblScore: UILabel?
    var playerScore:Int?
    var strName : String?
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var achievementsPickerView: UIPickerView!
    @IBOutlet weak var badgePickerViewLabel: UILabel!
    @IBOutlet weak var horizontalBarChartView: HorizontalBarChartView!
    
    var questionArrayScore:NSArray!
    var badgeName: String!

    var arrWrongQuestion : NSMutableArray = []
    var arrOtherAns : NSMutableArray = []
    var achievements = Array(1...10).map( { Double($0) * 1 } )
    var achievement : Double?
    
    var game: PFObject!
    var category: PFObject!
    var subCategory: PFObject!
    var playerBadges: [PFObject] = []
    
    var badges = [String]()
    

    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)

        let rows = ["Correct", "Incorrect"]
        let correct = self.game["correctAnswers"]
        let wrong = self.game["wrongAnswers"]
        var c: Int = 0
        var w: Int = 0
        
        for var i=0; i < correct?.count; i++ {
            c++
        }
        for var j=0; j < wrong?.count; j++ {
            w++
        }
        
        let answered = [c, w]
        
        setChart(rows, values: answered)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        lblScore?.text = String(format: "%d/%d", playerScore!, self.questionArrayScore.count * 10)

        /* Causes Long running operation b/c query counts objects NOT in background,
         *  Want to change to checking an array of badges for a user or edit the way
         *    UserBadges are created so there is only one relation per badge btwn user
         *      & badge instead of just always adding them
         */
//        self.getUserBadges("Long Hours Guy")
//        self.getUserBadges("The Intern")
//        self.getUserBadges("The Apprentice")
//        self.getUserBadges("The Veteran")
//        self.getUserBadges("The Crusader")
//        self.getUserBadges("Master of Disaster")
        
        checkHonorableMention()
        checkLongHoursGuy()
        checkIntern()
        checkApprentice()
        //checkVeteran()
        //checkCrusader()
        //checkMasterOfDisaster()
        
        if badges.count > 0 {
            self.badgePickerViewLabel.text = "Congratulations on WINNING Badges!"
        } else {
            self.badgePickerViewLabel.text = "Sorry, no new badges for you"
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Charts
    //==========================================================================================================================
    
    func setChart(dataPoints: [String], values: [Int]) {
        self.horizontalBarChartView.noDataText = "Did you play the game ... ?"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: Double(values[i]), xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let horizontalChartDataSet = BarChartDataSet(yVals: dataEntries, label: nil)
        let horizontalChartData = BarChartData(xVals: dataPoints, dataSet: horizontalChartDataSet)
        
        horizontalBarChartView.data = horizontalChartData
        horizontalBarChartView.descriptionText = ""
        
        let colorArray = [UIColor.greenColor(), UIColor.redColor()]
        horizontalChartDataSet.colors = colorArray
    }
    
    
    //==========================================================================================================================
    // MARK: UIPickerView required methods
    //==========================================================================================================================
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return badges.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(badges[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let a : Double? = self.achievements[row]
        self.achievement = a
    }
    
    
    //==========================================================================================================================
    // MARK: Check badges earned & add
    //==========================================================================================================================
    /*
    func getUserBadges(earnBadgeName: String) {
        let currentUser = PFUser.currentUser()!
        let queryUser = PFUser.query()
        queryUser?.getObjectInBackgroundWithId(currentUser.objectId!, block: { (success, error) -> Void in
            if error == nil {
                if let objects = success!["badges"] {
                    for var i=0; i < objects.count; i++ {
                        if objects.objectAtIndex(i).valueForKey("badgeName") as? String == earnBadgeName {
                            print("Earned \(earnBadgeName)")
                            self.playerBadges.append(objects.objectAtIndex(i) as! PFObject)
                        } else {
                            print("Did not earn: \(earnBadgeName) yet.")
//                            let bdg = earnBadgeName
//                            switch bdg {
//                                case "Long Hours Guy":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkLongHoursGuy()
//                                case "The Intern":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkIntern()
//                                case "Honorable Mention":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkHonorableMention()
//                                case "The Apprentice":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkApprentice()
//                                case "The Veteran":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkVeteran()
//                                case "The Crusader":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkCrusader()
//                                case "Master of Disaster":
//                                    print("Checking badge \(bdg) ... ")
//                                    self.checkMasterOfDisaster()
//                                default:
//                                    break
//                            }
                        }
                    }
                } else {
                    print("User does not have any badges.")
                }
            } else {
                print("Error getting currentUser: \(error)")
            }
        })
    }
    */
    
    /*
     * Checks if currentUser has already earned a specific badge. Passed in
     *  by earnBadgeName: String
     */
    func earned(earnBadgeName: String) -> Bool {
        let query = PFQuery(className: "UserBadges")
        query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
        query.whereKey("badgeName", equalTo: earnBadgeName)
        if query.countObjects() > 0 {
            print("Already earned \(earnBadgeName)")
            return true
        } else {
            print("Have not earned \(earnBadgeName) yet")
            return false
        }
    }
    
    /*
     * Function to add badge after confirming it was earned &
     *  currentUser did not already have it (!=)
     */
    func addBadge(addBadgeName: String){
        print("Adding badge: \(addBadgeName)")
        let UserBadge = PFObject(className: "UserBadges")
        let currUser = PFQuery.getUserObjectWithId(PFUser.currentUser()!.objectId!)
        let query = PFQuery(className: "Badges")
        
        query.whereKey("badgeName", equalTo: addBadgeName)
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil{
                print("Badge found: \(objects)")
                
                self.game.addUniqueObject(objects![0], forKey: "badgesWonInGame")
                
                currUser!.addUniqueObject(objects![0], forKey: "badges")
                
                UserBadge["badgeName"] = addBadgeName
                UserBadge["createdBy"] = PFUser.currentUser()
                UserBadge["badge"] = objects![0]
                
                UserBadge.saveInBackgroundWithBlock{ (success, error) -> Void in
                    if error == nil {
                        print("Badge \(addBadgeName) successfully saved!")
                        self.game.saveInBackground()
                        currUser?.saveInBackground()
                    } else{
                        print("Error saving badge \(addBadgeName): \(error)")
                    }
                }
            } else{
                print("Error addBadge(\(addBadgeName)): \(error)")
            }
        }
        hideHud(self.view)
    }
    
    /*
     *
     */
    func checkLongHoursGuy(){
    
        let totalPossible = self.questionArrayScore.count * 10
        if self.playerScore == totalPossible {
            if !self.earned("Long Hours Guy") {
                self.addBadge("Long Hours Guy")
                self.game.addUniqueObject("Long Hours Guy", forKey: "badgesWonInGame")
                self.badges.append("Long Hours Guy")
            }
        } else {
            print("Didn't earn checkLongHoursGuy")
        }
        hideHud(self.view)
    }
    
    /*
     *
     */
    func checkHonorableMention(){
        let totalPossible = self.questionArrayScore.count * 10
        if self.playerScore < totalPossible && self.playerScore > 0 {
            if !self.earned("Honorable Mention") {
                self.addBadge("Honorable Mention")
                self.game.addUniqueObject("Honorable Mention", forKey: "badgesWonInGame")
                self.badges.append("Honorable Mention")
            }
//            self.badgeName = "Honorable Mention"
        } else {
            print("Didn't earn checkHonorableMention")
        }
        hideHud(self.view)
    }
    
    /*
     *
     */
    func checkIntern(){
        var wins = 0
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray

                for var i=0; i < temp.count; i++ {
                    if temp[i].valueForKey("WLD") as? String == "W" {
                        wins++
                        print("Win detected")
                    }
                }
            } else {
                print("Error checkIntern(): \(error)")
            }
        }
        if wins == 0 {
            if !self.earned("The Intern") {
                self.addBadge("The Intern")
                self.badgeName = "The Intern"
                self.game.addUniqueObject("The Intern", forKey: "badgesWonInGame")
                self.badges.append("The Intern")
            } else if wins > 0 {
                print("Already won games, cannot earn The Intern badge.")
            } else {
                print("Sorry you did not earn The Intern badge.")
            }
        }
        hideHud(self.view)
    }

    /*
     * Practice makes prefect and playing 50 matches is not for the faint at heart.
     *  Keep sharpening your skills and making your boss proud. You got this!
     */
    func checkApprentice() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 50 {
                    if !self.earned("The Apprentice") {
                        self.addBadge("The Apprentice")
                        self.badgeName = "The Apprentice"
                        self.game.addUniqueObject("The Apprentice", forKey: "badgesWonInGame")
                        self.badges.append("The Apprentice")
                    }
                } else {
                    print("\(50 - count) games left until earning The Apprentice.")
                }
            } else {
                print("Error checkApprentince(): \(error)")
            }
        }
        hideHud(self.view)
    }
    
    /* You may or may not have served in any wars but playing 100 matches
     *  deserves some recognition in our book. The Digital War Heroes salute you.
     */
    func checkVeteran() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 100 {
                    if !self.earned("The Veteran") {
                        self.addBadge("The Veteran")
                        self.badgeName = "The Veteran"
                        self.game.addUniqueObject("The Veteran", forKey: "badgesWonInGame")
                        self.badges.append("The Veteran")
                    }
                } else {
                    print("\(100 - count) games left until earning The Veteran.")
                }
            } else {
                print("Error checkVeteran(): \(error)")
            }
        }
        hideHud(self.view)
    }
    
    /* A sword and shield may not be part of your usual work attire
     *  but you’re for sure making moves with playing 200 matches!
     */
    func checkCrusader() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error) -> Void in
            if error == nil {
                if count >= 200 {
                    if !self.earned("The Crusader") {
                        self.addBadge("The Crusader")
                        self.badgeName = "The Crusader"
                        self.game.addUniqueObject("The Crusader", forKey: "badgesWonInGame")
                        self.badges.append("The Crusader")
                    }
                } else {
                    print("\(200 - count) games left until earning The Crusader.")
                }
            } else {
                print("Error checkCrusader(): \(error)")
            }
        }
        hideHud(self.view)
    }
    
    /*
     * Do you know that saying about losing a game 5 times in a row?
     *  Yeah, we don’t either. Hold your head up high though,
     *      change is a coming (hopefully).
     */
    func checkMasterOfDisaster() {
        let query = PFQuery(className: "Game")
        query.whereKey("player", equalTo: PFUser.currentUser()!)
        query.addDescendingOrder("createdAt")
        query.limit = 5
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                
                for var i=0; i < temp.count; i++ {
                    if temp.objectAtIndex(i).valueForKey("WLD") as? String != "L" {
                        print("Non loss status, not a Master of Disaster.")
                    } else {
                        if !self.earned("Master of Disaster") {
                            self.addBadge("Master of Disaster")
                            self.badgeName = "Master of Disaster"
                            self.game.addUniqueObject("Master of Disaster", forKey: "badgesWonInGame")
                            self.badges.append("Master of Disaster")
                        }
                    }
                }
            } else {
                print("Error checkMasterOfDisaster() query: \(error)")
            }
        }
        hideHud(self.view)
    }
 
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueGameSummary" {
            let summaryVC = segue.destinationViewController as! SummaryViewController
            
            summaryVC.playerScore = self.playerScore
            summaryVC.arrWrongQuestion = self.arrWrongQuestion
            summaryVC.arrOtherAns = self.arrOtherAns
            summaryVC.game = self.game
            
        }
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        let swRevealVC = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swRevealVC.pushFrontViewController(homeVC, animated: true)
        self.navigationController?.presentViewController(swRevealVC, animated: true, completion: nil)
    }

    @IBAction func leaderboardButton(sender: AnyObject) {
        kTimeForWrongTime = 0
        let highscoreViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HighScoreViewController") as! HighScoreViewController
        self.navigationController?.pushViewController(highscoreViewController, animated: true)
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOutInBackground()
        let navController = self.storyboard?.instantiateInitialViewController()
        self.navigationController?.presentViewController(navController!, animated: true, completion: nil)
    }

    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }

    
    
    
    
}
