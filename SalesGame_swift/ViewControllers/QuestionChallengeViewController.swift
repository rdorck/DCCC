//
//  QuestionChallengeViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/10/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

extension Array {
    func subSetBy(subSetSize: Int) -> [[Element]] {
        return 0.stride(to: self.count, by: subSetSize).map { startIndex in
            let endIndex = startIndex.advancedBy(subSetSize, limit: self.count)
            return Array(self[startIndex ..< endIndex])
        }
        
    }
}

class QuestionChallengeViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    // Navigation buttons
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var soundButton: UIBarButtonItem!
    
    // PFUser.currentUser outlets
    @IBOutlet weak var currentUsernameLabel: UILabel!
    @IBOutlet weak var currentUserImgView: UIImageView!
    @IBOutlet weak var currentUserScoreLabel: UILabel!
    
    // Opponent outlets
    @IBOutlet weak var opponentUsernameLabel: UILabel!
    @IBOutlet weak var opponentImgView: UIImageView!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    
    // Question & Option outlets
    @IBOutlet weak var questionTextFieldLabel: UITextView!
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnB: UIButton!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnD: UIButton!
    
    // Lifeline outlets
    @IBOutlet weak var btnFiftyFifty: UIButton!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var btnStopwatch: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var btnPass: UIButton!
    
    // Position array
    var posArray:[CGRect] = []
    var originalPosArray:[CGRect] = []
    
    // Speech variables 
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var isSound:Bool = true
    
    var flagForWrongAnswerpush : Bool!

    // Custom objects
    var category: Category?
    var subCategory: SubCategory?
    var challenge: PFObject?
    
    var questions: [Question] = []
    var powerPlayQuestion: [Question] = []
    var totalQuestions: [[Question]] = [[]]
    var question: Question?
    var availableHint: String?
    var cycle: PFObject?
    
    var currQuestionCount: Int = 1
    var totalQuestionCount: Int!
    var playerScore: Int = 0
    var oldScore: Int!
    var timer: NSTimer!
    var questionTimer: Double = 0.0 // was ... :Int = kQuestionTime
    var wrongAns: String!
    var arrWrongAns: NSMutableArray = []
    var arrHalfWrongAns: NSMutableArray = []
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.originalPosArray.insert(self.btnA!.frame, atIndex: 0)
        self.originalPosArray.insert(self.btnB!.frame, atIndex: 1)
        self.originalPosArray.insert(self.btnC!.frame, atIndex: 2)
        self.originalPosArray.insert(self.btnD!.frame, atIndex: 3)
        
        self.posArray.insert(self.originalPosArray[0], atIndex: 0)
        self.posArray.insert(self.originalPosArray[1], atIndex: 1)
        self.posArray.insert(self.originalPosArray[2], atIndex: 2)
        self.posArray.insert(self.originalPosArray[3], atIndex: 3)

        self.btnFiftyFifty.setTitle("50-50", forState: .Normal)
        self.btnHint.setTitle("Hint", forState: .Normal)
        self.btnPass.setTitle("PASS", forState: .Normal)
        self.btnStopwatch.setTitle("TIMER", forState: .Normal)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updatePlayerScore()
        
        if flagForWrongAnswerpush == false {
            self.getQuestions()
        } else {
            print("flagForWrongAnswerpush = \(flagForWrongAnswerpush!)")
            playerScore = oldScore
            self.nextQuestion(self.currQuestionCount)
        }
        
        startTimer()
        displayChallenger()
        displayOpponent()
        
    }
    
    
    //==========================================================================================================================
    // MARK: Display Challenger & Opponent
    //==========================================================================================================================

    func displayChallenger() {
        let challenger: PFObject = self.challenge!["challenger"] as! PFObject
        
        self.currentUsernameLabel.text = challenger["username"] as? String
        self.currentUserScoreLabel.text = "\(self.challenge!["challengerScore"]!)"
        
        if let file = challenger["profilePic"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) -> Void in
                if error == nil {
                    if let imageData = imgData {
                        self.currentUserImgView.image = UIImage(data: imageData)
                        UtilityClass.setMyViewBorder(self.currentUserImgView, withBorder: 0, radius: 40)
                    }
                } else {
                    print("Error getting challenger file: \(error)")
                }
            }
        } else {
            self.currentUserImgView.image = UIImage(named: "add photo-30")
        }
    }
    
    func displayOpponent() {
        let opponent = self.challenge!["opponent"] as! PFObject
        
        self.opponentUsernameLabel.text = opponent["username"] as? String
        self.opponentScoreLabel.text = "\(self.challenge!["opponentScore"]!)"
        
        if let file = opponent["profilePic"] as? PFFile {
            file.getDataInBackgroundWithBlock { (imgData, error) ->  Void in
                if error == nil {
                    if let imageData = imgData {
                        self.opponentImgView.image = UIImage(data: imageData)
                        UtilityClass.setMyViewBorder(self.opponentImgView, withBorder: 0, radius: 40)
                    }
                } else {
                    print("Error getting opponent file: \(error)")
                }
            }
        } else {
            self.opponentImgView.image = UIImage(named: "add photo-30")
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Querying
    //==========================================================================================================================

    func updatePlayerScore() {
        let challenge = self.challenge
        let challenger = challenge!["challenger"] as! PFObject
        //let opponent = challenge!["opponent"] as! PFObject
        
        if self.getTurn() == challenger {
            self.playerScore = challenge!["challengerScore"] as! Int
        } else {
            self.playerScore = challenge!["opponentScore"] as! Int
        }
        print("updated playerScore = \(self.playerScore)")
    }
    
    func getQuestions() {
        let queryQuestion = Question.query()
        queryQuestion?.limit = 100
        queryQuestion?.whereKey("parentSubCategory", equalTo: self.subCategory!)
        queryQuestion?.includeKey("parentSubCategory")
        queryQuestion?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                var temp: [Question] = objects! as! [Question]
                
                let doubleNumOfSubSetsNeeded = Double(temp.count) / 4.0
                let numOfSubSetsNeeded = temp.count / 4
                let numOfPowerPlayQuestions: Double = doubleNumOfSubSetsNeeded - Double(numOfSubSetsNeeded)
                
                /*  Switch statement will find how many power play questions there are, add them to 
                 *    the powerPlayQuestions subset, remove them from the temp array of questions.
                 *  Then we set the questions array to equal the now modified temp array.
                 */
                
                switch numOfPowerPlayQuestions {
                    case 0.25:
                        // 1
                        print("1 power play question.")
                        let powerPlayQ1 = temp.last!
                        self.powerPlayQuestion.append(powerPlayQ1)
                        
                        temp.removeLast()
                    
                        //print("Modified temp 0.25 = \(temp)")
                        //print("powerPlayQuestions = \(self.powerPlayQuestion)")
                    
                    case 0.5:
                        // 2
                        print("2 power play questions.")
                        let powerPlayQ1 = temp[temp.count - 2]
                        let powerPlayQ2 = temp.last!
                    
                        self.powerPlayQuestion.append(powerPlayQ1)
                        self.powerPlayQuestion.append(powerPlayQ2)
                        
                        for var i=0; i < 2; i++ {
                            temp.removeLast()
                        }
                        
                        //print("Modified temp 0.5 = \(temp)")
                        //print("powerPlayQuestions = \(self.powerPlayQuestion)")
                    
                    case 0.75:
                        // 3
                        print("3 power play questions.")
                        let powerPlayQ1 = temp[temp.count - 3]
                        let powerPlayQ2 = temp[temp.count - 2]
                        let powerPlayQ3 = temp.last!
                        
                        self.powerPlayQuestion.append(powerPlayQ1)
                        self.powerPlayQuestion.append(powerPlayQ2)
                        self.powerPlayQuestion.append(powerPlayQ3)
                    
                        for var i=0; i < 3; i++ {
                            temp.removeLast()
                        }
                        
                        //print("Modified temp 0.75 = \(temp)")
                        //print("powerPlayQuestions = \(self.powerPlayQuestion)")
                    
                    default:
                        break
                }
                
                // Set questions array to modified temp array
                self.questions = temp
                
                /*  Make call to subSetBy(Int) to subSet questions array by 4.
                 *  Append powerPlayQuestions to subSetQuestions, giving us
                 *    our total array of questions in perfect sub sets with PPQs.
                 */
                var subSetQuestions = self.questions.subSetBy(4)
                subSetQuestions.append(self.powerPlayQuestion)
                //print("subSetQuestions = \(subSetQuestions)")
                
                self.totalQuestions = subSetQuestions
                
                self.nextQuestion(self.currQuestionCount)
                
            } else {
                print("Error finding Question in getQuestions(): \(error)")
            }
        }
    }
    
    /*  Returns player currently set for turn, ie. challenger or opponent */
    func getTurn() -> PFObject {
        let player: PFObject = self.challenge!["turn"] as! PFObject

        print("getTurn() player = \(player["username"]!)")
        return player
    }
    
    /* Returns false if the challenge is NOT over b/c there are more subsets of questions to be played */
    func isChallengeOver(cycle: Int) -> Bool {
        // It's [cycle - 1] b/c we initialize cycle = 1 when creating the challenge
        if (cycle - 1) < self.totalQuestions.count {
            return false
        } else {
            return true
        }
    }
    
    /* Returns the respective cycle's sub set of questions OR a blank subSet if non-existant */
    func getCycleSubSet(cycle: Int) -> [Question] {
        if cycle > self.totalQuestions.count {
            let subSet: [Question] = []
            return subSet
        } else {
            let subSet: [Question] = self.totalQuestions[cycle - 1]
            return subSet
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Next Question Methods
    //==========================================================================================================================

    func nextQuestion(questionNumber: Int) {
        print("Next Question.")
        let cycle = self.challenge!["cycle"] as! Int
        
        if self.isChallengeOver(cycle) {
            print("Challenge over.")
            challenge?["challengeOver"] = true
            challenge?.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully declared challengeOver.")
                } else {
                    print("Error stating challengeOver: \(error)")
                }
            }
            self.performSegueWithIdentifier("segueScoreChallenge", sender: self)

        } else {
            print("Challenge continues.")
            let currentCycleSubSet = self.getCycleSubSet(cycle)
            //print("currentCycleSubSet = \(currentCycleSubSet)")
            
            if currQuestionCount > currentCycleSubSet.count {
                // Finished answering all the questions in this cycle's subSet.
                let currentUser = PFUser.currentUser()!
                let challenger = self.challenge!["challenger"] as! PFObject
                let opponent = self.challenge!["opponent"] as! PFObject
                
                if self.getTurn() == challenger {
                    challenge?["challengerScore"] = self.playerScore
                } else {
                    challenge?["opponentScore"] = self.playerScore
                }
                
                if currentUser == challenger {
                    challenge?["turn"] = opponent
                } else {
                    challenge?["turn"] = challenger
                    challenge?["cycle"] = cycle + 1
                }
                
                challenge?.saveInBackgroundWithBlock { (success, error) -> Void in
                    if error == nil {
                        print("Challenge successfully updated.")
                        self.performSegueWithIdentifier("segueScoreChallenge", sender: self)

                    } else {
                        print("Error updating Challenge: \(error)")
                    }
                }
//                self.performSegueWithIdentifier("segueScoreChallenge", sender: self)

                if timer != nil {
                    timer.invalidate()
                }
            } else {
                // Display the next question in this cycle's subSet
                self.availableHint = nil
                self.question = nil
                self.question = currentCycleSubSet[currQuestionCount - 1]
                
                wrongAns = question?.valueForKey("options")?.objectAtIndex(1) as? String
                self.questionTextFieldLabel?.text = question?.valueForKey("questionText") as! String
                var ans: String = question!.valueForKey("answer") as! String
                
                if let hint = question!.valueForKey("hint") as? String {
                    self.availableHint = hint
                    self.btnHint.enabled = true
                } else {
                    self.btnHint.enabled = false
                }
                
                if ans == question?.valueForKey("options")?.objectAtIndex(0) as? String {
                    ans = "option1"
                }
                else if ans == question?.valueForKey("options")?.objectAtIndex(1) as? String {
                    ans = "option2"
                }
                else if ans == question?.valueForKey("options")?.objectAtIndex(2) as? String {
                    ans = "option3"
                }
                else if ans == question?.valueForKey("options")?.objectAtIndex(3) as? String {
                    ans = "option4"
                }
                
                // Set Original Position
                btnA.frame = originalPosArray[0]
                btnB.frame = originalPosArray[1]
                btnC.frame = originalPosArray[2]
                btnD.frame = originalPosArray[3]
                
                // Originally the 'gray' was 'normal', effecting the buttons background color
                btnA.setBackgroundImage(UIImage(named: "normal"), forState: UIControlState.Normal)
                btnB.setBackgroundImage(UIImage(named: "normal"), forState: UIControlState.Normal)
                btnC.setBackgroundImage(UIImage(named: "normal"), forState: UIControlState.Normal)
                btnD.setBackgroundImage(UIImage(named: "normal"), forState: UIControlState.Normal)
                
                btnA.tag = 0
                btnB.tag = 0
                btnC.tag = 0
                btnD.tag = 0
                
                btnA.hidden = false
                btnB.hidden = false
                btnC.hidden = false
                btnD.hidden = false
                
                btnA.setTitle(question!.valueForKey("options")?.objectAtIndex(0) as? String, forState: UIControlState.Normal)
                btnB.setTitle(question!.valueForKey("options")?.objectAtIndex(1) as? String, forState: UIControlState.Normal)
                btnC.setTitle(question!.valueForKey("options")?.objectAtIndex(2) as? String, forState: UIControlState.Normal)
                btnD.setTitle(question!.valueForKey("options")?.objectAtIndex(3) as? String, forState: UIControlState.Normal)
                
                if ans.rangeOfString("1") != nil {
                    btnA.tag = 1
                }
                else if ans.rangeOfString("2") != nil {
                    btnB.tag = 1
                }
                else if ans.rangeOfString("3") != nil {
                    btnC.tag = 1
                }
                else if ans.rangeOfString("4") != nil {
                    btnD.tag = 1
                }
                
                for idx in 0..<posArray.count {
                    let rnd = Int(arc4random_uniform(UInt32(idx)))
                    if rnd != idx {
                        swap(&posArray[idx], &posArray[rnd])
                    }
                }
                
                // Set Random Position
                btnA.frame = posArray[0]
                btnB.frame = posArray[1]
                btnC.frame = posArray[2]
                btnD.frame = posArray[3]
                
                //self.startTimer()
            }
        }
        
    }
    
    
    //====================================================================================================================
    // MARK: Timer Methods
    //====================================================================================================================

    /*
     * The timer starts at 0, incrementing.  Users are in a race to beat each others time !
     */
    func startTimer() {
        
        //NSLog("%@",NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String)
        if(NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "YES") {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: true)
        } else {
            timerLabel?.hidden = true
            btnStopwatch?.hidden = true
        }
    }
    
    func updateTimer(dt:NSTimer) {
        //questionTimer++
        questionTimer += 1
        if questionTimer == 500 {
            currQuestionCount++
            
            NSLog("%d %d",currQuestionCount,questions.count)
            if currQuestionCount > questions.count {
                print("Game over, ran out of time")
                
                self.performSegueWithIdentifier("segueScoreChallenge", sender: self)
                if timer != nil {
                    timer.invalidate()
                }
            }else {
                if timer != nil {
                    timer.invalidate()
                }
                challenge?.addUniqueObject(question!, forKey: "challengerWrong")
                print("Added question to wrongAnswers b/c time's up!")
                
                arrWrongAns.addObject(question!)
                
                //questionTimer = kQuestionTime
                self.nextQuestion(currQuestionCount)
            }
        }
        else {
            timerLabel.text = "\(questionTimer)"
        }
    }
    
    
    //====================================================================================================================
    // MARK: Actions
    //====================================================================================================================

    @IBAction func soundButtonTapped(sender: AnyObject) {
        if self.isSound {
            self.soundButton.title = "Sound On"
            self.soundButton.titleTextAttributesForState(.Normal)
        } else {
            self.soundButton.title = "Sound Off"
            self.soundButton.titleTextAttributesForState(.Normal)
        }
        
        self.isSound = !isSound
    }
    
    @IBAction func btnFiftyFiftyTapped(sender: AnyObject) {
        let fiftyFiftyLifeLine = "50-50"
        let challenger = self.challenge!["challenger"] as! PFObject
        let opponent = self.challenge!["opponent"] as! PFObject
        
        if self.getTurn() == challenger {
            self.challenge?.addUniqueObject(fiftyFiftyLifeLine, forKey: "challengerLifeLinesUsed")
            self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully updated challenger 50-50.")
                    self.btnFiftyFifty.enabled = false
                } else {
                    print("Error updating challenger 50-50: \(error)")
                }
            }
        } else if self.getTurn() == opponent {
            self.challenge?.addUniqueObject(fiftyFiftyLifeLine, forKey: "opponentLifeLinesUsed")
            self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully updated opponent 50-50.")
                    self.btnFiftyFifty.enabled = false
                } else {
                    print("Error updating opponent 50-50: \(error)")
                }
            }
        }
        
        let ff = NSUserDefaults.standardUserDefaults().valueForKey(kFiftyFiftyCount) as! String
        var ffInt = Int(ff)
        ffInt?--
        let ffString = String(format: "%d", ffInt!)
        NSUserDefaults.standardUserDefaults().setValue(ffString, forKey: kFiftyFiftyCount)
        btnFiftyFifty!.setTitle("50-50", forState: UIControlState.Normal)
        
        if btnA?.tag == 1 {
            btnC?.hidden = true
            btnD?.hidden = true
        }
        else if btnB?.tag == 1 {
            btnA?.hidden = true
            btnC?.hidden = true
        }
        else if btnC?.tag == 1 {
            btnA?.hidden = true
            btnD?.hidden = true
        }
        else if btnD?.tag == 1 {
            btnA?.hidden = true
            btnB?.hidden = true
        }
        
        btnFiftyFifty.enabled = false
    }
    
    @IBAction func btnHintTapped(sender: AnyObject) {
        if let hint: String = self.availableHint {
//            print("hint = \(hint)")
            
            let challenger = self.challenge!["challenger"] as! PFObject
            let opponent = self.challenge!["opponent"] as! PFObject
            
            let actionSheetController: UIAlertController = UIAlertController(title: "Hint", message: "\(hint)", preferredStyle: .Alert)
            
            /* Create & add a Ok Action, changing opponentAccepted = true, saving challenge, review current stats */
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in

                if self.getTurn() == challenger {
                    self.challenge!.addUniqueObject("Hint", forKey: "challengerLifeLinesUsed")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated challengerLifeLinesUsed with Hint.")
                            self.btnHint.enabled = false
                        } else {
                            print("Error updating challenge; challengerLifeLinesUsed with Hint: \(error)")
                        }
                    }
                } else if self.getTurn() == opponent {
                    self.challenge!.addUniqueObject("Hint", forKey: "opponentLifeLinesUsed")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated opponentLifeLinesUsed with Hint.")
                            self.btnHint.enabled = false
                        } else {
                            print("Error updating opponentLifeLinesUsed with Hint: \(error)")
                        }
                    }
                }
            }
            actionSheetController.addAction(okAction)
            
            // Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        } else {
            print("There is no hint.")
        }

    }
    
    @IBAction func btnStopwatchTapped(sender: AnyObject) {
        let pauseLifeLine = "Pause"
        let challenger = self.challenge?["challenger"] as! PFObject
        let opponent = self.challenge?["opponent"] as! PFObject
        
        if self.getTurn() == challenger {
            self.challenge?.addUniqueObject(pauseLifeLine, forKey: "challengerLifeLinesUsed")
            self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully updated challengerLifeLinesUsed with Pause.")
                    self.btnStopwatch.enabled = false
                } else {
                    print("Error updating challengerLifeLinesUsed with Pause: \(error)")
                }
            }
        } else if self.getTurn() == opponent {
            self.challenge?.addUniqueObject(pauseLifeLine, forKey: "opponentLifeLinesUsed")
            self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Successfully updated opponentLifeLinesUsed with Pause.")
                    self.btnStopwatch.enabled = false
                } else {
                    print("Error updating opponentLifeLinesUsed with Pause: \(error)")
                }
            }
        }
        
        let time = NSUserDefaults.standardUserDefaults().valueForKey(kTimerCount) as! String
        var ffTimeInt = Int(time)
        ffTimeInt?--
        let ffSkipString = String(format: "%d", ffTimeInt!)
        NSUserDefaults.standardUserDefaults().setValue(ffSkipString, forKey: kTimerCount)
        
        btnStopwatch!.setTitle(" ", forState: UIControlState.Normal)
        
        if timer != nil {
            timer.invalidate()
        }
        
        self.btnStopwatch.enabled = false
    }
    
    
    //==========================================================================================================================
    // MARK: Option Button Actions
    //==========================================================================================================================

    @IBAction func btnAtapped(sender: AnyObject) {
        let challenger = self.challenge!["challenger"] as! PFObject
        let opponent = self.challenge!["opponent"] as! PFObject
        
        if timer != nil {
            timer.invalidate()
        }
        
        if sender.tag == 1 {
            self.speechAction(true)
            sender.setBackgroundImage(UIImage(named: "green"), forState: UIControlState.Normal)
            if flagForWrongAnswerpush == false {
                playerScore = playerScore + 10
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge?.addUniqueObject(question!, forKey: "challengerCorrect")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated challengerCorrect with A.")
                        } else {
                            print("Error updating challengerCorrect with A: \(error)")
                        }
                    }
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge?.addUniqueObject(question!, forKey: "opponentCorrect")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated opponentCorrect with A.")
                        } else {
                            print("Error updating opponentCorrect with A: \(error)")
                        }
                    }
                }
            
            } else {
                playerScore = playerScore + 8
            }
        }
        else {
            self.arrWrongAns.addObject(question!)
            
            self.speechAction(false)
            sender.setBackgroundImage(UIImage(named: "red"), forState: UIControlState.Normal)
            
            if flagForWrongAnswerpush == false {
                playerScore = playerScore - 5

                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge?.addUniqueObject(question!, forKey: "challengerWrong")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated challengerWrong with A.")
                        } else {
                            print("Error updating challengerWrong with A: \(error)")
                        }
                    }
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge?.addUniqueObject(question!, forKey: "opponentWrong")
                    self.challenge!.saveInBackgroundWithBlock { (success, error) -> Void in
                        if error == nil {
                            print("Successfully updated opponentWrong with A.")
                        } else {
                            print("Error updating opponentWrong with A: \(error)")
                        }
                    }
                }
                
            } else {
                self.arrHalfWrongAns.addObject(question!)
            }
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.currQuestionCount++
            self.nextQuestion(self.currQuestionCount)
        }
        
//        dispatch_async(dispatch_get_main_queue(), {
//            self.currQuestionCount++
//            self.nextQuestion(self.currQuestionCount)
//        })
        
    }
    
    @IBAction func btnBtapped(sender: AnyObject) {
        let challenger = self.challenge!["challenger"] as! PFObject
        let opponent = self.challenge!["opponent"] as! PFObject
        
        if timer != nil {
            timer.invalidate()
        }
        
        if sender.tag == 1 {
            self.speechAction(true)
            sender.setBackgroundImage(UIImage(named: "green"), forState: UIControlState.Normal)
            if flagForWrongAnswerpush == false {
                playerScore = playerScore + 10
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerCorrect")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentCorrect")
                }
                
            } else {
                playerScore = playerScore + 8
            }
        }
        else {
            self.arrWrongAns.addObject(question!)
            self.speechAction(false)
            sender.setBackgroundImage(UIImage(named: "red"), forState: UIControlState.Normal)
            
            if flagForWrongAnswerpush == false {
                playerScore = playerScore - 5

                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerWrong")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentWrong")
                }
            } else {
                self.arrHalfWrongAns.addObject(question!)
            }
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.currQuestionCount++
            self.nextQuestion(self.currQuestionCount)
        }
//        dispatch_async(dispatch_get_main_queue(), {
//            self.currQuestionCount++
//            self.nextQuestion(self.currQuestionCount)
//        })

    }
    
    @IBAction func btnCtapped(sender: AnyObject) {
        let challenger = self.challenge!["challenger"] as! PFObject
        
        if timer != nil {
            timer.invalidate()
        }
        
        if sender.tag == 1 {
            self.speechAction(true)
            sender.setBackgroundImage(UIImage(named: "green"), forState: UIControlState.Normal)
            if flagForWrongAnswerpush == false {
                playerScore = playerScore + 10
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerCorrect")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentCorrect")
                }
                
            } else {
                playerScore = playerScore + 8
            }
        }
        else {
            self.arrWrongAns.addObject(question!)
            self.speechAction(false)
            sender.setBackgroundImage(UIImage(named: "red"), forState: UIControlState.Normal)
            
            if flagForWrongAnswerpush == false {
                playerScore = playerScore - 5
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerWrong")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentWrong")
                }
                
            } else {
                self.arrHalfWrongAns.addObject(question!)
            }
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.currQuestionCount++
            self.nextQuestion(self.currQuestionCount)
        }
//        dispatch_async(dispatch_get_main_queue(), {
//            self.currQuestionCount++
//            self.nextQuestion(self.currQuestionCount)
//        })
    }
    
    @IBAction func btnDtapped(sender: AnyObject) {
        let challenger = self.challenge!["challenger"] as! PFObject
        
        if timer != nil {
            timer.invalidate()
        }
        
        if sender.tag == 1 {
            self.speechAction(true)
            sender.setBackgroundImage(UIImage(named: "green"), forState: UIControlState.Normal)
            if flagForWrongAnswerpush == false {
                playerScore = playerScore + 10
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerCorrect")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentCorrect")
                }
                
            } else {
                playerScore = playerScore + 8
            }
        }
        else {
            self.arrWrongAns.addObject(question!)
            self.speechAction(false)
            sender.setBackgroundImage(UIImage(named: "red"), forState: UIControlState.Normal)
            
            if flagForWrongAnswerpush == false {
                playerScore = playerScore - 5
                
                if self.getTurn() == challenger {
                    self.currentUserScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "challengerWrong")
                } else {
                    self.opponentScoreLabel.text = String(playerScore)
                    self.challenge!.addUniqueObject(question!, forKey: "opponentWrong")
                }
                
            } else {
                self.arrHalfWrongAns.addObject(question!)
            }
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.currQuestionCount++
            self.nextQuestion(self.currQuestionCount)
        }

//        dispatch_async(dispatch_get_main_queue(), {
//            self.currQuestionCount++
//            self.nextQuestion(self.currQuestionCount)
//        })
    }
    
    
    //==========================================================================================================================
    // MARK: Speech
    //==========================================================================================================================
    
    func speechAction(yn: Bool) {
        if(NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "YES") {
            if isSound {
                if yn {
                    myUtterance = AVSpeechUtterance(string: "Correct Answer")
                    myUtterance.rate = 0.3
                    synth.speakUtterance(myUtterance)
                } else {
                    NSLog("%@", arrWrongAns)
                    myUtterance = AVSpeechUtterance(string: "Wrong Answer")
                    myUtterance.rate = 0.3
                    synth.speakUtterance(myUtterance)
                }
            }
        }
        
        if(NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "YES") {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    
    //==========================================================================================================================
    // MARK: Quitting
    //==========================================================================================================================
    
    @IBAction func quitButtonTapped(sender: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Quit", message: "Are you sure want to quit?", preferredStyle: .Alert)
        
        // Create & add Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        actionSheetController.addAction(cancelAction)
        
        //Create & add Option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
            
            // Create AlertController
            let actionSheetController1: UIAlertController = UIAlertController(title: "Enter Name", message: "", preferredStyle: .Alert)
            
            // Create & add Cancel action
            let cancelAction1: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                // Do some stuff
                //DBFunction.insertData(self.playerName, score: String(self.playerScore))
                
                /* GO TO POST QUESTION CHALLENGE TO SCORE CHALLENGE VIEW CONTROLLER */
            }
            actionSheetController1.addAction(cancelAction1)
            
            // Create & Option action in this case for our OK button
            let nextAction1: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                let swReveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                swReveal.pushFrontViewController(homeVC, animated: true)
                self.navigationController?.presentViewController(swReveal, animated: true, completion: nil)
            }
            actionSheetController1.addAction(nextAction1)
            
            // Add text field
            actionSheetController1.addTextFieldWithConfigurationHandler { textField -> Void in
                // TextField configuration
                textField.textColor = UIColor.blackColor()
                textField.delegate = self
            }
            
            // Present the AlertController
            self.presentViewController(actionSheetController1, animated: true, completion: nil)
            if self.timer != nil {
                self.timer.invalidate()
            }
        }
        
        actionSheetController.addAction(nextAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    
    //=====================================================================================================================
    // MARK: Navigation
    //=====================================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueScoreChallenge" {
            let navController = segue.destinationViewController as! UINavigationController 
            if let scoreChallengeVC = navController.topViewController as? ScoreChallengeViewController {
                
                scoreChallengeVC.category = self.category
                scoreChallengeVC.subCategory = self.subCategory
                scoreChallengeVC.challenge = self.challenge
                
            } else {
                print("Error casting ScoreChallengeViewController from QuestionChallengeViewController.")
            }
        }
    }
    
    
    
    
    
    
}
