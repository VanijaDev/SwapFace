//
//  ViewController.swift
//  SwapFaces
//
//  Created by Ivan Solomichev on 10/11/15.
//  Copyright © 2015 Vanijatko. All rights reserved.
//

class FaceModel {
    let image:UIImage!
    let drawRect:CGRect!
    
    init(aImage: UIImage!, aDrawRect: CGRect!) {
        image = aImage
        drawRect = aDrawRect
    }
}

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var swapFacesBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSwapFacesBtnAvailable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImageBtnAction(sender: AnyObject) {
        showPhotoGallery()
    }
    
    @IBAction func swapFacesBtnAction(sender: AnyObject) {
        activityIndicator.startAnimating()
        
        //  disable swap btn
        swapFacesBtn.enabled = false
        swapFacesBtn.alpha = 0.5
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let faces: Array<FaceModel> = self.facesInImage(self.imageV.image!)
            
            if faces.count > 0 {
                //  swap
                let rndMax: UInt32 = UInt32(faces.count - 1)
                var newImage: UIImage = self.imageV.image!
                
                for faceModel in faces {
                    let rnd: Int = Int(arc4random_uniform(rndMax))
                    newImage = UIImage.drawImage(faceModel.image, atRect: faces[rnd].drawRect, onImage: newImage)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageV.image = newImage
                    self.activityIndicator.stopAnimating()
                })
            } else  {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    //  MARK: activate / deactivate swapBtn
    func updateSwapFacesBtnAvailable() {
        if imageV.image != nil {
            swapFacesBtn.enabled = true
            swapFacesBtn.alpha = 1.0
        } else {
            swapFacesBtn.enabled = false
            swapFacesBtn.alpha = 0.5
        }
    }
    
    func showPhotoGallery() {
        let galleryVC = UIImagePickerController()
        galleryVC.delegate = self
        galleryVC.sourceType = .SavedPhotosAlbum
        self.presentViewController(galleryVC, animated: true, completion: nil)
    }
    
    func facesInImage(image: UIImage!) -> Array<FaceModel> {
        let ciImage = CIImage(CGImage: image.CGImage!)
        let cgImage = image.CGImage
        
        var result: Array<FaceModel> = Array()
        
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
        let faces = faceDetector.featuresInImage(ciImage)
        
        for face in faces {
            if (face as? CIFaceFeature != nil) {
                
                var faceRect: CGRect = face.bounds
                faceRect.origin.y = imageV.image!.size.height - faceRect.origin.y - faceRect.size.height
                
                let imageRef: CGImageRef = CGImageCreateWithImageInRect(cgImage, faceRect)!
                let faceImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
                
                let faceModel: FaceModel = FaceModel(aImage: faceImage, aDrawRect: faceRect)
                result.append(faceModel)
            }
        }
        
        return result
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.imageV.image = nil
            self.updateSwapFacesBtnAvailable()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                self.imageV.image = img
                self.updateSwapFacesBtnAvailable()
            })
        }
    }
}

