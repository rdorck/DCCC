//
//  EditProfileViewController.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 10/20/15.
//  Copyright © 2015 Akshay. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UINavigationControllerDelegate {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    @IBOutlet weak var imgUpload: UIImageView!
    @IBOutlet weak var imgUploadText: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var newDept: String?
    var newProfilePFImage: PFFile?
    
    let imagePicker = UIImagePickerController()

    var pic: AnyObject?
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var photoTakingHelper: PhotoTakingHelper?
    var takePhotoImageFile: PFFile?
    
    
    //==========================================================================================================================
    // MARK: Lifecycle
    //==========================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSThread .detachNewThreadSelector("showhud", toTarget: self, withObject: nil)
        
        saveButton.enabled = false
        
        UtilityClass.setMyViewBorder(imgUpload, withBorder: 0, radius: 75)
        let currentUser = PFUser.currentUser()
        self.usernameLabel.text = currentUser?.objectForKey("username") as? String
        
        displayUserImg()
    }
    
    
    //==========================================================================================================================
    // MARK: Fetch & Query
    //==========================================================================================================================
    
    /* Retrieve user's profile pic and display it.  Allows user to change img */
    func displayUserImg(){
        let currentUser = PFUser.currentUser()!
        
        if let file: PFFile = currentUser["profilePic"] as? PFFile {
            print("EditProfile displayUserImg() file: \(file)")
            file.getDataInBackgroundWithBlock({
                (imageData, error) -> Void in
                if error == nil {
                    let Image: UIImage = UIImage(data: imageData!)!
                    self.imgUpload.image = Image
                    //hideHud(self.view)
                } else {
                    print("Error \(error)")
                }
            })
        }else {
            self.imgUpload.image = UIImage(named: "add photo-30")
        }
    } // END of displayUserImg()
    
    
    //=======================================================================================================
    // MARK: Navigation
    //=======================================================================================================
    
    /* Configure View before it's presented */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            
            // set global department variable for use in unwindToProfile in ProfileVC
//            let newDepartment = self.departmentTextField.text ?? ""
//            self.newDept = newDepartment
            
//            let newImgData = UIImagePNGRepresentation(self.imgUpload.image!)
//            let parseImg = PFFile(name: "profilePNG.png", data: newImgData!)
            
//            self.newProfilePFImage = parseImg
            
        }
    }
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //==========================================================================================================================
    // MARK: UITextFieldDelegate
    //==========================================================================================================================
    
//    func textFieldDidBeginEditing(textField: UITextField){
//        saveButton.enabled = false
//    }
    
//    func checkValidDepartmentName() {
//        let text = departmentTextField.text ?? ""
//        saveButton.enabled = !text.isEmpty
//    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        checkValidDepartmentName()
//    }
    
    
    //=======================================================================================================
    // MARK: ImagePicker
    //=======================================================================================================

    @IBAction func imgUploadFromSource(sender: AnyObject) {
        takePhoto()
    }
    
    func takePhoto() {
        /* in keyword marks begginning of closure code */
        photoTakingHelper = PhotoTakingHelper(viewController: self) { (image: UIImage?) in
            //print("received a callback")
            if let image = image {
                let imageData = UIImageJPEGRepresentation(image, 0.8)!
                let imageFile = PFFile(data: imageData)
                
                self.photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                    UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                }
                
                imageFile.saveInBackgroundWithBlock { (success, error) -> Void in
                    if error == nil {
                        UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                    } else {
                        print("Error saving photo: \(error)")
                    }
                }
                
                self.takePhotoImageFile = imageFile // set var for when passed back to ProfileVC
                
                self.imgUpload.image = image
                self.saveButton.enabled = true
            }
        }
    }

    
    //==========================================================================================================================
    // MARK: Actions
    //==========================================================================================================================
    
    
    //==========================================================================================================================
    // MARK: Progress hud display methods
    //==========================================================================================================================
    
    func showhud() {
        showHud(self.view)
    }
    
    
}
