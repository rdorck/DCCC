//
//  PhotoTakingHelper.swift
//  SalesGame_swift
//
//  Created by Robert Rock on 1/4/16.
//  Copyright © 2016 Akshay. All rights reserved.
//

import UIKit

/*
 * Three main tasks:
 *      1) Present popover to allow user to choose btwn taking photo or using library
 *      2) Depending on choice, present appropiate selection
 *      3) Return photo
 */
typealias PhotoTakingHelperCallback = UIImage? -> Void


extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        callback(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}


class PhotoTakingHelper: NSObject {

    //==========================================================================================================================
    // MARK: Properties
    //==========================================================================================================================
    
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    
    //==========================================================================================================================
    // MARK: Initialization
    //==========================================================================================================================
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
    
    
    //==========================================================================================================================
    // MARK: Methods
    //==========================================================================================================================
    
    /* Allow user to choose btwn camera & photo library */
    func showPhotoSourceSelection() {
        // .ActionSheet indicates pop-up gets displayed from bottom of screen
        let alertController = UIAlertController(title: nil, message: "How would you like to load your photo?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
                self.showImagePickerController(.PhotoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        if UIImagePickerController.isCameraDeviceAvailable(.Rear) {
            let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
                self.showImagePickerController(.Camera)
            }
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /* instantiates imagePickerController, presentes view depending on passed in param of sourceType */
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
    
    
    
    
}
