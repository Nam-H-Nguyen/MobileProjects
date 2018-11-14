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
//import TwitterKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "d_l-W2GxtZXo1DsT5yANb3qom8-R6rfisx70G2AVirwe"
    let version = "2018-11-12"
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
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
//                    self.shareButton.isHidden = false
                }
//                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = classes[0].className
                        self.navigationController?.navigationBar.barTintColor = UIColor(red: 108.0/255.0, green: 230.0/255.0, blue: 121.0/255.0, alpha: 1.0)
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "ok")
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
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
//        TWTRTwitter.sharedInstance().start(withConsumerKey:consumerSecret:)
//        let composer = TWTRComposer()
//
//        composer.setText("Using IBM Watson to do cool visual recognition stuff!")
//        composer.setImage(UIImage(named: "ibm_watson"))
//
//        // Called from a UIViewController
//        composer.show(from: self.navigationController!) { (result) in
//            if (result == .done) {
//            print("Successfully composed Tweet")
//            } else {
//            print("Cancelled composing")
//            }
//        }
    }
}

