//
//  LoginViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/11/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassWord: UITextField!
    
    @IBOutlet var btnSignUp : UIButton!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet weak var btnResetPassword: UIButton!
    
    @IBOutlet weak var lblAuthResult: UILabel!
    
    var currentUser: PFUser?
    
    
    //==========================================================================================================================
    // MARK: Life Cycle methods
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = nil
        
        txtUserName.delegate = self
        txtPassWord.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))

//            let str =  currentUser?.objectId
//            NSUserDefaults .standardUserDefaults().setObject(str, forKey: kLoggedInUserId)
//            let strUsername = currentUser?.username
//            NSUserDefaults.standardUserDefaults().setObject(strUsername, forKey: kLoggedInUserName)
//
            //self.isAdmin()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if txtUserName.becomeFirstResponder() {
            if txtUserName.isFirstResponder() == true {
               // print("username field isFirstResponder.")

            }
        }

        
    }
    
    
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
    // MARK: Methods
    //==========================================================================================================================
    
    func dismissKeyboard() {
        txtUserName.resignFirstResponder()
        txtPassWord.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtUserName.resignFirstResponder()
        txtPassWord.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if txtUserName.isFirstResponder() {
            let start = textField.beginningOfDocument
            txtUserName.textRangeFromPosition(start, toPosition: start)
        }
    }
    
    
    //==========================================================================================================================
    // MARK: ACL Check & Set
    //==========================================================================================================================
    
    func isAdmin() {
        let roleACL = PFACL()
        roleACL.setPublicReadAccess(true)
        roleACL.setPublicWriteAccess(false)
        
        let role = PFRole(name: "Admin", acl: roleACL)
        
        let user = PFQuery.getUserObjectWithId("AU98WHZZBa")
        role.users.addObject(user!)
        role.saveInBackgroundWithBlock{ (success, error) -> Void in
            if error == nil {
                print("Admin is \(user) with role title :\(role)")
            } else{
                print("Error saving role: \(error)")
            }
        }
    }
    
    
    //==========================================================================================================================
    // MARK: TouchID Message
    //==========================================================================================================================
    
    func writeOutAuthResult(authError:NSError?) {
        dispatch_async(dispatch_get_main_queue(), {() in
            if let possibleError = authError {
                self.lblAuthResult.textColor = UIColor.redColor()
                self.lblAuthResult.text = possibleError.localizedDescription
            }
            else {
                self.lblAuthResult.textColor = UIColor.greenColor()
                self.lblAuthResult.text = "Authentication successful."
            }
        })
    }
    
    func loadData(){
        print("Loading home screen ... ")
        let swRevealVC = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        swRevealVC.pushFrontViewController(homeVC, animated: true)
        self.presentViewController(swRevealVC, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueHome" {
            if let swRevealVC = segue.destinationViewController as! SWRevealViewController {
                let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                swRevealVC.pushFrontViewController(homeVC, animated: true)
                
            }
        }
    }
    */
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
   
    @IBAction func beginTouchIDAuthCheck(sender: AnyObject) {
        let authContext:LAContext = LAContext()
        var error:NSError?
        
        // Is Touch ID hardware available & configured?
        if(authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&error)) {
            //Perform Touch ID auth
            authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with Touch ID", reply: {(successful:Bool, error:NSError?) in
                
                if(successful) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.loadData()
                    })
                } else {
                    // There are a few reasons why it can fail, we'll write them out to the user in the label
                    self.writeOutAuthResult(error)
                }
            })
        } else {
            // Missing the hardware or Touch ID isn't configured
            self.writeOutAuthResult(error)
        }
    }

    @IBAction func btnSignUp(sender: UIButton) {
        let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        self.navigationController!.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func btnLogin(sender: AnyObject) {
        if !txtUserName.text!.isEmpty {
            if !txtPassWord.text!.isEmpty {
                NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
                
                let username = self.txtUserName.text
                let pass = self.txtPassWord.text
                
                PFUser.logInWithUsernameInBackground(username!, password: pass!) { (user, error) -> Void in
                    if user != nil {
                        print("Logged in successfully as \(user!)")
                        self.currentUser = user
                        
                        let str =  self.currentUser?.objectId
                        NSUserDefaults .standardUserDefaults().setObject(str, forKey: kLoggedInUserId)
                        
                        let str11 =  self.currentUser?.objectId
                        NSUserDefaults .standardUserDefaults().setObject(str11, forKey: kLoggedInUserId)
                        let strUsername = self.currentUser?.username
                        NSUserDefaults.standardUserDefaults().setObject(strUsername, forKey: kLoggedInUserName)
                        
                        let swRevealVC = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                        swRevealVC.pushFrontViewController(homeVC, animated: true)
                        self.navigationController?.presentViewController(swRevealVC, animated: true, completion: nil)
                        
                        hideHud(self.view)

                    } else {
                        print("Error logging in with username \(username) & password")
                        let loginVC = self.storyboard?.instantiateInitialViewController()
                        self.navigationController?.presentViewController(loginVC!, animated: true, completion: nil)
                    }
                }
            }
            else {
                UtilityClass.showAlert("Please insert your password")
            }
        } else {
            UtilityClass.showAlert("Please insert your username")
        }
    }

    @IBAction func btnResetPassword(sender: UIButton) {
        let resetPasswordVC = self.storyboard?.instantiateViewControllerWithIdentifier("ResetPasswordViewController") as? ResetPasswordViewController
            self.navigationController!.pushViewController(resetPasswordVC!, animated:true)
    }
    
    
    //==========================================================================================================================
    // MARK: Show Indication
    //==========================================================================================================================
    
     func showhud() {
        showHud(self.view)
     }
    
    

}
