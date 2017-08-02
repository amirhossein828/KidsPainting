//
//  CameraViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-08-02.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    var imagePicker: UIImagePickerController!
    
    var imageCamera : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // put image taken from camera inside upload view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFromCameraToUpload" {
            
            if let vc = segue.destination as? UploadItemViewController {
                vc.newImage = self.imageCamera
            }
        }
    }

}

//This protocol is used to take a picture, when the photo is validate by the
//user, the function imagePickerController is called
extension CameraViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        //If the image exists extract it and store in a constant
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.imageCamera = image
            //go to uploadviewcontroller
            performSegue(withIdentifier: "goFromCameraToUpload", sender: self)
            //profilePictureButton.setImage(image, for: .normal)
        }
    }
}

extension CameraViewController: UINavigationControllerDelegate{
    
}
