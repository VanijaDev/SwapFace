//
//  UIImage+AddImage.swift
//  SwapFaces
//
//  Created by Ivan Solomichev on 10/11/15.
//  Copyright © 2015 Vanijatko. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func drawImage(imageToDraw: UIImage!, atRect: CGRect!, onImage: UIImage!) -> UIImage {        
        UIGraphicsBeginImageContextWithOptions(onImage.size, false, 0.0);
        onImage.drawInRect(CGRectMake(0, 0, onImage.size.width, onImage.size.height))
        imageToDraw.drawInRect(atRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}