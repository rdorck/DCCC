//
//  ResetPasswordViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 10/20/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sendRequestBtn: UIButton!
    
    var emailObj: AnyObject?
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    @IBAction func sendRequestBtn(sender: UIButton) {
        if email != nil {
            let queryEmails = PFUser.query()
            queryEmails?.whereKey("email", equalTo: email.text!)
            queryEmails?.findObjectsInBackgroundWithBlock{
                (emailObjects, error) -> Void in
                if error == nil {
                    self.emailObj = emailObjects
                    let obj:PFObject = (self.emailObj as! Array)[0];
    
                    PFUser.requestPasswordResetForEmailInBackground(obj.objectForKey("email") as! String)
                }
            }
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
            self.navigationController!.pushViewController(loginVC!, animated:true)
        }
        else {
            UtilityClass.showAlert("Enter a valid email address.")
        }
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //==========================================================================================================================
    // MARK:
    //==========================================================================================================================
    
    
    
    
    
}
