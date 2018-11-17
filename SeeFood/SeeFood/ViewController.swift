//
//  ViewController.swift
//  SeeFood
//
//  Created by NomNomNam on 11/11/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import CoreML
import Vision   // Allow image processing more easily

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController() // object of the class ImagePickerController
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 'If' statement triggers if device has no camera
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            imagePicker.delegate = self     // set imagePicker as the delegate
            imagePicker.sourceType = .camera    // allows user to tap into the camera functionality
            imagePicker.allowsEditing = false     // disallows user to crop/edit photos
        }
    }
    
    // What happens when user picks the media
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        // Safer with optional binding if userPickedImage which is of datatype any can be downcasted to UIImage, if it is, set the imageview to the image the user picked
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // Convert image to core image to use vision framework allowing ML interpretation on the image
            guard let ciimage = CIImage(image: userPickedImage) else {fatalError("Could not convert to UIImage to CIImage.")}
            
            detect(image: ciimage)
        }
        
        // Dismiss ImagePicker and go back to View Controller
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // Process CIImage and get classification out of the CIImage
    func detect(image: CIImage) {
        
        // If model is nil, trigger fatal error message
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        // Process results of the request of the model
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
//            print(results)
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    self.topBarImageView.image = UIImage(named:"hotdog")
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    self.topBarImageView.image = UIImage(named:"not-hotdog")
                }
            }
        }
        
        // Handler to specify what request we want to handle
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Handler failed to specificy request, \(error)")
        }
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

