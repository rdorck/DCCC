//
//  HelpViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 10/20/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        navigationItem.title = "Help"
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
    // MARK: Actions
    //==========================================================================================================================
       
    
    //==========================================================================================================================
    // MARK: 
    //==========================================================================================================================
    
    
    
    
}
