//
//  ViewController.swift
//  ImageDetector
//
//  Created by Jon Manning on 22/8/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit

// Necessary additional imports
import Vision
import CoreML

class ViewController: UIViewController {

    // References to the buttons
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    // Actions, run by the buttons
    @IBAction func takePhoto(_ sender: Any) {
        takeImage(sourceType: .camera)
    }
    @IBAction func chooseFromLibrary(_ sender: Any) {
        takeImage(sourceType: .photoLibrary)
    }
    
    // An instance of our classification model
    let model = SqueezeNet()
    
    // A shared method that captures a photo from a given source
    func takeImage(sourceType: UIImagePickerControllerSourceType) {
        
        // Don't forget that we need to set NSCameraUsageDescription!
        
        // Create a picker
        let controller = UIImagePickerController()
        
        // Ensure that the source type is available to sue
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            NSLog("Source type \(sourceType) isn't available.")
            return
        }
        
        // Use the specified source type
        controller.sourceType = sourceType
        
        // Allow editing the image we take
        controller.allowsEditing = true
        
        // Receive callbacks on this object
        controller.delegate = self
        
        // If this isn't a camera and we're running on
        // an iPad, we are required to present it
        // in a popover
        if sourceType != .camera && self.traitCollection.userInterfaceIdiom == .pad {
            
            // Display in a popover
            controller.modalPresentationStyle = .popover
            
            // When modalPresentationStyle is 'popover', the popoverPresentationController
            // property is non-nil, and can be used to configure the popover
            
            // Display the popover from the image view
            controller.popoverPresentationController?.sourceView = self.view
            controller.popoverPresentationController?.sourceRect = imageView.frame
            
           // Allow the popover to overlay the image view (otherwise it won't fit on an iPad screen)
            controller.popoverPresentationController?.canOverlapSourceViewRect = true
        }
        
        // Present the picker
        self.present(controller, animated: true, completion: nil)
        
    }
    
    // Called by the image picker controller delegate
    // method to deal with the image we got
    func imageSelected(image: UIImage) {
        
        // Display the image
        self.imageView.image = image
        
        // Display some text while we wait for the prediction to finish
        predictionLabel.text = "Detecting object..."
        
        // Detect the most likely type of the most prominent object.
        detectObjects(in: image) { (result: String) in
            
            // Once we have the prediction, display it
            self.predictionLabel.text = result
        }
        
    }
    
    // Given an image, attempts to detect objects in it.
    // The 'completion' block is passed the result as a string.
    func detectObjects(in image: UIImage, completion: @escaping (_ result: String) -> Void) {
        
        // We may be calling 'completion' on the main queue, or on the background queue.
        // So, we wrap it in a block that ensures that it's run on the main queue.
        let completionOnMain = { (value : String) in
            OperationQueue.main.addOperation {
                completion(value)
            }
        }
        
        // Load the model in a form usable by Vision
        guard let model = try? VNCoreMLModel(for: model.model) else {
            completionOnMain("Error: Can't load the model!")
            return
        }
        
        // Vision deals in CIImages, not UIImages, so we need to convert
        guard let image = CIImage(image: image) else {
            completionOnMain("Can't convert the image to a CIImage!")
            return
        }
        
        // Create a Vision request to use a model; it will run
        // the block we provide when it completes processing
        
        // We do this because the CoreML model expects input in the form
        // of CVPixelBuffer objects of a particular format and size, and
        // those are annoying to prepare, so we get Vision to take care of that for us
        let request = VNCoreMLRequest(model: model) { request, error in
            
            // Ensure we got no error
            guard error == nil else {
                completionOnMain("Error: \(error!)")
                return
            }
            
            // Get the results back from the classifier
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    
                    // We either didn't get any results, or the result list was
                    // not an array of VNClassificationObservation.
                    completionOnMain("Couldn't get results from the model.")
                    return
            }
            
            // Prepare our report and send it back to our completion handler
            let confidence = "\(Int(topResult.confidence * 100))%"
            let labelText = "\(topResult.identifier) (\(confidence))"
            completionOnMain(labelText)
            
        }
        
        // Create a handler that works with this image
        let handler = VNImageRequestHandler(ciImage: image)
        
        // Perform the request, using this image, in the background
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                // Attempt to classify
                try handler.perform([request])
            } catch {
                completionOnMain("Error classifying image: \(error)")
            }
        }
        
    }
    

}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Called when the user finishes taking an image.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            // Dismiss the image picker UI when we leave
            picker.dismiss(animated: true, completion: nil)
        }
        
        // Select either the edited image, or the original image
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage ??
                            info[UIImagePickerControllerEditedImage] as? UIImage else {
                                
            // And if we don't have an image, report that and bail out
            NSLog("No image selected.")
                                
            return
        }
        
        // Indicate to the view controller that we got an image
        self.imageSelected(image: image)
        
        
    }
}

