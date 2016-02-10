//
//  SignUpViewController.swift
//  SalesGame_swift
//
//  Created by Akuma on 9/11/15.
//  Copyright (c) 2015 Akuma. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirm: UITextField!
    @IBOutlet weak var labelConfirm: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet var btnSignUp : UIButton!
    @IBOutlet var btnCancel : UIButton!

    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelConfirm.hidden = true
        
    }
    
    
    func displayAlert(title: String, error: String){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func btnCancel(sender: UIButton) {
            self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func btnSignUp(sender: UIButton) {
        if !txtEmail.text!.isEmpty {
            if UtilityClass .Emailvalidate(txtEmail.text) == true {
                if !txtUserName.text!.isEmpty {
                    if !txtPassword.text!.isEmpty {
                        if !txtConfirm.text!.isEmpty {
                            NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
                            var email = txtEmail.text
                            let password = txtPassword.text
                            let confirm = txtConfirm.text
                            let username = txtUserName.text
                            let fname = self.firstName.text
                            let lname = self.lastName.text
                            let phone = self.phone.text
                            
                            // Ensure username is lowercase
                            email = email!.lowercaseString
                            
                            if username!.utf16.count < 3 || password!.utf16.count < 3 {
                                
                                displayAlert("Invalid", error: "username and / or password must be greater than 4 characters")
                                
                            } else if email!.utf16.count < 8 {

                                displayAlert("Invalid", error: "Please enter a valid email address")
                            }
                            else if password!.utf16.count != confirm!.utf16.count {
                                //displayAlert("Verify Password", error: "passwords are not the same size")
                                self.labelConfirm.text = "passwords are not the same size"
                                self.labelConfirm.hidden = false
                            }
                            else {
                                let newUser = PFUser()
                                newUser.username = username
                                newUser.password = password
                                newUser.email = email
                                newUser["firstName"] = fname
                                newUser["lastName"] = lname
                                newUser["phone"] = phone
                                newUser["level"] = 1
                                
                                /* newUser emailedVerified does not need setting.  It is automatically false.
                                *   Verification link is sent to user's email, after successful completion,
                                *   the value is changed automatically to true.
                                */
                                
                                //let teamMemberACL = PFACL()
                                //teamMemberACL.setPublicReadAccess(true)
                                //teamMemberACL.setWriteAccess(true, forRoleWithName: "Admin")
                                //teamMemberACL.setReadAccess(true, forRoleWithName: "Admin")
                                //
                                //let teamMember = PFRole(name: "TeamMember", acl: teamMemberACL)
                                //teamMember.saveInBackground()
                                
                                if newUser.signUp() {
                                    hideHud(self.view)
                                    
                                } else {
                                    UtilityClass .showAlert("Please try again.")
                                    let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as? SignUpViewController
                                    self.navigationController?.pushViewController(signUpVC!, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    } // END of btnSignUp()

    
    //==========================================================================================================================
    // MARK: Navigation
    //==========================================================================================================================
    
    
    
    //==========================================================================================================================
    // MARK: Progress Hud
    //==========================================================================================================================

    func showhud() {
        showHud(self.view)
    }
}
