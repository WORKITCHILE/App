//
//  ImagePickerViewController.swift
//  Work It
//
//  Created by qw on 03/02/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

protocol PickImage{
    func geImagePath(image: UIImage,imagePath: String, imageData: Data)
}

class ImagePickerViewController: UIViewController {
    
    static var imagePickerDelegate = ImagePickerViewController()
    var imagePath: String?
    var imageName: String?
    var imageDelegate: PickImage? = nil
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        
    }
}

extension ImagePickerViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        if let selectedImageName = ((info[UIImagePickerController.InfoKey.referenceURL] as? NSURL)?.lastPathComponent) {
            self.imageName = selectedImageName
        }else {
            self.imageName = "image.jpg"
        }
        let imageData:NSData = selectedImage.pngData()! as NSData
        
        imageDelegate?.geImagePath(image: selectedImage,imagePath:self.imageName!, imageData: selectedImage.pngData()!)
        picker.dismiss(animated: true)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Allow Camera to take photos",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default){
            _ in
        })
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        self.present(alertController, animated: true)
    }
}
