//
//  UIImage+TintColor.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 14.09.23.
//

import UIKit

extension UIImage {
    func tintedImageWithColor(_ color: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(origin: .zero, size: size))
        
        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return imageColored
    }
}
