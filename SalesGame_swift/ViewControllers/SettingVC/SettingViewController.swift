//
//  SettingViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/13/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITextFieldDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var switchTimed: UISwitch?
    @IBOutlet weak var switchSound: UISwitch?
    @IBOutlet weak var switchVibrate: UISwitch?
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var resetButton: UIBarButtonItem!

    var emailObj: AnyObject?
    var email: String?
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle user input through delegate
        emailText.delegate = self
        
        // Enable reset button IFF text field has text
        checkValidEmail()
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        switchTimed?.tag = 1
        switchSound?.tag = 2
        switchVibrate?.tag = 3
        
        switchTimed?.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        switchSound?.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        switchVibrate?.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        
        if(NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "YES") {
            switchTimed?.setOn(true, animated: false)
        }
        else if(NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "NO") {
            switchTimed?.setOn(false, animated: false)
        }
        
        if(NSUserDefaults.standardUserDefaults().valueForKey(kSound) as! String  == "YES") {
            switchSound?.setOn(true, animated: false)
        }
        else if (NSUserDefaults.standardUserDefaults().valueForKey(kTimer) as! String  == "NO") {
            switchSound?.setOn(false, animated: false)
        }
        
        if(NSUserDefaults.standardUserDefaults().valueForKey(kVibrate) as! String  == "YES") {
            switchVibrate?.setOn(true, animated: false)
        }
        else if (NSUserDefaults.standardUserDefaults().valueForKey(kVibrate) as! String  == "NO") {
            switchVibrate?.setOn(false, animated: false)
        }

    }

    
    //==========================================================================================================================
    // MARK: Methods
    //==========================================================================================================================

    /* User turns the switch to ON */
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            if switchState == switchTimed {
                NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kTimer)
            }
            if switchState == switchSound {
                UtilityClass.showAlert("Sound Changed")
                NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kSound)
            }
            if switchState == switchVibrate {
                UtilityClass.showAlert("Switch Changed")
                NSUserDefaults.standardUserDefaults().setValue("YES" , forKey: kVibrate)
            }
        }
        else { // When user turns the switch OFF
            if switchState == switchTimed {
                NSUserDefaults.standardUserDefaults().setValue("NO" , forKey: kTimer)
            }
            if switchState == switchSound {
                NSUserDefaults.standardUserDefaults().setValue("NO" , forKey: kSound)
            }
            if switchState == switchVibrate {
                NSUserDefaults.standardUserDefaults().setValue("NO" , forKey: kVibrate)
            }
        }
    }// END of stateChanged(switchState: UISwitch)
    
    
    //==========================================================================================================================
    // MARK: Alert
    //==========================================================================================================================

    func displayAlert(title: String, error: String){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if resetButton === sender {
            let email = self.emailText.text ?? ""
            self.email = email
        }
    }
    
    
    //==========================================================================================================================
    // MARK: UITextFieldDelegate
    //==========================================================================================================================
    
    func textFieldDidBeginEditing(textField: UITextField) {
        resetButton.enabled = false
    }
    
    func checkValidEmail() {
        let text = emailText.text ?? ""
        resetButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidEmail()
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================

    @IBAction func resetButton(sender: AnyObject) {
        if emailText.text != nil {
            let queryEmails = PFUser.query()
            queryEmails?.whereKey("email", equalTo: emailText.text!)
            queryEmails?.findObjectsInBackgroundWithBlock{
                (emailObjects, error) -> Void in
                if error == nil {
                    self.emailObj = emailObjects
                    let obj:PFObject = (self.emailObj as! Array)[0];
                    
                    PFUser.requestPasswordResetForEmailInBackground(obj.objectForKey("email") as! String)
                    let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
                    self.navigationController!.pushViewController(homeVC!, animated:true)
                }
            }
        }
        else {
            displayAlert("Invalid Email", error: "Please try again.")
        }
    }
    
    
    //==========================================================================================================================
    // MARK:
    //==========================================================================================================================


}
