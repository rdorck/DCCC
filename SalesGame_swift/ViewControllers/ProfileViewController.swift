//
//  ProfileViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 10/20/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit
import Charts

class ProfileViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    var months: [String]!
    var wld: [String]!
    
    var playerGames: NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var labelTotalGamesAmount: UILabel!
    @IBOutlet weak var labelWinsAmount: UILabel!
    @IBOutlet weak var labelLossesAmount: UILabel!
    @IBOutlet weak var labelDrawsAmount: UILabel!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var gamesButton: UIButton!
    @IBOutlet weak var badgesButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var newFriendRequestLabel: UILabel!
    
    var userLevel: Int?
    
    var pic:AnyObject?
    var wins: Int = 0
    var losses: Int = 0
    var noStatus: Int = 0
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSThread.detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        UtilityClass.setMyViewBorder(img, withBorder: 0, radius: 75)
        self.displayUserImg()
        
        let currentUser = PFUser.currentUser()!.objectForKey("username")
        let level = PFUser.currentUser()!.objectForKey("level")
        self.userLevel = level as? Int
        self.usernameLabel.text = currentUser as? String
        levelLabel?.text = String(format: "%d", self.userLevel!)
        
        getTotalGamesPlayed()
        
        
    } // END of viewDidLoad()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.newFriendRequestLabel.text = ""
        checkNewFriendRequests()

    }
    
    
    //==========================================================================================================================
    // MARK: Chart Methods
    //==========================================================================================================================
    
    func setChart(dataPoints: [String], values:[Double]) {
        pieChartView.noDataText = "Must play a game before data can be displayed."
        pieChartView.descriptionText = ""
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: nil)
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        pieChartView.usePercentValuesEnabled = true
        pieChartView.animate(xAxisDuration: 2.0, easingOption: .EaseInCirc)
        //pieChartView.backgroundColor = UIColor.lightGrayColor()
                
        /* percent value of pieChart hole; default is 0.5 (half of the chart) */
        pieChartView.holeRadiusPercent = 0.2
        pieChartView.transparentCircleRadiusPercent = 0.3

        pieChartData.setValueTextColor(UIColor.whiteColor())
        
        /* Setting your own custom colors, there MUST be as many colors as data
        var colors: [UIColor] = []
        
        for j in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        */

        /* Choices are: .liberty, .joyful, .colorful, .pastel, .vordiplom */
        pieChartDataSet.colors = ChartColorTemplates.colorful()
        
        /* Properties for the graph's legend */
        let legend = pieChartView.legend
        legend.position = .RightOfChartCenter
        legend.textColor = UIColor.darkGrayColor()
        
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .PercentStyle
        pFormatter.percentSymbol = "%"
        pFormatter.multiplier = 1
        pieChartData.setValueFormatter(pFormatter)
        
    } // END of setChart()
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================
    
    /* Retrieve user's profile pic and display it.  Allows user to change img */
    func displayUserImg() {
        let currentUser = PFUser.currentUser()!
        
        if let file: PFFile = currentUser["profilePic"] as? PFFile {
            file.getDataInBackgroundWithBlock({
                (imageData, error) -> Void in
                if error == nil {
                    let Image: UIImage = UIImage(data: imageData!)!
                    self.img.image = Image
                    //hideHud(self.view)
                } else {
                    print("Error \(error)")
                }
            })
        }
    } // END of displayUserImg()
    
    func getTotalGamesPlayed(){
        let queryGame = PFQuery(className: "Game")
        queryGame.whereKey("player", equalTo: PFUser.currentUser()!)
        queryGame.findObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.labelTotalGamesAmount?.text = String(success!.count)
                
                let temp: NSArray = success! as NSArray
                
                self.playerGames = temp.mutableCopy() as! NSMutableArray
                self.getWLD()
            } else{
                print("Error getTotalGamesPlayed(): \(error)")
            }
        }
    }
    
    /* Gets Wins, Losses, Draws */
    func getWLD() {
        for var i=0; i < self.playerGames.count; i++ {
            if self.playerGames.objectAtIndex(i).valueForKey("WLD") as? String == "W" {
                wins++
            } else if self.playerGames.objectAtIndex(i).valueForKey("WLD") as? String == "L" {
                losses++
            } else {
                noStatus++
            }
        }
        
        wld = ["Wins", "Losses", "Draws"]
        let stats = [Double(self.wins), Double(self.losses), Double(self.noStatus)]
        print("stats:  wins = \(stats[0]), losses = \(stats[1]), no stats = \(stats[2])")
        
        self.setChart(wld, values: stats)

        self.labelWinsAmount?.text = String(wins)
        self.labelLossesAmount?.text = String(losses)
    }
    
    func checkNewFriendRequests() {
        let queryFriend = PFQuery(className: "Friend")
        queryFriend.whereKey("to", equalTo: PFUser.currentUser()!)
        queryFriend.whereKey("accepted", notEqualTo: true)
        queryFriend.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            if error == nil {
                let temp: [PFObject] = requests! as! [PFObject]
                
                for var i=0; i < temp.count; i++ {
                    let friendship: PFObject = temp[i]
                    if let request = friendship["accepted"] {
                        if request as! NSObject != true {
                            self.newFriendRequestLabel.text = "\(i + 1)"
                        }
                    } else {
                        print("Error friend has no requested status.")
                    }
                }
                
            } else {
                print("Error getting friend request: \(error)")
            }
        }
    }

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    @IBAction func homeButton(sender: AnyObject) {
        let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swReveal.pushFrontViewController(homeVC, animated: true)
        //self.navigationController?.pushViewController(swReveal, animated: true)
        self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
    }
    
    @IBAction func friendButtonTapped(sender: AnyObject) {
       
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOutInBackground()
        let navController = self.storyboard?.instantiateInitialViewController()
        self.navigationController?.presentViewController(navController!, animated: true, completion: nil)
    }
    

    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? EditProfileViewController, profilePic = sourceViewController.takePhotoImageFile {
            
            let user = PFUser.currentUser()
            user!["profilePic"] = profilePic
            
            user?.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("unwindToProfile done, new profile data was saved")
                } else{
                    print("Error in unwindToProfile b/c of saving department \(error)")
                }
            }
            self.displayUserImg()
        }
    } // END of unwindToProfile
    
    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    

}
