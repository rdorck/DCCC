//
//  BackTableVC.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 11/25/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import Foundation

class BackTableVC: UITableViewController {
    
    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================

    var tableArray = [String]()
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================

    override func viewDidLoad() {
        
        tableArray = ["Home", "Friends", "Badges", "Help", "Settings"]
        
    }
    
    
    //==========================================================================================================================
    // MARK: TableDatasource & Delegate
    //==========================================================================================================================

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableArray[indexPath.row], forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.tableArray[indexPath.row]
        
        return cell
    }
    
    
    
    
}