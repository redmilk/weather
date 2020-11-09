//
//  Helpers.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 31.10.2020.
//

import UIKit

enum Helper {
    
    static func imageFromText(text: String, font: UIFont) -> UIImage {
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        text.draw(at: CGPoint(x: 0, y:0), withAttributes: [NSAttributedString.Key.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    static func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
           UIApplication.shared.open(settingsUrl)
         }
    }
    
}

