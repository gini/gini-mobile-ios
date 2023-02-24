//
//  UIImage.swift
//  
//
//  Created by David Vizaknai on 22.02.2023.
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
