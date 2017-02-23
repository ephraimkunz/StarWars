//
//  DataUtilities.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
import UIKit

struct DataUtilities{
    
    // Get the swapi id of an item from it's url
    static func idFromUrl(url: String) -> String{
        let array = url.components(separatedBy: "/")
        return array[array.count - 2] //Second to last item
    }
    
    
    static func imageScaledToWidth(image: UIImage?, width: CGFloat) -> UIImage?{
        guard let image = image else{
            return nil
        }
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor;
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage

    }
}
