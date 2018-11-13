//
//  ViewController.swift
//  WhatIsIt
//
//  Created by NomNomNam on 11/12/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "d_l-W2GxtZXo1DsT5yANb3qom8-R6rfisx70G2AVirwe"
    let version = "2018-11-12"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    // Display image picked inside image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Since results has not come back yet, disable/gray out the camera button
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            let imageData = userPickedImage.jpegData(compressionQuality: 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(image: userPickedImage) { (classifiedImages) in
                // Dig down to classification results and store into classes
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                // Clear out classification results array after each previous classification
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                
                print(self.classificationResults)
                
                // Once results has come back, enable the camera button to be pressed again
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
//                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = classes[0].className
                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.navigationItem.title = "Not hotdog!"
//                    }
//                }
            }
            
        } else {
            print("Error while picking the image")
        }
        
        // Dismiss ImagePicker and go back to View Controller
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

