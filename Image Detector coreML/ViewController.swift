//
//  ViewController.swift
//
//  Image-Detection
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // an ImageView object
    @IBOutlet weak var imageView: UIImageView!
    // object to pick images
    var imagePicker = UIImagePickerController()
    var chosenImage = CIImage()
    
    // result text label
    @IBOutlet weak var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // any event
    }
    
    
    @IBAction func buton(_ sender: Any) {
        // alert before uploading an image
        let alert = UIAlertController(title: "", message: "Source of Image.", preferredStyle: .actionSheet)
           
           let selectPhoto = UIAlertAction(title: "Select Gallery Photo", style: .default) { _ in
               self.preparePickerController(picker2: .photoLibrary)
           }
           
           let takePhoto = UIAlertAction(title: "Capture a Photo", style: .default) { _ in
               self.preparePickerController(picker2: .camera)
           }
        
           // actions on the selected image / photo
           alert.addAction(selectPhoto)
           alert.addAction(takePhoto)
           
           alert.popoverPresentationController?.sourceView = self.view
           alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
           alert.popoverPresentationController?.permittedArrowDirections = []
           
           present(alert, animated: true)
    }
    // controller for image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
                if let ciImage = CIImage(image: image) {
                    chosenImage = ciImage
                    recognizeImage(image: chosenImage)
                }
            }
    }
    
    // the picker controller
    func preparePickerController(picker2: UIImagePickerController.SourceType){
       let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = picker2
        present(picker, animated: true)
    }
    
    // to detect the image
    func recognizeImage(image: CIImage) {

        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        // on the main thread to update the result
                        DispatchQueue.main.async {
                            // level of accuracy
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            // rounding the calculated value
                            let rounded = Int (confidenceLevel * 100) / 100
                            
                            // alert with accuracy result
                            let alert = UIAlertController(title:"Accuracy of Intelligence (Detection):\(rounded)", message: "It seems to be \(topResult!.identifier) ", preferredStyle: .actionSheet)
                            let okBtn = UIAlertAction(title: "Reset Image", style: .cancel) { alert in
                                self.imageView.image = UIImage(named: "")
                            }
                            // popping over controller
                            alert.popoverPresentationController?.sourceView = self.view
                            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                            alert.popoverPresentationController?.permittedArrowDirections = []
                            alert.addAction(okBtn)
                            self.present(alert, animated: true)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
                  DispatchQueue.global(qos: .userInteractive).async {
                    do {
                    try handler.perform([request])
                    } catch {
                        print("error")
                    }
            }
            
            
        }
        
      
        
    }
}

